//
//  User.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 19/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import MapKit
import Firebase

class User: NSObject, MKAnnotation {
    let uid: String
    let name: String
    var coordinate: CLLocationCoordinate2D

    init(uid: String, name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.uid = uid
        self.coordinate = coordinate

        super.init()
    }

    var title: String? {
        return name
    }

    static var all: [User] {
        let allUsers = [User]()
        let db = Database.database().reference()

        db.observeSingleEvent(of: .childAdded) { (snapshot) in
            guard let users = snapshot.value as? NSDictionary else { return }
            print(users)
        }

        // Get users
//        db.child("users").observeSingleEvent(of: .childAdded) { (snapshot) in
//            guard let users = snapshot.value as? NSDictionary else { return }
//            let name = users["name"] as! String
//            let coordinate = users["coordinate"]
//
//            print(name)
//            print(coordinate)
//        }

        return allUsers

//        let userID = Auth.auth().currentUser?.uid
//        db.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//            let username = value?["username"] as? String ?? ""
//            let user = User(username: username)
//
//            // ...
//        }) { (error) in
//            print(error.localizedDescription)
//        }

    }

    private var userBooks = [Book]()

    var subtitle: String? {
        return "\(userBooks.count) livres"
    }

    func getBooks() -> [Book] {
        guard let userUID = Auth.auth().currentUser?.uid else { return userBooks }
        let booksDB = Database.database().reference().child("users/\(userUID)/books")

        booksDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>

            let title = snapshotValue["title"]!
            let author = snapshotValue["author"]!
            let book = Book(title: title, author: author)

            self.userBooks.append(book)
        }
        return userBooks
    }
}
