//
//  WishManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation

protocol WishManager {
    func getMatch(with user: User, completion: @escaping (Wish?) -> Void)
    func add(_ wish: Wish, completion: @escaping (Error?) -> Void)
    func getAll(completion: @escaping ([Wish]) -> Void)
    func delete(_ wish: Wish, completion: @escaping (Error?) -> Void)
    func deleteAll(completion: @escaping (Error?) -> Void)
}

protocol WishManagerInjectable {
    var wishManager: WishManager { get }
}

extension WishManagerInjectable {
    var wishManager: WishManager {
        return FirebaseManager()
    }
}
