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
        //        static let button = UIColor.systemTeal
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
        static let noUserImage = UIImage(named: "Image-NoUserImage")!
        static let starFalse = UIImage(named: "Image-StarFalse")!
        static let starTrue = UIImage(named: "Image-StarTrue")!
    }

    struct Segue {
        static let bookVC = "BookViewController"
        static let chatVC = "ChatViewController"
        static let userTableVC = "UserTableViewController"
        static let scannerVC = "ScannerViewController"
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
