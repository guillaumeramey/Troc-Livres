//
//  AccountManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation

protocol AccountManager {
    func createAccount(name: String, email: String, password: String, completion: @escaping (String?) -> Void)
    func signIn(withEmail email: String, password: String, completion: @escaping (String?) -> Void)
    func signOut()
    func reauthenticate(withPassword password: String, completion: @escaping (Bool) -> Void)
    func resetPassword(withEmail email: String, completion: @escaping (String?) -> Void)
    func setToken()
}

protocol AccountManagerInjectable {
    var accountManager: AccountManager { get }
}

extension AccountManagerInjectable {
    var accountManager: AccountManager {
        return FirebaseManager()
    }
}
