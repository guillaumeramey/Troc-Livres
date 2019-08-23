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
            ProgressHUD.showError(NSLocalizedString("enter email", comment: ""))
            return
        }
        DependencyInjection.shared.dataManager.resetPassword(withEmail: emailTextField.text!) { errorMessage in
            if let errorMessage = errorMessage {
                ProgressHUD.showError(errorMessage)
                return
            }
            let title = NSLocalizedString("email sent", comment: "")
            let message = NSLocalizedString("check emails", comment: "")
            self.alert(title: title, message: message)
        }
    }

    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setDesign()
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
            return .rejected(NSLocalizedString("enter username", comment: ""))
        }
        if emailTextField.text == nil || emailTextField.text == "" {
            return .rejected(NSLocalizedString("enter email", comment: ""))
        }
        if passwordTextField.text == nil || passwordTextField.text == "" {
            return .rejected(NSLocalizedString("enter password", comment: ""))
        }
        if passwordTextField.text!.count < 6 {
            return .rejected(NSLocalizedString("password must be 6 chars", comment: ""))
        }
        return .accepted
    }

    private func createUser() {
        ProgressHUD.show(NSLocalizedString("creating account", comment: ""))
        DependencyInjection.shared.dataManager.createAccount(name: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!) { error in
            if let error = error {
                ProgressHUD.showError(error)
            } else {
                self.logIn()
            }
            self.validateButton.isEnabled = true
        }
    }

    private func authenticateUser() {
        ProgressHUD.show(NSLocalizedString("signing in", comment: ""))
        DependencyInjection.shared.dataManager.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { errorMessage in
            if let errorMessage = errorMessage {
                ProgressHUD.showError(errorMessage)
            } else {
                self.logIn()
            }
            self.validateButton.isEnabled = true
        }
    }
    
    private func logIn() {
        DependencyInjection.shared.dataManager.getCurrentUser(completion: { success in
            if success {
                self.performSegue(withIdentifier: "userLogged", sender: self)
            } else {
                ProgressHUD.showError(NSLocalizedString("error sign in", comment: ""))
            }
            self.validateButton.isEnabled = true
        })
    }

    // MARK: - Navigation

    @IBAction func unwindToWelcome(segue: UIStoryboardSegue) {
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
