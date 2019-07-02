//
//  Constants.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 18/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

struct Constants {

    struct Cell {
        static let book = "BookViewCell"
        static let message = "MessageViewCell"
    }

    struct Color {
        static let lightGray = UIColor(named: "Color-LightGray")!
        static let chatSender = UIColor(named: "Color-ChatSender")!
        static let chatReceiver = UIColor(named: "Color-ChatReceiver")!
        static let button = UIColor(named: "Color-Button")!
    }

    struct Image {
        static let eyeShow = UIImage(named: "Image-Eye")!
        static let eyeHide = UIImage(named: "Image-EyeSlash")!
        static let envelope = UIImage(named: "Image-Envelope")!
        static let person = UIImage(named: "Image-Person")!
        static let lock = UIImage(named: "Image-Lock")!
        static let noBookCover = UIImage(named: "Image-NoBookCover")!
        static let star = UIImage(named: "Image-Star")!
        static let starFill = UIImage(named: "Image-StarFill")!
    }

    struct Segue {
        static let bookVC = "BookVC"
        static let chatVC = "ChatVC"
        static let userVC = "UserVC"
        static let scannerVC = "ScannerVC"
        static let searchBookVC = "SearchBookVC"
        static let changeLocationVC = "ChangeLocationVC"
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
