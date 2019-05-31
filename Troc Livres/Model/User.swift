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
    var latitude: Double
    var longitude: Double
    var books = [Book]()
    var contacts = [Contact]()
    let imageRef: StorageReference

    init?(from snapshot: DataSnapshot){
        guard
            let value = snapshot.value as? [String: Any],
            let name = value["name"] as? String,
            let latitude = value["latitude"] as? Double,
            let longitude = value["longitude"] as? Double
            else {
                return nil
            }

        uid = snapshot.key
        self.name = name
        self.latitude = latitude
        self.longitude = longitude

        // Get the user books
        for snapshotChild in snapshot.childSnapshot(forPath: "books").children {
            if let book = Book(from: snapshotChild as! DataSnapshot) {
                books.append(book)
            }
        }

        // Get the current user contacts
        if let currentUid = Auth.auth().currentUser?.uid, uid == currentUid {
//            for snapshotChild in snapshot.childSnapshot(forPath: "contacts").children {
//                if let contact = Contact(from: snapshotChild as! DataSnapshot) {
//                    contacts.append(contact)
//                }
//            }
        }

        imageRef = Constants.Firebase.imageRef.child("images/\(uid).jpg")
    }

    // MKAnnotation properties
    var title: String? {
        return name
    }
    var subtitle: String? {
        return "\(books.count) livre" + (books.count > 1 ? "s" : "")
    }
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // Methods
    func deleteBook(key: String) {
        Constants.Firebase.userRef.child("\(uid)/books/\(key)").removeValue()
        books.removeAll(where: { $0.key == key })
    }

    func delete() {
        Session.user = nil
        Constants.Firebase.userRef.child(uid).removeValue()
    }

    static func logout() {
        do {
            try Auth.auth().signOut()
            Session.user = nil
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
