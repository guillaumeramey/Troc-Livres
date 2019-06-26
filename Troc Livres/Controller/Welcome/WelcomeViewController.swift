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

class WelcomeViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var usernameLine: UIView!
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var validateButton: CustomButton!
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
        ProgressHUD.show()
        switch checkForm() {
        case .accepted:
            registration ? createUser() : authenticateUser()
        case .rejected(let error):
            ProgressHUD.showError(error)
        }
        validateButton.isEnabled = true
    }

    @IBAction func forgotPasswordButtonPressed(_ sender: AnyObject) {
        #warning("todo")
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setDesign()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseManager.signOut()
        #warning("remove")
        passwordTextField.text = "123456"
        emailTextField.text = "tony.stark@avengers.com"
        usernameTextField.text = nil
    }

    private func setDesign() {
        registration = true

        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: Constants.Font.button], for: .normal)

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
        FirebaseManager.createUser(email: emailTextField.text!, password: passwordTextField.text!) { errorMessage in
            if let errorMessage = errorMessage {
                ProgressHUD.showError(errorMessage)
            } else {
                self.setUserName()
            }
        }
    }

    private func setUserName() {
        FirebaseManager.setUserName(usernameTextField.text!) { success in
            if success {
                self.getCurrentUserData()
            } else {
                ProgressHUD.showError("Impossible de sauvegarder le nom d'utilisateur")
            }
        }
    }

    private func authenticateUser() {
        FirebaseManager.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { errorMessage in
            if let errorMessage = errorMessage {
                ProgressHUD.showError(errorMessage)
            } else {
                self.getCurrentUserData()
            }
        }
    }

    private func getCurrentUserData() {
        ProgressHUD.show("Récupération des données de l'utilisateur")
        FirebaseManager.getUser(completion: { user in
            if let user = user {
                Session.user = user
                ProgressHUD.dismiss()
                self.performSegue(withIdentifier: "userLogged", sender: self)
            } else {
                ProgressHUD.showError("Erreur lors de l'accès aux données")
            }
        })
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
