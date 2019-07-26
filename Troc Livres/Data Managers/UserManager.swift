//
//  UserManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import CoreLocation

protocol UserManager {
    func getCurrentUser(completion: @escaping (Bool) -> Void)
    func get(uid: String, completion: @escaping (User?) -> Void)
    func getAll(completion: @escaping ([User]) -> Void)
    func setLocation(address: String, location: CLLocation, completion: @escaping (Bool) -> Void)
    func delete(completion: @escaping (Error?) -> Void)
    func deleteBooks(completion: @escaping (Error?) -> Void)
    func deleteBooksInWishlists(completion: @escaping (Error?) -> Void)
}

protocol UserManagerInjectable {
    var userManager: UserManager { get }
}

extension UserManagerInjectable {
    var userManager: UserManager {
        return FirebaseManager()
    }
}
