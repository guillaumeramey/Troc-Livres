//
//  Message.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

struct Message {
    let text: String
    let senderUid: String
    let timestamp: Date?

    var displayDate: String {
        guard let timestamp = timestamp else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "FR-fr")
        return dateFormatter.string(from: timestamp)
    }

    init(_ text: String, to contact: Contact) {
        self.text = text
        self.senderUid = Session.user.uid
        self.timestamp = nil

        // Send the message to a contact
        send(to: contact)
        // Update the timestamp and change the unread message flag to true
        updateContact(contact)
        // Update the timestamp for the conversation to be on top
        updateUserContact(contact)
    }

    init?(from snapshot: DataSnapshot){
        guard
            let value = snapshot.value as? [String: Any],
            let text = value["text"] as? String,
            let senderUid = value["senderUid"] as? String,
            let timestamp = value["timestamp"] as? TimeInterval
            else {
                return nil
        }

        self.text = text
        self.senderUid = senderUid
        self.timestamp = Date(timeIntervalSince1970: timestamp/1000)
    }

    // Create a new message between users
    private func send(to contact: Contact) {
        guard !text.isEmpty else { return }
        let chatKey = Constants.chatKey(uid1: senderUid, uid2: contact.uid)
        let message: [String : Any] = ["text": text,
                                       "senderUid": senderUid,
                                       "timestamp": ServerValue.timestamp()]

        Constants.Firebase.chatRef.child(chatKey).childByAutoId().setValue(message)
    }

    private func updateUserContact(_ contact: Contact) {
        let path = "\(senderUid)/contacts/\(contact.uid)"
        let value: [String : Any] = ["name": contact.name,
                                     "timestamp": ServerValue.timestamp()]

        Constants.Firebase.userRef.child(path).updateChildValues(value) { (error, reference) in
            guard error == nil else { return }
        }
    }

    // Mark the message as unread for the contact
    private func updateContact(_ contact: Contact) {
        let path = "\(contact.uid)/contacts/\(senderUid)"
        let value: [String : Any] = ["name": Session.user.name,
                                     "unread": true,
                                     "timestamp": ServerValue.timestamp()]

        Constants.Firebase.userRef.child(path).setValue(value) { (error, reference) in
            guard error == nil else { return }
        }
    }
}
