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

    // Get the current user details
    static func getUser(_ requestedUid: String, completion: @escaping (_ user: User) -> ()) {
        var user: User!
        let userQuery = Constants.Firebase.userRef.child(requestedUid)

        userQuery.observeSingleEvent(of: .value, with: { snapshot in
            let uid = snapshot.key
            let value = snapshot.value as! [String: AnyObject]

            if let name = value["name"] as? String,
                let latitude = value["latitude"] as? Double,
                let longitude = value["longitude"] as? Double,
                let numberOfBooks = value["numberOfBooks"] as? Int {
                user = User(uid: uid, name: name, latitude: latitude, longitude: longitude, numberOfBooks: numberOfBooks)
            }
            completion(user)
        })
    }

    // Get all users (except the current user) with at least 1 book
    static func getAllUsers(completion: @escaping (_ user: [User]?) -> ()) {
        var users = [User]()
        let userQuery = Constants.Firebase.userRef

        userQuery.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let user = (child as! DataSnapshot)
                let uid = user.key
                let value = user.value as! [String: AnyObject]

                if let numberOfBooks = value["numberOfBooks"] as? Int, numberOfBooks > 0 {
                    if uid != Constants.currentUid {
                        if let name = value["name"] as? String,
                            let latitude = value["latitude"] as? Double,
                            let longitude = value["longitude"] as? Double {
                            users.append(User(uid: uid, name: name, latitude: latitude, longitude: longitude, numberOfBooks: numberOfBooks))
                        }
                    }
                }
            }
            completion(users)
        })
    }

    enum BookCounterAction {
        case add, remove
    }

    static func modifyNumberOfBooks(_ action: BookCounterAction) {
        let userQuery = Constants.Firebase.userRef.child(Constants.currentUid).child("numberOfBooks")
        userQuery.observeSingleEvent(of: .value) { snapshot in
            var numberOfBooks = snapshot.value as! Int
            switch action {
            case .add:
                numberOfBooks += 1
            case .remove:
                numberOfBooks -= 1
            }
            userQuery.setValue(numberOfBooks)
        }
    }

    static func deleteUserDetails() {
        Constants.Firebase.userRef.child(Constants.currentUid).removeValue()
    }

    static func logout() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
