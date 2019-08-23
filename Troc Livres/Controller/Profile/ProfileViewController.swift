//
//  ProfileViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import CoreLocation
import MapKit

class ProfileViewController: UITableViewController {

    // MARK: - Outlets

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: PassThroughView!
    @IBOutlet weak var booksLanguageSwitch: UISwitch!
    
    // MARK: - Actions

    @IBAction func booksLanguageSwitchValueChanged(_ sender: UISwitch) {
        Persist.preferredLanguage = sender.isOn
    }
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = Persist.name
        tableView.tableFooterView = UIView()
        updateUserLocation()
        booksLanguageSwitch.isOn = Persist.preferredLanguage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Remove badge
        tabBarController?.tabBar.items?[3].badgeValue = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Display badge if no address
        if Persist.address == "" { tabBarController?.tabBar.items?[3].badgeValue = "!" }
    }
    
    private func updateUserLocation() {
        addressLabel.text = Persist.address != "" ? Persist.address : NSLocalizedString("tap to select location", comment: "")
        let region = MKCoordinateRegion.init(center: Persist.location,
                                             latitudinalMeters: 1000,
                                             longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)

        let userLocation = MKPointAnnotation()
        userLocation.title = ""
        userLocation.coordinate = Persist.location
        mapView.addAnnotation(userLocation)
    }
    
    @IBAction func signOut() {
        DependencyInjection.shared.dataManager.signOut()
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        let alertTitle = NSLocalizedString("password required", comment: "")
        let alertMessage = NSLocalizedString("alert delete account", comment: "")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        // Reauthenticate to confirm deletion
        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("password", comment: "")
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .destructive, handler: { [weak alert] (_) in
            if let password = alert?.textFields![0].text, password != "" {
                ProgressHUD.show()
                DependencyInjection.shared.dataManager.reauthenticate(withPassword: password, completion: { success in
                    if success {
                        self.deleteUser()
                    } else {
                        ProgressHUD.showError(NSLocalizedString("wrong password", comment: ""))
                    }
                })
            }
        }))
        present(alert, animated: true)
    }

    private func deleteUser() {
        ProgressHUD.show(NSLocalizedString("deleting account", comment: ""))
        DependencyInjection.shared.dataManager.deleteUser { error in
            if let error = error {
                ProgressHUD.showError(NSLocalizedString("error deleting account", comment: "") + error.localizedDescription)
            } else {
                DependencyInjection.shared.dataManager.signOut()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return view.frame.height / 5
        }
        return view.frame.height / 10
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return view.frame.height / 5
        }
        return view.frame.height / 10
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.changeLocationVC {
            let destinationVC = segue.destination as! ChangeLocationViewController
            destinationVC.delegate = self
        }
    }
}

extension ProfileViewController: ChangeLocationDelegate {
    func changeLocation(address: String, location: CLLocation) {
        Persist.address = address
        Persist.location = location.coordinate
        updateUserLocation()
    }
}
