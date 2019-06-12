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
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }

        uid = snapshot.key
        self.name = value["name"] as! String
        self.address = value["address"] as? String
        self.latitude = value["latitude"] as? Double
        self.longitude = value["longitude"] as? Double

        // Get the user books
        for snapshotChild in snapshot.childSnapshot(forPath: "books").children {
            if let book = Book(from: snapshotChild as! DataSnapshot) {
                books.append(book)
            }
        }
        books.sort(by: { $0.title! < $1.title! })
    }

    // MKAnnotation properties
    var title: String? {
        return name
    }
    var subtitle: String? {
        return "\(books.count) livre" + (books.count > 1 ? "s" : "")
    }
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
    }

    // Methods
    func deleteBook(key: String?) {
        guard let key = key else { return }
        FirebaseManager.deleteBook(withKey: key)
        books.removeAll(where: { $0.id == key })
    }
}
