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
    let id: String?
    var volumeInfo: Book
}

struct Book: Decodable {
    var id: String?
    let title: String?
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


    init?(from snapshot: DataSnapshot){
        guard let value = snapshot.value as? [String: Any] else { return nil }

        self.id = snapshot.key
        self.title = value["title"] as? String
        self.authors = (value["authors"] as? String)?.components(separatedBy: "&&&")
        self.bookDescription = value["bookDescription"] as? String
        self.imageLinks = ImageLinks(thumbnail: value["imageURL"] as? String)
        self.language = value["language"] as? String
    }
}
