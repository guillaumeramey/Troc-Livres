//
//  DataMock.swift
//  Troc LivresTests
//
//  Created by Guillaume Ramey on 31/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation

@testable import Troc_Livres

var user1 = User(uid: "uid1", name: "username1", fcmToken: "token1")
var user2 = User(uid: "uid2", name: "username2", fcmToken: "token2")

let chat1 = Chat(with: user1)
let chat2 = Chat(with: user2)

let message1 = Message(content: "message1", sender: "uid1")
let message2 = Message(content: "message2", sender: "uid2")

let book1 = Book(id: "idbook1", title: "Book 1")
let book2 = Book(id: "idbook2", title: "Book 2")

let wish1 = Wish(owner: user2, book: book1)
let wish2 = Wish(owner: user2, book: book2)
