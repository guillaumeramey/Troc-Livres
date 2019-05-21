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

struct User: Codable {
    let uid: String
    let name: String
    let latitude: Double
    let longitude: Double
    let books: [Book]
}

class UserPin: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate

        super.init()
    }
}
//    static var all: [User] {
//        let allUsers = [User]()
//        let db = Database.database().reference()
//
//        db.observeSingleEvent(of: .childAdded) { (snapshot) in
//            guard let users = snapshot.value as? NSDictionary else { return }
//            print(users)
//        }
//        return allUsers
//    }
//
//    private var userBooks = [Book]()
//
//    var subtitle: String? {
//        return "\(userBooks.count) livres"
//    }
//
//    func getBooks() -> [Book] {
//        guard let userUID = Auth.auth().currentUser?.uid else { return userBooks }
//        let booksDB = Database.database().reference().child("users/\(userUID)/books")
//
//        booksDB.observe(.childAdded) { (snapshot) in
//            let snapshotValue = snapshot.value as! Dictionary<String, String>
//
//            let title = snapshotValue["title"]!
//            let author = snapshotValue["author"]!
//            let book = Book(title: title, author: author)
//
//            self.userBooks.append(book)
//        }
//        return userBooks
//    }
}
