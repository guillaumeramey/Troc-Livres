//
//  PushNotificationManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 16/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

class PushNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: {_, _ in })
        // For iOS 10 data message (sent via FCM)
//        Messaging.messaging().delegate = self

        UIApplication.shared.registerForRemoteNotifications()
        UserManager.setToken()
    }

//
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print(remoteMessage.appData)
//    }
//
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        updateFirestorePushTokenIfNeeded()
//    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        print(response)
//    }
}
