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
    var title: String? {
        return name
    }
    var subtitle: String? {
        return nil
//        return "\(books) livres"
    }
    let uid: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    var books: Int

    init(uid: String, name: String, coordinate: CLLocationCoordinate2D, books: Int) {
        self.uid = uid
        self.name = name
        self.coordinate = coordinate
        self.books = books

        super.init()
    }
}
