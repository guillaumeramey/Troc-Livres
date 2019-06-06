//
//  CustomButton.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 31/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import UIKit

class CustomButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        layer.cornerRadius = frame.size.height / 2
        layer.borderWidth = 2
        layer.borderColor = Constants.Color.button?.cgColor
        titleLabel?.font = Constants.Font.button
    }
}
