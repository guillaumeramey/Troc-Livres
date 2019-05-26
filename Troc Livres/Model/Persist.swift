//
//  Persist.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation

struct Persist {

    private struct Keys {
        static let userUID = "TrocLivresDistance"
    }

    static var distance: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.userUID)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.userUID)
        }
    }
}
