//
//  AppDelegate.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 15/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        self.window = UIWindow(frame: UIScreen.main.bounds)

        var storyboardName = ""
        var initialVCId = ""
//        if let uid = Auth.auth().currentUser?.uid {
//            storyboardName = "Main"
//            initialVCId = "Main"
//            UserManager.getUser(uid: uid, completion: { success in
//                if success {
//                    print("************ USER success ************")
//                } else {
//                // logout
//                    print("************ USER failure ************")
//                }
//            })
//        } else {
            storyboardName = "Welcome"
            initialVCId = "WelcomeViewController"
//        }

        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: initialVCId)

        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
}
