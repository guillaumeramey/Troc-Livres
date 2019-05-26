//
//  UserManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

struct UserManager {

    // Get a user books
    static func getBooks(from snapshot: DataSnapshot) -> [Book] {
        var books = [Book]()
        for child in snapshot.childSnapshot(forPath: "books").children {
            let book = child as! DataSnapshot
            let key = book.key
            let bookValue = book.value as! [String: String]
            if let title = bookValue["title"],
                let author = bookValue["author"],
                let condition = bookValue["condition"] {
                books.append(Book(key: key, title: title, author: author, condition: condition))
            }
        }
        return books
    }

    // Get the current user details
    static func getUser(_ requestedUid: String, completion: @escaping (_ user: User) -> ()) {
        var user: User!

        Constants.Firebase.userRef.child(requestedUid).observeSingleEvent(of: .value, with: { snapshot in
            let uid = snapshot.key
            let userValue = snapshot.value as! [String: AnyObject]

            if let name = userValue["name"] as? String,
                let latitude = userValue["latitude"] as? Double,
                let longitude = userValue["longitude"] as? Double {
                let books = getBooks(from: snapshot)
                user = User(uid: uid, name: name, latitude: latitude, longitude: longitude, books: books)
            }
            completion(user)
        })
    }

    // Get all users (except the current user) with at least 1 book
    static func getAllUsers(completion: @escaping (_ user: [User]?) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { fatalError() }

        var users = [User]()

        Constants.Firebase.userRef.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let user = child as! DataSnapshot
                let uid = user.key
                let value = user.value as! [String: AnyObject]
                let books = getBooks(from: snapshot.childSnapshot(forPath: uid))

                if uid != currentUid && books.count > 0 {
                    if let name = value["name"] as? String,
                        let latitude = value["latitude"] as? Double,
                        let longitude = value["longitude"] as? Double {
                        users.append(User(uid: uid, name: name, latitude: latitude, longitude: longitude, books: books))
                    }
                }
            }
            completion(users)
        })
    }
}
