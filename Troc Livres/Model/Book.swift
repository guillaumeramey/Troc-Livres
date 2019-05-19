//
//  Book.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 15/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import MapKit

class Book: NSObject, MKAnnotation {
    var title: String?
    var author: String
    var coordinate: CLLocationCoordinate2D

    init(title: String, author: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.author = author
        self.coordinate = coordinate

        super.init()
    }

    var subtitle: String? {
        return author
    }
}
