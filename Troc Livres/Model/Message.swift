//
//  Message.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

struct Message {
    let uid: String
    let text: String

    init?(from snapshot: DataSnapshot){
        guard
            let value = snapshot.value as? [String: String],
            let uid = value["uid"],
            let text = value["text"]
            else {
                return nil
        }

        self.uid = uid
        self.text = text
    }
}
