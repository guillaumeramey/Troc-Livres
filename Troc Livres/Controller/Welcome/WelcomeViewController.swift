//
//  WelcomeViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import CoreLocation

class WelcomeViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var usernameLine: UIView!
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!


    // MARK: - Properties

    var registration: Bool! {
        didSet {
            updateDisplay()
        }
    }

    // MARK: - Actions

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            registration = true
        case 1:
            registration = false
        default:
            break
        }
    }

    @IBAction func validateButtonPressed(_ sender: AnyObject) {
        validateButton.isEnabled = false
        switch checkForm() {
        case .accepted:
            registration ? createUser() : authenticateUser()
        case .rejected(let error):
            ProgressHUD.showError(error)
            validateButton.isEnabled = true
        }
    }

    @IBAction func forgotPasswordButtonPressed(_ sender: AnyObject) {
        if emailTextField.text == nil || emailTextField.text == "" {
            ProgressHUD.showError("Entrez votre e-mail")
            return
        }
        FirebaseManager.resetPassword(withEmail: emailTextField.text!) { errorMessage in
            if let errorMessage = errorMessage {
                ProgressHUD.showError(errorMessage)
            } else {
                self.alert(title: "E-mail envoyé !", message: "Consultez vos e-mails et suivez les instructions pour réinitialiser votre mot de passe.")
            }
        }
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setDesign()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #warning("remove")
        passwordTextField.text = "123456"
        emailTextField.text = "tony.stark@avengers.com"
        usernameTextField.text = nil
    }

    private func setDesign() {
        registration = true

        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)], for: .normal)

        validateButton.layer.cornerRadius = 8
        
        textFieldsView.layer.cornerRadius = 8
        textFieldsView.layer.masksToBounds = true
        textFieldsView.layer.borderWidth = 1
        textFieldsView.layer.borderColor = Constants.Color.lightGray.cgColor

        usernameTextField.setIcon(Constants.Image.person)
        emailTextField.setIcon(Constants.Image.envelope)
        passwordTextField.setIcon(Constants.Image.lock)
    }

    private func updateDisplay() {
        forgotPasswordButton.isHidden = registration
        usernameTextField.isHidden = !registration
        usernameLine.isHidden = !registration
    }

    private func checkForm() -> FormError {
        if (usernameTextField.text == nil || usernameTextField.text == "") && registration {
            return .rejected("Entrez un nom d'utilisateur")
        }
        if emailTextField.text == nil || emailTextField.text == "" {
            return .rejected("Entrez votre e-mail")
        }
        if passwordTextField.text == nil || passwordTextField.text == "" {
            return .rejected("Entrez votre mot de passe")
        }
        if passwordTextField.text!.count < 6 {
            return .rejected("Le mot de passe doit faire 6 caractères minimum")
        }
        return .accepted
    }

    private func createUser() {
        ProgressHUD.show("Création de votre compte")
        FirebaseManager.createUser(email: emailTextField.text!, password: passwordTextField.text!) { errorMessage in
            if let errorMessage = errorMessage {
                ProgressHUD.showError(errorMessage)
                self.validateButton.isEnabled = true
                return
            }
            self.setUserName()
        }
    }

    private func setUserName() {
        FirebaseManager.setUserName(usernameTextField.text!) { success in
            if success {
                self.performSegue(withIdentifier: "userLogged", sender: self)
            } else {
                ProgressHUD.showError("Impossible de sauvegarder le nom d'utilisateur")
                self.validateButton.isEnabled = true
            }
        }
    }

    private func authenticateUser() {
        ProgressHUD.show("Connexion en cours")
        FirebaseManager.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { errorMessage in
            if let errorMessage = errorMessage {
                ProgressHUD.showError(errorMessage)
                self.validateButton.isEnabled = true
                return
            }
            FirebaseManager.getUser(uid: Persist.uid, completion: { user in
                guard let user = user else {
                    ProgressHUD.showError("Impossible de se connecter")
                    self.validateButton.isEnabled = true
                    return
                }
                Persist.name = user.name
                Persist.address = user.address ?? "Non renseigné"
                Persist.location = CLLocationCoordinate2D(latitude: user.location?.latitude ?? 0, longitude: user.location?.longitude ?? 0)
                self.performSegue(withIdentifier: "userLogged", sender: self)
            })
        }
    }

    // MARK: - Navigation

    @IBAction func unwindToWelcome(segue:UIStoryboardSegue) {
        ProgressHUD.dismiss()
    }
}

// MARK: - Keyboard navigation between textfields

extension WelcomeViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
        default:
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
