//
//  AccountManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 17/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class AccountManager: FirebaseManager {
    
    static func signIn(withEmail email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(getErrorMessage(from: error))
                return
            }
            Persist.uid = result?.user.uid ?? ""
            completion(nil)
        }
    }
    
    static func signOut() {
        Persist.uid = ""
        Persist.name = ""
        Persist.address = ""
        Persist.location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        do {
            try Auth.auth().signOut()
            Switcher.updateRootVC()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    static func reauthenticate(withPassword password: String, completion: @escaping (Bool) -> Void) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: password)
        user?.reauthenticate(with: credential, completion: { (result, error) in
            completion(error == nil)
        })
    }
    
    static func resetPassword(withEmail email: String, completion: @escaping (String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(getErrorMessage(from: error))
                return
            }
            completion(nil)
        }
    }
}
