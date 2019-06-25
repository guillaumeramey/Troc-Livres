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
import CoreLocation

class User: NSObject, MKAnnotation {
    let uid: String
    var name: String
    var numberOfBooks: Int?
    var books = [Book]()
    var contacts = [Chat]()
    var address: String?
    var geohash: String?

    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }

    init(from document: DocumentSnapshot) {
        self.uid = document.documentID
        self.name = document.get("name") as? String ?? ""
        self.numberOfBooks = document.get("numberOfBooks") as? Int
        self.address = document.get("address") as? String
        self.geohash = document.get("geohash") as? String
    }

    // MKAnnotation properties
    var title: String? {
        return name
    }
    var subtitle: String? {
        if let numberOfBooks = numberOfBooks {
            return "\(numberOfBooks) livre" + (numberOfBooks > 1 ? "s" : "")
        }
        return nil
    }
    var coordinate: CLLocationCoordinate2D {
        if let geohash = geohash {
            return CLLocationCoordinate2D.init(geohash: geohash)
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}
