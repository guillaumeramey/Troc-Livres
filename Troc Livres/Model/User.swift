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
    var name: String
    var books = [Book]()
    var contacts = [Contact]()
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var imageRef: StorageReference {
        return FirebaseManager.imageRef.child("users/\(uid).jpg")
    }

    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }

    init?(from snapshot: DataSnapshot){
        guard
            let value = snapshot.value as? [String: Any],
            let name = value["name"] as? String
            else {
                return nil
            }

        uid = snapshot.key
        self.name = name
        self.address = value["address"] as? String
        self.latitude = value["latitude"] as? Double
        self.longitude = value["longitude"] as? Double

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
    }

    // MKAnnotation properties
    var title: String? {
        return name
    }
    var subtitle: String? {
        return "\(books.count) livre" + (books.count > 1 ? "s" : "")
    }
    var coordinate: CLLocationCoordinate2D {
        #warning("optionals")
        return CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
    }

    // Methods
    func deleteBook(key: String) {
        FirebaseManager.deleteBook(withKey: key)
        books.removeAll(where: { $0.key == key })
    }

//    func delete() {
////        Session.user = nil
//        Constants.Firebase.userRef.child(uid).removeValue()
//    }
}
