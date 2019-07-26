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

class FirebaseManager {
    
    let db = Firestore.firestore()
    
    var usersCollection: CollectionReference {
        return db.collection("users")
    }
    
    var chatsCollection: CollectionReference {
        return db.collection("chats")
    }
    
    var booksCollection: CollectionReference {
        return db.collection("books")
    }
    
    var wishlistCollection: CollectionReference {
        return usersCollection.document(currentUser.uid).collection("wishlist")
    }
    
    var wishlistCollectionGroup: Query {
        return db.collectionGroup("wishlist")
    }
    
    func getErrorMessage(from error: Error) -> String {
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
}

// MARK: - Account

extension FirebaseManager: AccountManager {

    func signIn(withEmail email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(self.getErrorMessage(from: error))
                return
            }
            Persist.uid = result?.user.uid ?? ""
            self.setToken()
            completion(nil)
        }
    }
    
    func setToken() {
        if let token = Messaging.messaging().fcmToken {
            usersCollection.document(Persist.uid).updateData(["fcmToken": token])
        }
    }
    
    func signOut() {
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
    
    func reauthenticate(withPassword password: String, completion: @escaping (Bool) -> Void) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: password)
        user?.reauthenticate(with: credential, completion: { (result, error) in
            completion(error == nil)
        })
    }
    
    func resetPassword(withEmail email: String, completion: @escaping (String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(self.getErrorMessage(from: error))
            } else {
                completion(nil)
            }
        }
    }
    
    func createAccount(name: String, email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(self.getErrorMessage(from: error))
                return
            }
            Persist.uid = result?.user.uid ?? ""
            Persist.name = name
            self.usersCollection.document(Persist.uid).setData(["name": name])
            completion(nil)
        }
    }
}

// MARK: - User

extension FirebaseManager: UserManager {
    
    func getCurrentUser(completion: @escaping (Bool) -> Void) {
        get(uid: Persist.uid) { user in
            guard let user = user else {
                completion(false)
                return
            }
            currentUser = user
            
            Persist.name = user.name
            Persist.address = user.address ?? ""
            Persist.location = CLLocationCoordinate2D(latitude: user.location?.latitude ?? 0,
                                                      longitude: user.location?.longitude ?? 0)
            completion(true)
        }
    }
    
    // Get a specific user
    func get(uid: String, completion: @escaping (User?) -> Void) {
        usersCollection.document(uid).getDocument { (document, error) in
            guard error == nil else {
                completion(nil)
                return
            }
            if let document = document, document.exists {
                completion(User(from: document))
            }
        }
    }
    
    // Get all the users
    func getAll(completion: @escaping ([User]) -> Void) {
        usersCollection.whereField("numberOfBooks", isGreaterThan: 0).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            var users = [User]()
            snapshot.documents.forEach { document in
                guard currentUser.uid != document.documentID else { return }
                users.append(User(from: document))
            }
            completion(users)
        }
    }
    
    func setLocation(address: String, location: CLLocation, completion: @escaping (Bool) -> Void) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let geoPoint = GeoPoint(latitude: latitude, longitude: longitude)
        let data = ["address": address, "location": geoPoint] as [String : Any]
        usersCollection.document(currentUser.uid).updateData(data) { error in
            completion(error == nil)
        }
    }
    
    func delete(completion: @escaping (Error?) -> Void) {
        deleteBooks { error in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
                return
            }
            self.deleteBooksInWishlists { error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(error)
                    return
                }
                self.deleteAll { error in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(error)
                        return
                    }
                    self.usersCollection.document(currentUser.uid).delete { error in
                        if let error = error {
                            print(error.localizedDescription)
                            completion(error)
                            return
                        }
                        Auth.auth().currentUser?.delete { error in
                            completion(error)
                        }
                    }
                }
            }
        }
        
    }
    
    func deleteBooks(completion: @escaping (Error?) -> Void) {
        getAll(ownedBy: currentUser) { books in
            let batch = self.db.batch()
            books.forEach { book in
                guard let id = book.id else { return }
                let data = ["owners": FieldValue.arrayRemove([currentUser.uid])]
                let document = self.booksCollection.document(id)
                batch.updateData(data, forDocument: document)
            }
            batch.commit { error in
                completion(error)
            }
        }
    }
    
    // Delete the user's books in all the wishlists
    func deleteBooksInWishlists(completion: @escaping (Error?) -> Void) {
        wishlistCollectionGroup.whereField("owner", isEqualTo: currentUser.uid).getDocuments { (snapshot, error) in
            guard error == nil else {
                completion(error)
                return
            }
            if let snapshot = snapshot {
                let batch = self.db.batch()
                for document in snapshot.documents {
                    batch.deleteDocument(document.reference)
                }
                batch.commit { error in
                    completion(error)
                }
            }
        }
    }
}

// MARK: - Book

extension FirebaseManager: BookManager {

    // Update an existing book's owners or create a new entry
    func add(_ book: Book, completion: @escaping (Error?) -> Void) {
        guard let id = book.id else { return }
        
        booksCollection.document(id).getDocument { (document, error) in
            let batch = self.db.batch()
            let bookData: [String : Any]
            if let document = document, document.exists {
                bookData = ["owners": FieldValue.arrayUnion([Persist.uid])]
            } else {
                bookData = ["title": book.title as Any,
                            "authors": book.authors as Any,
                            "description": book.bookDescription as Any,
                            "imageURL": book.imageURL as Any,
                            "language": book.language as Any,
                            "owners": [Persist.uid] as Any]
            }
            batch.setData(bookData, forDocument: self.booksCollection.document(id), merge: true)
            // Add 1 to the number of books
            batch.updateData(["numberOfBooks": FieldValue.increment(Int64(1))],
                             forDocument: self.usersCollection.document(currentUser.uid))
            batch.commit { error in
                completion(error)
            }
        }
    }
    
    func getAll(ownedBy owner: User, completion: @escaping ([Book]) -> Void) {
        booksCollection.whereField("owners", arrayContains: owner.uid).getDocuments { (snapshot, error) in
            guard error == nil, let snapshot = snapshot else { return }
            var books = [Book]()
            for document in snapshot.documents {
                books.append(Book(from: document))
            }
            completion(books)
        }
    }
    
    func remove(_ book: Book, completion: @escaping (Error?) -> Void) {
        guard let id = book.id else { return }
        
        wishlistCollectionGroup.whereField("owner", isEqualTo: currentUser.uid).whereField("bookId", isEqualTo: id)
            .getDocuments { (snapshot, error) in
                guard error == nil else {
                    completion(error)
                    return
                }
                let batch = self.db.batch()
                if let snapshot = snapshot {
                    // Remove the book from the users whislists
                    for document in snapshot.documents {
                        batch.deleteDocument(document.reference)
                    }
                }
                // Remove the user from the book's owners
                batch.updateData(["owners": FieldValue.arrayRemove([Persist.uid])],
                                 forDocument: self.booksCollection.document(id))
                // Substract 1 to the number of books
                batch.updateData(["numberOfBooks": FieldValue.increment(Int64(-1))],
                                 forDocument: self.usersCollection.document(currentUser.uid))
                batch.commit { error in
                    completion(error)
                }
        }
    }
}

// MARK: - Chat

extension FirebaseManager: ChatManager {

    func newChat(with user: User, completion: @escaping (Result<Chat, Error>) -> Void) {
        // Unique chat id between 2 users
        let chatId = currentUser.uid < user.uid ? currentUser.uid + user.uid : user.uid + currentUser.uid
        
        let user1Data = ["name": user.name,
                         "uid": user.uid,
                         "unread": false,
                         "fcmToken": user.fcmToken] as [String : Any]
        let user2Data = ["name": currentUser.name,
                         "uid": currentUser.uid,
                         "unread": true,
                         "fcmToken": Messaging.messaging().fcmToken as Any] as [String : Any]
        let chatData = ["users": [currentUser.uid, user.uid],
                        "timestamp": FieldValue.serverTimestamp(),
                        currentUser.uid: user1Data,
                        user.uid: user2Data] as [String : Any]
        
        chatsCollection.document(chatId).setData(chatData, completion: { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(Chat(id: chatId, with: user)))
            }
        })
    }
    
    // the current user chats
    func getAll(completion: @escaping ([Chat]) -> Void) {
        chatsCollection
            .whereField("users", arrayContains: currentUser.uid)
            .order(by: "timestamp", descending: true)
            .getDocuments { (snapshot, error) in
                var chats = [Chat]()
                if error == nil, let snapshot = snapshot {
                    for document in snapshot.documents {
                        chats.append(Chat(from: document))
                    }
                }
                completion(chats)
        }
    }
    
    static var chatListener: ListenerRegistration!
    
    func getMessages(in chat: Chat, completion: @escaping ([Message]) -> Void) {
        FirebaseManager.chatListener = chatsCollection.document(chat.id).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { (snapshot, error) in
                var messages = [Message]()
                if error == nil, let snapshot = snapshot {
                    for document in snapshot.documents {
                        messages.append(Message(from: document))
                    }
                }
                completion(messages)
        }
    }
    
    static func leaveChat() {
        FirebaseManager.chatListener.remove()
    }
    
    func newMessage(in chat: Chat, content: String, system: Bool, completion: @escaping (Error?) -> Void) {
        let document = chatsCollection.document(chat.id)
        let message = ["content": content,
                       "sender": system ? "system" : Persist.uid,
                       "timestamp": FieldValue.serverTimestamp() as Any]
        let batch = db.batch()
        batch.setData(message, forDocument: document.collection("messages").document())
        
        // mark the chat as unread for the receiver
        batch.updateData(["\(chat.user.uid).unread": true], forDocument: document)
        
        // send notification
        let sender = PushNotificationSender()
        let notificationTitle = system ? "Nouveau troc !" : "Message de \(currentUser.name)"
        sender.sendPushNotification(to: chat.user.fcmToken, title: notificationTitle, body: content)
        
        // if it's an automatic message, mark the chat as unread for the current user
        if system {
            batch.updateData(["\(currentUser.uid).unread": true], forDocument: document)
        }
        
        // update the timestamp in the chat
        batch.updateData(["timestamp": FieldValue.serverTimestamp()], forDocument: document)
        
        batch.commit { error in
            completion(error)
        }
    }
    
    func markAsRead(_ chat: Chat) {
        chatsCollection.document(chat.id).updateData(["\(currentUser.uid).unread": false])
    }
}

// MARK: - Wishlist

extension FirebaseManager: WishManager {

    func getAll(completion: @escaping ([Wish]) -> Void) {
        wishlistCollection.getDocuments { (snapshot, error) in
            var wishes = [Wish]()
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    wishes.append(Wish(from: document))
                }
            }
            completion(wishes)
        }
    }
    
    // If matches are found, return the 1st book
    func getMatch(with user: User, completion: @escaping (Wish?) -> Void) {
        wishlistCollectionGroup
            .whereField("owner", isEqualTo: currentUser.uid)
            .whereField("applicant", isEqualTo: user.uid)
            .order(by: "timestamp")
            .getDocuments { (snapshot, error) in
                if error == nil, let snapshot = snapshot, let document = snapshot.documents.first {
                    completion(Wish(from: document))
                    return
                }
                completion(nil)
        }
    }
    
    func add(_ wish: Wish, completion: @escaping (Error?) -> Void) {
        guard let bookId = wish.book.id else { return }
        let data = ["applicant": currentUser.uid,
                    "owner": wish.owner.uid,
                    "bookTitle": wish.book.title,
                    "bookId": bookId,
                    "timestamp": FieldValue.serverTimestamp()] as [String : Any]
        wishlistCollection.document(wish.owner.uid + bookId).setData(data, completion: { error in
            completion(error)
        })
    }
    
    func delete(_ wish: Wish, completion: @escaping (Error?) -> Void) {
        guard let bookId = wish.book.id else { return }
        wishlistCollection.document(wish.owner.uid + bookId).delete { error in
            completion(error)
        }
    }
    
    func deleteAll(completion: @escaping (Error?) -> Void) {
        wishlistCollection.getDocuments { (snapshot, error) in
            guard error == nil else {
                completion(error)
                return
            }
            if let snapshot = snapshot {
                let batch = self.db.batch()
                for document in snapshot.documents {
                    batch.deleteDocument(document.reference)
                }
                batch.commit { error in
                    completion(error)
                }
            }
        }
    }
}
