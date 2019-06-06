//
//  Constants.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 18/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

struct Constants {

    static func chatKey(uid1: String, uid2: String) -> String {
            return uid1 < uid2 ? uid1 + uid2 : uid2 + uid1
    }

    struct Font {
        static let button = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }

    struct Image {
        static let eyeShow = UIImage(named: "Image-EyeShow")
        static let eyeHide = UIImage(named: "Image-EyeHide")
    }
    
    struct Color {
        static let background = UIColor(named: "Color-Background")
        static let chatSender = UIColor(named: "Color-ChatSender")
        static let chatReceiver = UIColor(named: "Color-ChatReceiver")
        static let button = UIColor(named: "Color-Button")
    }

    struct Firebase {
    }
}
