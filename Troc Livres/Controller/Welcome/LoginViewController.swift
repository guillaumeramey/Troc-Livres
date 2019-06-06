//
//  LogInViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var signInButton: CustomButton!

    var forgotPasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        setForgotPasswordButton()
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }

    // MARK: - Actions
    @IBAction func signInButtonPressed(_ sender: AnyObject) {
        signInButton.isEnabled = false
        ProgressHUD.show("Authentification")
        switch checkForm() {
        case .accepted:
            authenticateUser()
        case .rejected(let error):
            ProgressHUD.showError(error)
        }
        signInButton.isEnabled = true
    }

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }


    private func checkForm() -> FormError {
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

    private func authenticateUser() {
        FirebaseManager.logIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { result in
            switch result {
            case .success(_):
                self.getUserData()
            case .failure(let error):
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    print(errorCode.rawValue)
                    switch errorCode {
                    case .invalidEmail:
                        ProgressHUD.showError("E-mail invalide")
                    case .networkError:
                        ProgressHUD.showError("Problème de connexion")
                    case .wrongPassword:
                        ProgressHUD.showError("Mot de passe incorrect")
                    case .userNotFound:
                        ProgressHUD.showError("Utilisateur introuvable")
                    default:
                        ProgressHUD.showError(error.localizedDescription)
                    }
                }
            }
        }
    }

    private func getUserData() {
        ProgressHUD.show("Récupération des données de l'utilisateur")
        FirebaseManager.getCurrentUserData(completion: { success in
            if success {
                ProgressHUD.dismiss()
                self.performSegue(withIdentifier: "userLogged", sender: self)
            } else {
                ProgressHUD.showError("Erreur lors de l'accès aux données")
            }
        })
    }
}

extension LogInViewController: UITextFieldDelegate {

    // Keyboard navigation between textfields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
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

extension LogInViewController {

    // Add a forgot password button
    func setForgotPasswordButton() {
        forgotPasswordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        forgotPasswordButton.setTitle("Oublié ?", for: .normal)
        forgotPasswordButton.setTitleColor(Constants.Color.button, for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
    }

    @objc func forgotPassword() {
        print("forgot")
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if passwordTextField.text!.isEmpty {
            passwordTextField.rightView = forgotPasswordButton
        } else {
            passwordTextField.rightView = passwordTextField.toggleSecureTextButton
        }
    }

}
