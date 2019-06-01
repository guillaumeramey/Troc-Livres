//
//  WelcomeViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 31/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navigation
    @IBAction func unwindToWelcome(segue:UIStoryboardSegue) {
        User.logout()
        Persist.distance = Constants.Params.initialDistance
        ProgressHUD.dismiss()
    }
}
