//
//  Book.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 15/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

//enum Category: String {
//    case novel = "Roman"
//    case kids = "Pour enfants"
//    case fantasy = "Fantasy"
//    case detectiveStory = "Policier"
//}

struct Book {
    let key: String
    var title: String
    var author: String
    var condition: String

    init?(from snapshot: DataSnapshot){
        guard
            let value = snapshot.value as? [String: String],
            let title = value["title"],
            let author = value["author"],
            let condition = value["condition"]
            else {
                return nil
        }

        self.key = snapshot.key
        self.title = title
        self.author = author
        self.condition = condition
    }
}
