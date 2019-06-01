//
//  ContactViewCell.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 29/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class ContactViewCell: UITableViewCell {

    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactImage: UIImageView!

    func set(contact: Contact) {
        contactName.text = contact.name
        contactName.isHighlighted = contact.unread
        let userRef = Constants.Firebase.imageRef.child("images/\(contact.uid).jpg")
        contactImage.sd_setImage(with: userRef)
    }
}
