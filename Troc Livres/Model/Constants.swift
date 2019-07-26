//
//  Constants.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 18/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

var currentUser = User(uid: "", name: "", fcmToken: "")

struct Constants {
    
    struct Cell {
        static let book = "BookCell"
        static let chat = "ChatCell"
        static let message = "MessageCell"
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
        static let location = UIImage(named: "Image-Location")!
        static let lock = UIImage(named: "Image-Lock")!
        static let noBookCover = UIImage(named: "Image-NoBookCover")!
        static let person = UIImage(named: "Image-Person")!
        static let star = UIImage(named: "Image-Star")!
        static let starFill = UIImage(named: "Image-StarFill")!
    }

    struct Segue {
        static let bookVC = "BookVC"
        static let chatVC = "ChatVC"
        static let userBooksVC = "UserBooksVC"
        static let scannerVC = "ScannerVC"
        static let searchBookVC = "SearchBookVC"
        static let changeLocationVC = "ChangeLocationVC"
    }

    // Get the API key from plist file
    static func valueForAPIKey(_ keyname: String) -> String {
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
        }
        return nsDictionary?.object(forKey: keyname) as! String
    }
}
