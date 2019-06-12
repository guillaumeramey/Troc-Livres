//
//  Constants.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 18/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

struct Constants {

    static func chatKey(uid1: String, uid2: String) -> String {
            return uid1 < uid2 ? uid1 + uid2 : uid2 + uid1
    }

    struct Font {
        static let button = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }

    struct Image {
        static let eyeShow = UIImage(named: "Image-EyeShow")!
        static let eyeHide = UIImage(named: "Image-EyeHide")!
        static let envelope = UIImage(named: "Image-Envelope")!
        static let userIcon = UIImage(named: "Image-UserIcon")!
        static let lock = UIImage(named: "Image-Lock")!
        static let noBookCover = UIImage(named: "Image-NoBookCover")!
    }
    
    struct Color {
        static let background = UIColor(named: "Color-Background")!
        static let chatSender = UIColor(named: "Color-ChatSender")!
        static let chatReceiver = UIColor(named: "Color-ChatReceiver")!
        static let button = UIColor(named: "Color-Button")!
    }

    // Wrapper for obtaining keys from keys.plist
    static func valueForAPIKey(_ keyname: String) -> String {
        // Get the file path for keys.plist
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")

        // Put the keys in a dictionary
        let plist = NSDictionary(contentsOfFile: filePath!)

        // Pull the value for the key
        let value: String = plist?.object(forKey: keyname) as! String

        return value
    }
}
