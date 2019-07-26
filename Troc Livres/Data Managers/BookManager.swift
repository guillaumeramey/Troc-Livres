//
//  BookManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation

protocol BookManager {
    func add(_ book: Book, completion: @escaping (Error?) -> Void)
    func getAll(ownedBy owner: User, completion: @escaping ([Book]) -> Void)
    func remove(_ book: Book, completion: @escaping (Error?) -> Void)
}

protocol BookManagerInjectable {
    var bookManager: BookManager { get }
}

extension BookManagerInjectable {
    var bookManager: BookManager {
        return FirebaseManager()
    }
}
