//
//  ProfileViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import ProgressHUD

class ProfileViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        displayUser()
    }

    private func displayUser() {
        name.text = Session.user.name
        image.sd_setImage(with: Session.user.imageRef, placeholderImage: UIImage(named: "placeholder.jpg"))
    }


    // MARK: - ACTIONS
    @IBAction func logoutButtonPressed(_ sender: Any) {
        logout()
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "La suppression d'un compte est définitive et irréversible.", message: nil, preferredStyle: .actionSheet)
        let actionDelete = UIAlertAction(title: "Supprimer", style: .destructive, handler: deleteHandler)
        alert.addAction(actionDelete)
        let actionCancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }

    private func deleteHandler(alert: UIAlertAction) {
        ProgressHUD.show("Suppression des données")
        Session.user.delete()
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                ProgressHUD.showError("Echec de la suppression : \(error.localizedDescription)")
            } else {
                self.logout()
            }
        }
    }
}
