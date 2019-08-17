//
//  Switcher.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 28/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

import ProgressHUD

class Switcher {
    
    static func updateRootVC() {
        var storyboardName = "Welcome"
        var rootVCId = "WelcomeViewController"
        
        // User is already signed in ?
        if Auth.auth().currentUser != nil {
            storyboardName = "Main"
            rootVCId = "Main"
        }
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: rootVCId)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
    }
}
