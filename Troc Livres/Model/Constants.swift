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
    
    struct Color {
        static let background = UIColor(named: "Color_background")
        static let chatSender = UIColor(named: "Color_chatSender")
        static let chatReceiver = UIColor(named: "Color_chatReceiver")
    }

    struct Firebase {
        static let chatRef = Database.database().reference().child("chats")
        static let userRef = Database.database().reference().child("users")
        static let imageRef = Storage.storage().reference()
    }

    struct Params {
        static let initialDistance = 15
    }
}

struct Session {
    static var user: User!
}
