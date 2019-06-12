//
//  CustomTextField.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 07/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        iconView.image = image
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor.white

        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        iconContainerView.backgroundColor = Constants.Color.button
        iconContainerView.addSubview(iconView)

//        leftView?.backgroundColor = Constants.Color.button
        leftView = iconContainerView
        leftViewMode = .always
    }
}
