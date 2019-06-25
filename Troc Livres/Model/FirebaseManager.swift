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
import Geofirestore

struct FirebaseManager {

//    static let shared = FirebaseManager()
//
//    private init() {}

    static var currentUser: Firebase.User!
    static let db = Firestore.firestore()
    static let usersCollection = db.collection("users")
    static let chatsCollection = db.collection("chats")
    static let booksCollection = db.collection("books")
    static let geoFirestore = GeoFirestore(collectionRef: usersCollection)

    // MARK: - Authentication

    static func signIn(withEmail email: String, password: String, completion: @escaping (String?) -> Void ) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
//                print(errorCode.rawValue)
                let errorMessage: String
                switch errorCode {
                case .invalidEmail:
                    errorMessage = "E-mail invalide"
                case .networkError:
                    errorMessage = "Problème de connexion"
                case .wrongPassword:
                    errorMessage = "Mot de passe incorrect"
                case .userNotFound:
                    errorMessage = "Utilisateur introuvable"
                default:
                    errorMessage = error.localizedDescription
                }
                completion(errorMessage)
            } else {
                FirebaseManager.currentUser = result?.user
                completion(nil)
            }

        }
    }

    static func signOut() {
        currentUser = nil
        Session.user = nil
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - User management

    static func createUser(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                //                    print(errorCode.rawValue)
                let errorMessage: String
                switch errorCode {
                case .invalidEmail:
                    errorMessage = "E-mail invalide"
                case .emailAlreadyInUse:
                    errorMessage = "E-mail déjà utilisé"
                default:
                    errorMessage = error.localizedDescription
                }
                completion(errorMessage)
            } else {
                FirebaseManager.currentUser = user?.user
                completion(nil)
            }
        }
    }

    // Get a specific user
    static func getUser(withUid uid: String = currentUser.uid, completion: @escaping (User?) -> Void) {
        usersCollection.document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                completion(User(from: document))
            }
        }
    }

    // Get the users within a radius around a location
    static func getUsers(center: CLLocationCoordinate2D, radius: Double, completion: @escaping ([User]) -> Void) {
        let earthRadius: Double = 6371

        let deltaLatitude = radius / ((2 * Double.pi / 360) * earthRadius)
        let minLatitude = center.latitude - deltaLatitude
        let maxLatitude = center.latitude + deltaLatitude

        let deltaLongitude = radius / ((2 * Double.pi / 360) * earthRadius * __cospi(center.latitude / 180))
        let minLongitude = center.longitude - deltaLongitude
        let maxLongitude = center.longitude + deltaLongitude

        let swGeohash = Geohash.encode(latitude: minLatitude, longitude: minLongitude, length: 10)
        let neGeohash = Geohash.encode(latitude: maxLatitude, longitude: maxLongitude, length: 10)

        print("swGeohash = " + swGeohash)
        print("neGeohash = " + neGeohash)
        
        usersCollection
            .whereField("geohash", isLessThan: neGeohash)
            .whereField("geohash", isGreaterThan: swGeohash)
            .getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                var users = [User]()
                for document in snapshot.documents {
                    // display other users with at least 1 book
                    let numberOfBooks = document.get("numberOfBooks") as? Int ?? 0
                    if currentUser.uid != document.documentID && numberOfBooks > 0 {
                        let user = User(from: document)
                        print("user geohash = " + user.geohash!)
                        users.append(user)
                    }
                }
                completion(users)
        }
    }

    static func setUserName(_ name: String, completion: @escaping (Bool) -> Void) {
        let userData = ["name": name, "address": "Non défini", "numberOfBooks": 0] as [String : Any]
        usersCollection.document(currentUser.uid).setData(userData) { error in
            completion(error == nil)
        }
    }

    static func setUserLocation(_ geoPoint: GeoPoint, completion: @escaping (Result<Bool, Error>) -> Void) {
        geoFirestore.setLocation(geopoint: geoPoint, forDocumentWithID: currentUser.uid) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    static func deleteUser(completion: @escaping (Result<Bool, Error>) -> Void) {
        //        userRef.child(currentUser.uid).removeValue()
        //        Auth.auth().currentUser?.delete { error in
        //            if let error = error {
        //                completion(.failure(error))
        //            } else {
        //                completion(.success(true))
        //            }
        //        }
    }

    // MARK: - Book management

    static func addBook(_ book: Book, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let id = book.id else { return }

        booksCollection.document(id).getDocument { (document, error) in
            if let document = document, document.exists {
                // update owners
                let bookData = ["owners": FieldValue.arrayUnion([Session.user.uid])]
                booksCollection.document(id).updateData(bookData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // Add 1 to the number of books
                        usersCollection.document(currentUser.uid).updateData(["numberOfBooks": FieldValue.increment(Int64(1))])
                        completion(.success(true))
                    }
                }
            } else {
                // Create book
                let bookData = ["title": book.title as Any,
                                "authors": book.authors as Any,
                                "description": book.bookDescription as Any,
                                "imageURL": book.imageURL as Any,
                                "language": book.language as Any,
                                "owners": [Session.user.uid] as Any]
                booksCollection.document(id).setData(bookData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // Add 1 to the number of books
                        usersCollection.document(currentUser.uid).updateData(["numberOfBooks": FieldValue.increment(Int64(1))])
                        completion(.success(true))
                    }
                }
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
        let bookData = ["owners": FieldValue.arrayRemove([Session.user.uid])]
        booksCollection.document(id).updateData(bookData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Substract 1 to the number of books
                usersCollection.document(currentUser.uid).updateData(["numberOfBooks": FieldValue.increment(Int64(-1))])
                completion(.success(true))
            }
        }
    }

    // MARK: - Wishes management

    // If matches are found, return the 1st book
    static func getMatches(uid: String, completion: @escaping (String) -> Void) {
        db.collectionGroup("wishlist")
            .whereField("owner", isEqualTo: currentUser.uid)
            .whereField("applicant", isEqualTo: uid)
            .order(by: "timestamp")
            .getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                completion(snapshot.documents.first?.get("bookTitle") as? String ?? "")
        }
    }

    static func addBookToWishlist(uid: String, _ book: Book) {
        guard let id = book.id, let title = book.title else { return }
        let data = ["applicant": currentUser.uid,
                    "owner": uid,
                    "bookTitle": title,
                    "bookId": id,
                    "timestamp": FieldValue.serverTimestamp()] as [String : Any]
        usersCollection.document(currentUser.uid).collection("wishlist").document(uid + id).setData(data)
    }

    static func removeBookFromWishlist(uid: String, _ book: Book) {
        guard let id = book.id else { return }
        usersCollection.document(currentUser.uid).collection("wishlist").document(uid + id).delete()
    }

    // MARK: - Chat management

    private static func createChat(id: String, with user: User, completion: @escaping (Result<Chat, Error>) -> Void) {
        let chatData = [
            "users": [currentUser.uid, user.uid],
            currentUser.uid: ["name": user.name, "uid": user.uid, "unread": false] as [String : Any],
            user.uid: ["name": Session.user.name, "uid": currentUser.uid, "unread": true] as [String : Any]
            ] as [String : Any]
        chatsCollection.document(id).setData(chatData, completion: { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(Chat(id: id, with: user)))
            }
        })
    }

    // the current user chats
    static func getUserChats(completion: @escaping ([Chat]) -> Void) {
        chatsCollection.whereField("users", arrayContains: currentUser.uid).getDocuments { (snapshot, error) in
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
        let chatId = currentUser.uid < user.uid ? currentUser.uid + user.uid : user.uid + currentUser.uid

        chatsCollection.document(chatId).getDocument { (document, error) in
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
        chatListener = chatsCollection.document(chat.id).collection("messages").order(by: "timestamp").addSnapshotListener { (snapshot, error) in
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

    static func sendMessage(in chat: Chat, content: String) {
        let messageData = ["content": content,
                           "sender": currentUser.uid,
                           "timestamp": FieldValue.serverTimestamp() as Any]

        chatsCollection.document(chat.id).collection("messages").addDocument(data: messageData)
        markChatAsUnread(chat: chat)
    }

    static func markChatAsRead(id: String) {
        chatsCollection.document(id).updateData(["\(currentUser.uid).unread": false])
    }

    static func markChatAsUnread(chat: Chat) {
        chatsCollection.document(chat.id).updateData(["\(chat.uid).unread": true])
    }
}
