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

class UserManager {

    class func getUser(requestedUserUID: String = "all", completion: @escaping (_ user: [User]?) -> ()) {
        var users = [User]()
        let userQuery: DatabaseQuery

        if requestedUserUID == "all" {
            userQuery = Constants.userRef
        } else {
            userQuery = Constants.userRef.queryOrdered(byChild: "uid").queryEqual(toValue : requestedUserUID)
        }

        userQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let user = (child as! DataSnapshot)
                let value = user.value as! Dictionary<String, AnyObject>

                guard let uid = value["uid"] as? String else { fatalError() }
                if uid != Persist.userUID! && requestedUserUID == "all" || requestedUserUID != "all" {
                    if let name = value["name"] as? String,
                    let latitude = value["latitude"] as? Double,
                    let longitude = value["longitude"] as? Double,
                    let books = value["books"] as? Int {
                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        users.append(User(uid: uid, name: name, coordinate: coordinate, books: books))
                    }
                }
            }
            completion(users)
        })
    }
}
