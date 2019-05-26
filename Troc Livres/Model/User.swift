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
    var latitude: Double
    var longitude: Double
    var books: [Book]

    init(uid: String, name: String, latitude: Double, longitude: Double, books: [Book]) {
        self.uid = uid
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.books = books

        super.init()
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
    }

    func delete() {
        Constants.Firebase.userRef.child(uid).removeValue()
    }

    static func logout() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
