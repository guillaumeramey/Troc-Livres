//
//  PasswordTextField.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 03/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

// Add the show / hide button in the rightView
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

    // Show / hide password button
    func setup() {
        let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        toggleSecureTextButton = UIButton(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        toggleSecureTextButton.setImage(Constants.Image.eyeShow, for: .normal)
        toggleSecureTextButton.imageView?.contentMode = .scaleAspectFit
        toggleSecureTextButton.tintColor = Constants.Color.button
        toggleSecureTextButton.addTarget(self, action: #selector(toggleSecureText), for: .touchUpInside)
        containerView.addSubview(toggleSecureTextButton)

        rightView = containerView
        rightViewMode = .always
    }
    
    @objc func toggleSecureText() {
        isSecureTextEntry.toggle()
        let image = isSecureTextEntry ? Constants.Image.eyeShow : Constants.Image.eyeHide
        toggleSecureTextButton.setImage(image, for: .normal)
    }
}
