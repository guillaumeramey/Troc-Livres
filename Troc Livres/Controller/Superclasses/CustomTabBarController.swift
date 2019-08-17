//
//  CustomTabBarController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 08/08/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveNotification(_:)), name: .pushNotificationReceived, object: nil)
        
        // Get the current user data
        DependencyInjection.shared.dataManager.getCurrentUser { success in
            if success {
                currentUser.getWishes()
            } else {
                Switcher.updateRootVC()
            }
        }
        
        // Alert user to check his profile tab if he did not choose an address
        if Persist.address == "" { tabBar.items?[3].badgeValue = "!" }
        
    }
    
    @objc func onDidReceiveNotification(_ notification: Notification) {
        if selectedIndex == 1 {
            NotificationCenter.default.post(name: .updateChats, object: nil)
        } else {
            tabBar.items?[1].badgeValue = "!"
        }
    }
}
