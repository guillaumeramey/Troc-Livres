//
//  MessageViewCell.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 28/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class MessageViewCell: UITableViewCell {

    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var messageDate: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!

    var message: Message! {
        didSet {
            setCell()
        }
    }

    func setCell() {
        messageText.text = message.content
        messageDate.text = message.displayDate
        messageBackground.backgroundColor = .white
        messageBackground.layer.borderWidth = 0
        messageBackground.layer.cornerRadius = 5
        messageBackground.layer.borderColor = UIColor.white.cgColor

        if message.sender == "system" {
            // Message from the system
            messageText.textColor = Constants.Color.button
            messageDate.textColor = Constants.Color.button
            messageBackground.layer.borderWidth = 2
            messageBackground.layer.borderColor = Constants.Color.button.cgColor
            leadingConstraint.constant = 10
            trailingConstraint.constant = 10
            
        } else if message.sender == Persist.uid {
            // Message from the current user
            messageBackground.backgroundColor = Constants.Color.chatSender
            messageText.textColor = .white
            messageDate.textColor = .white
            leadingConstraint.constant = 80
            trailingConstraint.constant = 10
        } else {
            // Message from the other user
            messageBackground.backgroundColor = Constants.Color.chatReceiver
            messageText.textColor = .darkText
            messageDate.textColor = .darkText
            leadingConstraint.constant = 10
            trailingConstraint.constant = 80
        }
    }
}
