//
//  LoginViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }

    // User authentication
    @IBAction func logInPressed(_ sender: AnyObject) {
        ProgressHUD.show("Authentification")
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            if let error = error {
                ProgressHUD.showError("\(error.localizedDescription)")
                return
            }
            ProgressHUD.showSuccess()
            self.performSegue(withIdentifier: "userLogged", sender: self)
        }
    }


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userLogged" {
            UserManager.getSessionUser(Auth.auth().currentUser!.uid) { success in
                guard success else {
                    ProgressHUD.showError()
                    return
                }
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {

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
