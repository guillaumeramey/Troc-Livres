//
//  UserViewCell.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 12/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase

class UserViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userDetail: UILabel!
    @IBOutlet weak var userImage: UIImageView!

    var user: User! {
        didSet {
            updateCell()
        }
    }

    private func updateCell() {
        userName.text = user.name
        userDetail.text = user.subtitle
        userImage.sd_setImage(with: user.imageRef, placeholderImage: Constants.Image.noUserImage)
    }
}
