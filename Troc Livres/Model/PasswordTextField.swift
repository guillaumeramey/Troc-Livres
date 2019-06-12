//
//  PasswordTextField.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 03/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class PasswordTextField: CustomTextField {

    var toggleSecureTextButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
//        leftView = setLabel()
//        leftViewMode = .always
        rightView = setToggleSecureTextButton()
        rightViewMode = .always
    }

//    func setLabel() -> UILabel {
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
//        label.text = " 🔒"
//        label.tintColor = Constants.Color.button
//        return label
//    }

    // Show / hide password button
    func setToggleSecureTextButton() -> UIButton {
        toggleSecureTextButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        toggleSecureTextButton.setImage(Constants.Image.eyeShow, for: .normal)
//        toggleSecureTextButton.setImage(UIImage(systemName: "eye"), for: .normal)
        toggleSecureTextButton.tintColor = Constants.Color.button
        toggleSecureTextButton.addTarget(self, action: #selector(toggleSecureText), for: .touchUpInside)
        return toggleSecureTextButton
    }
    
    @objc func toggleSecureText() {
        isSecureTextEntry.toggle()
        let image = isSecureTextEntry ? Constants.Image.eyeShow : Constants.Image.eyeHide
        toggleSecureTextButton.setImage(image, for: .normal)
    }
}
