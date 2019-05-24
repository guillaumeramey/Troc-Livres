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
    var numberOfBooks: Int

    init(uid: String, name: String, latitude: Double, longitude: Double, numberOfBooks: Int) {
        self.uid = uid
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.numberOfBooks = numberOfBooks

        super.init()
    }

    // MKAnnotation variables
    var title: String? {
        return name
    }
    var subtitle: String? {
        return "\(numberOfBooks) livre" + (numberOfBooks > 1 ? "s" : "")
    }
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
