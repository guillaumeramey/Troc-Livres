//
//  Wish.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 24/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

struct Wish: Equatable {
    let owner: User
    let book: Book
    
    static func == (lhs: Wish, rhs: Wish) -> Bool {
        return lhs.book.id == rhs.book.id && lhs.owner.uid == rhs.owner.uid
    }
    
    init(owner: User, book: Book) {
        self.owner = owner
        self.book = book
    }
    
    init(from document: DocumentSnapshot) {
        let owner = document.get("owner") as? String
        let bookId = document.get("bookId") as? String
        let bookTitle = document.get("bookTitle") as? String
        
        self.owner = User(uid: owner ?? "", name: "", fcmToken: "")
        self.book = Book(id: bookId ?? "", title: bookTitle ?? "")
    }
}
