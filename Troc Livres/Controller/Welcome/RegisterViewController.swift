//
//  RegisterViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import CoreLocation

class RegisterViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
//    @IBOutlet weak var showPasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseManager.logOut()
    }

    // MARK: - Actions


    @IBAction func validateButtonPressed(_ sender: AnyObject) {
        #warning("disable buttons")
        ProgressHUD.show()
        switch checkForm() {
        case .accepted:
            createUser()
        case .rejected(let error):
            ProgressHUD.showError(error)
        }
    }

    // MARK: - Methods
    private func checkForm() -> FormError {
        if usernameTextField.text == nil || usernameTextField.text == "" {
            return .rejected("Entrez un nom d'utilisateur")
        }
        if emailTextField.text == nil || emailTextField.text == "" {
            return .rejected("Entrez un e-mail valide")
        }
        if passwordTextField.text == nil || passwordTextField.text == "" {
            return .rejected("Entrez un mot de passe")
        }
        if passwordTextField.text!.count < 6 {
            return .rejected("Le mot de passe doit faire 6 caractères minimum")
        }
        return .accepted
    }

    private func createUser() {
        ProgressHUD.show()
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (user, error) in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
//                print(errorCode.rawValue)
                switch errorCode {
                case .invalidEmail:
                    ProgressHUD.showError("E-mail invalide")
                case .emailAlreadyInUse:
                    ProgressHUD.showError("E-mail déjà utilisé")
                default:
                    ProgressHUD.showError(error.localizedDescription)
                }
                return
            }
            self.saveUsername()
        }
    }

    private func saveUsername() {
        FirebaseManager.setUsername(usernameTextField.text!) { success in
            if success {
                ProgressHUD.dismiss()
                self.performSegue(withIdentifier: "userLogged", sender: self)
            } else {
                ProgressHUD.showError("Impossible de sauvegarder le nom d'utilisateur")
            }
        }
    }

    // MARK: - Navigation
    @IBAction func unwindToSignUp(segue:UIStoryboardSegue) {
        ProgressHUD.dismiss()
    }
}

// Keyboard navigation between textfields
extension RegisterViewController: UITextFieldDelegate {

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
