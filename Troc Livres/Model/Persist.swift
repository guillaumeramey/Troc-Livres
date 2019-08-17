//
//  Persist.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import CoreLocation

struct Persist {

    private static let defaults = UserDefaults.standard
    
    private struct Keys {
        static let uid = "TrocLivresUID"
        static let name = "TrocLivresName"
        static let address = "TrocLivresAddress"
        static let latitude = "TrocLivresLatitude"
        static let longitude = "TrocLivresLongitude"
    }

    static var uid: String {
        get {
            return defaults.string(forKey: Keys.uid) ?? ""
        }
        set {
            defaults.set(newValue, forKey: Keys.uid)
        }
    }
    
    static var name: String {
        get {
            return defaults.string(forKey: Keys.name) ?? ""
        }
        set {
            defaults.set(newValue, forKey: Keys.name)
        }
    }
    
    static var address: String {
        get {
            return defaults.string(forKey: Keys.address) ?? ""
        }
        set {
            defaults.set(newValue, forKey: Keys.address)
        }
    }
    
    static var location: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: defaults.double(forKey: Keys.latitude),
                                          longitude: defaults.double(forKey: Keys.longitude))
        }
        set {
            defaults.set(newValue.latitude, forKey: Keys.latitude)
            defaults.set(newValue.longitude, forKey: Keys.longitude)
        }
    }
}
