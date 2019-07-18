//
//  UserManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 17/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class UserManager: FirebaseManager {
    
    static func createUser(name: String, email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(getErrorMessage(from: error))
                return
            }
            Persist.uid = result?.user.uid ?? ""
            Persist.name = name
            usersCollection.document(Persist.uid).setData(["name": name])
            completion(nil)
        }
    }
    
    // Get a specific user
    static func getUser(uid: String, completion: @escaping (User?) -> Void) {
        usersCollection.document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                completion(User(from: document))
            }
        }
    }
    
    // Get all the users
    static func getUsers(completion: @escaping ([User]) -> Void) {
        usersCollection.whereField("numberOfBooks", isGreaterThan: 0).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            var users = [User]()
            for document in snapshot.documents {
                if Persist.uid != document.documentID {
                    users.append(User(from: document))
                }
                completion(users)
            }
        }
    }
    
    static func setUserLocation(address: String, location: CLLocation, completion: @escaping (Bool) -> Void) {
        let geoPoint = GeoPoint(latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude)
        usersCollection.document(Persist.uid)
            .updateData(["address": address, "location": geoPoint]) { (error) in
                completion(error == nil)
        }
    }
    
    static func setToken() {
        if let token = Messaging.messaging().fcmToken {
            usersCollection.document(Persist.uid).updateData(["fcmToken": token])
        }
    }
    
    
    static func deleteUser(completion: @escaping (Error?) -> Void) {
        BookManager.deleteBooks { error in
            if let error = error {
                print(error.localizedDescription)
            }
            BookManager.deleteBooksInWishlists { error in
                if let error = error {
                    print(error.localizedDescription)
                }
                WishlistManager.deleteWishlist { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    // Delete user data
                    //        usersCollection.document(Persist.uid).delete()
                    
                    // Delete user account
                    //        Auth.auth().currentUser?.delete { error in
                    //            completion(error)
                    //        }
                    completion(nil)
                }
            }
        }
        
    }
}
