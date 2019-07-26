//
//  Book.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 15/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

struct BookJSON: Decodable {
    let items: [Item]
}

struct Item: Decodable {
    let id: String
    var volumeInfo: Book
}

struct Book: Decodable, Equatable, DataManagerInjectable {
    var id: String?
    let title: String
    let authors: [String]?
    let bookDescription: String?
    let imageLinks: ImageLinks?
    let language: String?

    var imageURL: String? {
        return imageLinks?.thumbnail?.replacingOccurrences(of: "&zoom=1", with: "")
    }

    enum CodingKeys: String, CodingKey {
        case id, title, authors
        case bookDescription = "description"
        case imageLinks, language
    }

    struct ImageLinks: Decodable {
        let thumbnail: String?
    }
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
        authors = nil
        bookDescription = nil
        imageLinks = nil
        language = nil
    }

    init(from document: DocumentSnapshot) {
        self.id = document.documentID
        self.title = document.get("title") as? String ?? ""
        self.authors = document.get("authors") as? [String]
        self.bookDescription = document.get("description") as? String
        self.imageLinks = ImageLinks(thumbnail: document.get("imageURL") as? String)
        self.language = document.get("language")  as? String
    }
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id
    }
    
}
