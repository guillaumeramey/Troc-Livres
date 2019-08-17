//
//  PassThroughView.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 07/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import MapKit

// Allow the user to tap through the map
class PassThroughView: MKMapView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
