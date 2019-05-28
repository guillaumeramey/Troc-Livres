//
//  Contact.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 27/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

struct Contact {
    let chatKey: String
    let name: String

    init(chatKey: String, name: String) {
        self.chatKey = chatKey
        self.name = name
    }

    init?(from snapshot: DataSnapshot){
        chatKey = snapshot.key
        name = snapshot.value as! String
    }
}
