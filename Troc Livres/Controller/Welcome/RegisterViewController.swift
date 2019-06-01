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

    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    var imagePicker = UIImagePickerController()
    var latitude, longitude: Double!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
    }

    @IBAction func selectImage(_ sender: AnyObject) {
        present(imagePicker, animated: true)
    }

    @IBAction func validateButtonPressed(_ sender: AnyObject) {
        ProgressHUD.show()
        switch checkForm() {
        case .accepted:
            checkAddress()
        case .rejected(let error):
            ProgressHUD.showError(error)
        }
    }

    enum FormError {
        case accepted
        case rejected(String)
    }

    private func checkForm() -> FormError {
        if usernameTextField.text == nil || usernameTextField.text == "" {
            return .rejected("Entrez un nom d'utilisateur")
        }
        if addressTextField.text == nil || addressTextField.text == "" {
            return .rejected("Entrez une adresse valide")
        }
        if emailTextField.text == nil || emailTextField.text == "" {
            return .rejected("Entrez un e-mail valide")
        }
        if passwordTextField.text == nil || passwordTextField.text == "" {
            return .rejected("Entrez un mot de passe")
        }
        return .accepted
    }

    private func checkAddress() {
        CLGeocoder().geocodeAddressString(addressTextField.text!) { placemarks, error in
            if let location = placemarks?.first?.location {
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                self.createUser()
            }
            ProgressHUD.dismiss()
        }
    }

    private func createUser() {
        ProgressHUD.show("Création du compte")
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (user, error) in
            if let error = error {
                ProgressHUD.showError("\(error.localizedDescription)")
                return
            }
            self.saveUserData()
        }
    }

    private func saveUserData() {
        guard let userUid = Auth.auth().currentUser?.uid else { fatalError() }

        if let data = imageButton.currentImage?.jpegData(compressionQuality: 0) {
            let imageRef = Constants.Firebase.imageRef.child("images/\(userUid).jpg")
            _ = imageRef.putData(data, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    return
                }
            }
        }

        let user: [String: Any] = ["name": usernameTextField.text!,
                                   "latitude": latitude as Any,
                                   "longitude": longitude as Any]

        Constants.Firebase.userRef.child(userUid).setValue(user) { (error, reference) in
            guard error == nil else {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            ProgressHUD.dismiss()
        }

        UserManager.getSessionUser(userUid) { success in
            guard success else { return }
            self.performSegue(withIdentifier: "userLogged", sender: self)
        }
    }
}

// MARK: - Image picker
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Allows the user to select an image
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageButton.setImage(pickedImage, for: .normal)
        imageButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        dismiss(animated: true)
    }

    // Canceling the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
