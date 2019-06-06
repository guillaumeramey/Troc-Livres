//
//  FirebaseManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 05/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseManager {

//    static let shared = FirebaseManager()
//
//    private init() {}

    static var currentUser: Firebase.User!
    static let userRef = Database.database().reference().child("users")
    static let chatRef = Database.database().reference().child("chats")
    static let imageRef = Storage.storage().reference().child("images")

    static func logIn(withEmail email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void ) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                FirebaseManager.currentUser = result?.user
                completion(.success(true))
            }
        }
    }

    static func logOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            Session.user = nil
        }
        catch {
            print(error.localizedDescription)
        }
    }

    static func getCurrentUserData(completion: @escaping (Bool) -> Void) {
        userRef.child(currentUser.uid).observeSingleEvent(of: .value, with: { snapshot in
            if let user = User(from: snapshot) {
                Session.user = user
                completion(true)
            } else {
                completion(false)
            }
        })
    }

    static func deleteCurrentUser(completion: @escaping (Result<Bool, Error>) -> Void) {
        userRef.child(currentUser.uid).removeValue()

        Auth.auth().currentUser?.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    static func addBook(_ book: [String: String], completion: @escaping (Result<String, Error>) -> Void) {
        let bookRef = userRef.child("\(currentUser.uid)/books").childByAutoId()
        bookRef.setValue(book) { (error, reference) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(bookRef.key!))
            }
        }
    }

    static func deleteBook(withKey key: String) {
        userRef.child("\(currentUser.uid)/books/\(key)").removeValue()
    }


    static func setUsername(_ name: String, completion: @escaping (Bool) -> Void) {
        userRef.child("\(currentUser.uid)/name").setValue(name) { (error, reference) in
            completion(error != nil)
        }
    }

    static func setUserLocation(_ userLocation: [String: Any], completion: @escaping (Bool) -> Void) {
        userRef.child("\(currentUser.uid)").updateChildValues(userLocation) { (error, reference) in
            completion(error != nil)
        }
    }

    static func getUsers(completion: @escaping ([User]) -> Void) {
        var users = [User]()
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            for snapshotChild in snapshot.children {
                if let user = User(from: snapshotChild as! DataSnapshot) {
                    if user.books.count > 0 && user.uid != Session.user.uid {
                        users.append(user)
                    }
                }
            }
            completion(users)
        })
    }

    static func getChat(withUid uid: String, completion: @escaping ([Message]) -> Void) {
        var messages = [Message]()
        let chatKey = Constants.chatKey(uid1: currentUser.uid, uid2: uid)
        chatRef.child(chatKey).observe(.childAdded) { snapshot in
            if let message = Message(from: snapshot) {
                messages.append(message)
            }
            completion(messages)
        }
    }

    static func getContacts(completion: @escaping ([Contact]) -> Void) {
        var contacts = [Contact]()
        userRef.child("\(currentUser.uid)/contacts").queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { snapshot in
            for contactSnapshot in snapshot.children {
                if let contact = Contact(from: contactSnapshot as! DataSnapshot) {
                    contacts.insert(contact, at: 0)
                }
            }
            completion(contacts)
        }
    }
}
