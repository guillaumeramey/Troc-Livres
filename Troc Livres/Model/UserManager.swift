//
//  UserManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

struct UserManager {

    // Get the current user
    static func getSessionUser(_ uid: String, completion: @escaping (_ success: Bool) -> Void) {
        Constants.Firebase.userRef.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            guard let user = User(from: snapshot) else { return }
            Session.user = user
            completion(true)
        })
    }

    // Get all users (except the current user) with at least 1 book
    static func getAllUsers(completion: @escaping (_ user: [User]) -> Void) {
        var users = [User]()
        Constants.Firebase.userRef.observeSingleEvent(of: .value, with: { snapshot in
            for snapshotChild in snapshot.children {
                if let user = User(from: snapshotChild as! DataSnapshot) {
                    if user.books.count > 0 && user.uid != Session.user.uid {
                        users.append(user)
                    }
                }
            }
            completion(users)
        })
    }
}

