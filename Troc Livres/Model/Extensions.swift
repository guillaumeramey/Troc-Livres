//
//  Extensions.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import ProgressHUD

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(actionOk)
        present(alert, animated: true)
    }

    // MARK: - Navigation

    func goBack() {
        navigationController?.popViewController(animated: true)
    }
//
//    func logout() {
//        guard let window = UIApplication.shared.keyWindow else { return }
//        guard let rootViewController = window.rootViewController else { return }
//
//        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterViewController")
//        vc.view.frame = rootViewController.view.frame
//        vc.view.layoutIfNeeded()
//
//        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
//            window.rootViewController = vc
//        }, completion: { completed in
//            // maybe do something here
//        })
//    }

    enum FormError {
        case accepted
        case rejected(String)
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
