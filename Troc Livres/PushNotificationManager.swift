//
//  PushNotificationManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 16/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import UserNotifications

class PushNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: {_, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        FirebaseManager().setToken()
    }
}
