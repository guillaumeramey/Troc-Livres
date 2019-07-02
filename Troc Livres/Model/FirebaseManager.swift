//
//  FirebaseManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 05/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

struct FirebaseManager {
    
    static let db = Firestore.firestore()
    static let usersCollection = db.collection("users")
    static let chatsCollection = db.collection("chats")
    static let booksCollection = db.collection("books")

    // MARK: - Authentication

    static func signIn(withEmail email: String, password: String, completion: @escaping (String?) -> Void ) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(getErrorMessage(from: error))
                return
            }
            Persist.uid = result?.user.uid ?? ""
            completion(nil)
        }
    }

    static func signOut() {
        Persist.uid = ""
        Persist.name = ""
        Persist.address = ""
        Persist.location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        do {
            try Auth.auth().signOut()
            Switcher.updateRootVC()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    static func resetPassword(withEmail email: String, completion: @escaping (String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(getErrorMessage(from: error))
                return
            }
            completion(nil)
        }
    }
    
    private static func getErrorMessage(from error: Error) -> String {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            switch errorCode {
            case .invalidEmail:
                return "E-mail invalide"
            case .emailAlreadyInUse:
                return "E-mail déjà utilisé"
            case .userNotFound:
                return "Utilisateur introuvable"
            case .networkError:
                return "Problème de connexion"
            case .wrongPassword:
                return "Mot de passe incorrect"
            default:
                return "Error \(errorCode.rawValue): \(error.localizedDescription)"
            }
        }
        return "Erreur inconnue"
    }

    // MARK: - User management

    static func createUser(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(getErrorMessage(from: error))
                return
            }
            Persist.uid = result?.user.uid ?? ""
            completion(nil)
        }
    }


    // Get a specific user
    static func getUser(uid: String, completion: @escaping (User?) -> Void) {
        usersCollection.document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                completion(User(from: document))
            }
        }
    }
    
    // Get all the users
    static func getUsers(completion: @escaping ([User]) -> Void) {
        usersCollection.whereField("numberOfBooks", isGreaterThan: 0).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            var users = [User]()
            for document in snapshot.documents {
                if Persist.uid != document.documentID {
                    users.append(User(from: document))
                }
                completion(users)
            }
        }
    }

    static func setUserName(_ name: String, completion: @escaping (Bool) -> Void) {
//        let userData = ["name": name,
//                        "address": "Non renseigné",
//                        "numberOfBooks": 0] as [String : Any]
        Persist.name = name
        usersCollection.document(Persist.uid).setData(["name": name]) { error in
            completion(error == nil)
        }
    }

    static func setUserLocation(address: String, location: CLLocation, completion: @escaping (Bool) -> Void) {
        let geoPoint = GeoPoint(latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude)
        usersCollection.document(Persist.uid)
            .updateData(["address": address, "location": geoPoint]) { (error) in
            completion(error == nil)
        }
    }

    static func deleteUser(completion: @escaping (Result<Bool, Error>) -> Void) {

        // Send a message in the user chats
        getUserChats { chats in
            let batch = db.batch()
            for chat in chats {
                sendMessage(in: chat, content: "Utilisateur supprimé", system: true)
            }
            batch.commit() { error in
                print("Send messages in user chats")
                if let error = error {
                    print("Error writing batch \(error)")
                } else {
                    print("Batch write succeeded.")
                }
            }
        }
        
        // Delete user books
        FirebaseManager.getBooks(uid: Persist.uid) { (books) in
            let bookData = ["owners": FieldValue.arrayRemove([Persist.uid])]
            let batch = db.batch()
            for book in books {
                if let id = book.id {
                    batch.updateData(bookData, forDocument: booksCollection.document(id))
                }
            }
            batch.commit() { error in
                print("Delete user books")
                if let error = error {
                    print("Error writing batch \(error)")
                } else {
                    print("Batch write succeeded.")
                }
            }
        }
        
        // Delete the user wishlist
        db.collectionGroup("wishlist")
            .whereField("applicant", isEqualTo: Persist.uid)
            .getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                let batch = db.batch()
                for document in snapshot.documents {
                    let docRef = usersCollection.document(Persist.uid).collection("wishlist").document(document.documentID)
                    batch.deleteDocument(docRef)
                }
                batch.commit() { error in
                    print("Delete the user wishlist")
                    if let error = error {
                        print("Error writing batch \(error)")
                    } else {
                        print("Batch write succeeded.")
                    }
                }
            }
        }
        
        // Delete the user's books in all the wishlists
        db.collectionGroup("wishlist").whereField("owner", isEqualTo: Persist.uid).getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                let batch = db.batch()
                for document in snapshot.documents {
                    let uid = document.get("applicant") as! String
                    let docRef = usersCollection.document(uid).collection("wishlist").document(document.documentID)
                    batch.deleteDocument(docRef)
                }
                batch.commit() { error in
                    print("Delete the user's books in all the wishlists")
                    if let error = error {
                        print("Error writing batch \(error)")
                    } else {
                        print("Batch write succeeded.")
                    }
                }
            }
        }

        // Delete user data
        usersCollection.document(Persist.uid).delete()

        // Delete user account
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(true))
        }
    }

    // MARK: - Book management

    static func addBook(_ book: Book, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let id = book.id else { return }

        booksCollection.document(id).getDocument { (document, error) in
            if let document = document, document.exists {
                // update owners
                let bookData = ["owners": FieldValue.arrayUnion([Persist.uid])]
                booksCollection.document(id).updateData(bookData) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    // Add 1 to the number of books
                    usersCollection.document(Persist.uid).updateData(["numberOfBooks": FieldValue.increment(Int64(1))])
                    completion(.success(true))
                }
                return
            }
            // Create book
            let bookData = ["title": book.title as Any,
                            "authors": book.authors as Any,
                            "description": book.bookDescription as Any,
                            "imageURL": book.imageURL as Any,
                            "language": book.language as Any,
                            "owners": [Persist.uid] as Any]
            booksCollection.document(id).setData(bookData) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                // Add 1 to the number of books
                usersCollection.document(Persist.uid).updateData(["numberOfBooks": FieldValue.increment(Int64(1))])
                completion(.success(true))
            }
        }
    }

    static func getBooks(uid: String, completion: @escaping ([Book]) -> Void) {
        booksCollection.whereField("owners", arrayContains: uid).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            var books = [Book]()
            for document in snapshot.documents {
                books.append(Book(from: document))
            }
            completion(books)
        }
    }

    static func deleteBook(_ book: Book, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let id = book.id else { return }
        let bookData = ["owners": FieldValue.arrayRemove([Persist.uid])]
        booksCollection.document(id).updateData(bookData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            // Substract 1 to the number of books
            usersCollection.document(Persist.uid).updateData(["numberOfBooks": FieldValue.increment(Int64(-1))])
            
            // Delete the book in all the wishlists
            db.collectionGroup("wishlist")
                .whereField("owner", isEqualTo: Persist.uid)
                .whereField("bookId", isEqualTo: id)
                .getDocuments { (snapshot, error) in
                    guard let snapshot = snapshot else { return }
                    let batch = db.batch()
                    for document in snapshot.documents {
                        let uid = document.get("applicant") as! String
                        let docRef = usersCollection.document(uid).collection("wishlist").document(document.documentID)
                        batch.deleteDocument(docRef)
                    }
                    batch.commit() { error in
                        if let error = error {
                            print("Error writing batch \(error)")
                            completion(.failure(error))
                        } else {
                            print("Batch write succeeded.")
                            completion(.success(true))
                        }
                    }
            }
        }
    }

    // MARK: - Wishes management

    // If matches are found, return the 1st book in the list
    static func getMatch(with uid: String, completion: @escaping (String) -> Void) {
        db.collectionGroup("wishlist")
            .whereField("owner", isEqualTo: Persist.uid)
            .whereField("applicant", isEqualTo: uid)
            .order(by: "timestamp")
            .getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                completion(snapshot.documents.first?.get("bookTitle") as? String ?? "")
        }
    }
    
    static func isBookInWishlist(uid: String, _ book: Book, completion: @escaping (Bool) -> Void) {
        guard let id = book.id else { return }
        usersCollection.document(Persist.uid).collection("wishlist").document(uid + id).getDocument { (document, error) in
            if let document = document, document.exists {
                completion(true)
                return
            }
            completion(false)
        }
    }

    static func addBookToWishlist(uid: String, _ book: Book) {
        guard let id = book.id, let title = book.title else { return }
        let data = ["applicant": Persist.uid,
                    "owner": uid,
                    "bookTitle": title,
                    "bookId": id,
                    "timestamp": FieldValue.serverTimestamp()] as [String : Any]
        usersCollection.document(Persist.uid).collection("wishlist").document(uid + id).setData(data)
    }

    static func removeBookFromWishlist(uid: String, _ book: Book) {
        guard let id = book.id else { return }
        usersCollection.document(Persist.uid).collection("wishlist").document(uid + id).delete()
    }

    // MARK: - Chat management

    private static func createChat(id: String, with user: User, completion: @escaping (Result<Chat, Error>) -> Void) {
        let chatData = [
            "users": [Persist.uid, user.uid],
            "timestamp": FieldValue.serverTimestamp(),
            Persist.uid: ["name": user.name, "uid": user.uid, "unread": false] as [String : Any],
            user.uid: ["name": Persist.name, "uid": Persist.uid, "unread": true] as [String : Any]] as [String : Any]
        chatsCollection.document(id)
            .setData(chatData, completion: { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(Chat(id: id, with: user)))
            }
        })
    }

    // the current user chats
    static func getUserChats(completion: @escaping ([Chat]) -> Void) {
        chatsCollection
            .whereField("users", arrayContains: Persist.uid)
            .order(by: "timestamp", descending: true)
            .getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            var chats = [Chat]()
            for document in snapshot.documents {
                chats.append(Chat(from: document))
            }
            completion(chats)
        }
    }

    static func getChat(with user: User, completion: @escaping (Result<Chat, Error>) -> Void) {
        // Unique chat id between 2 users
        let chatId = Persist.uid < user.uid ? Persist.uid + user.uid : user.uid + Persist.uid

        chatsCollection.document(chatId)
            .getDocument { (document, error) in
            if let document = document, document.exists {
                completion(.success(Chat(from: document)))
            } else {
                createChat(id: chatId, with: user, completion: { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let chat):
                        completion(.success(chat))
                    }
                })
            }
        }
    }

    static var chatListener: ListenerRegistration!

    static func getMessages(in chat: Chat, completion: @escaping ([Message]) -> Void) {
        chatListener = chatsCollection.document(chat.id).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            var messages = [Message]()
            for document in snapshot.documents {
                messages.append(Message(from: document))
            }
            completion(messages)
        }
    }

    static func leaveChat() {
        chatListener.remove()
    }

    static func sendMessage(in chat: Chat, content: String, system: Bool) {
        let messageData = ["content": content,
                           "sender": system ? "system" : Persist.uid,
                           "timestamp": FieldValue.serverTimestamp() as Any]

        chatsCollection.document(chat.id).collection("messages")
            .addDocument(data: messageData)
        // mark the chat as unread for the receiver
        markChatAsUnread(chat: chat, uid: chat.uid)
        
        // if it's an automatic message, mark the chat as unread for the current user
        system ? markChatAsUnread(chat: chat, uid: Persist.uid) : nil
        
        // update the timestamp in the chat
        chatsCollection.document(chat.id)
            .updateData(["timestamp": FieldValue.serverTimestamp()])
    }

    static func markChatAsRead(id: String) {
        chatsCollection.document(id)
            .updateData(["\(Persist.uid).unread": false])
    }

    static func markChatAsUnread(chat: Chat, uid: String) {
        chatsCollection.document(chat.id)
            .updateData(["\(uid).unread": true])
    }
}
