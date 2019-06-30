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
    let content: String
    let sender: String
    let timestamp: Timestamp?

    var displayDate: String {
        guard let timestamp = timestamp else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "FR-fr")
        return dateFormatter.string(from: timestamp.dateValue())
    }

//    init(_ text: String, to contact: Chat) {
//        self.text = text
//        self.senderUid = Persist.uid
//        self.timestamp = nil
//
//        send(to: contact)
//    }

    init(from document: DocumentSnapshot) {
        content = document.get("content") as? String ?? "Erreur content"
        sender = document.get("sender") as? String ?? "Erreur sender"
        timestamp = document.get("timestamp") as? Timestamp
    }

    // Create a new message between users
    private func send(to contact: Chat) {
//        guard !text.isEmpty else { return }
//        let chatKey = Constants.chatKey(uid1: senderUid, uid2: contact.uid)
//        let message: [String : Any] = ["text": text,
//                                       "senderUid": senderUid,
//                                       "timestamp": ServerValue.timestamp()]
//
//        FirebaseManager.chatRef.child(chatKey).childByAutoId().setValue(message) { (error, reference) in
//            guard error == nil else { return }
//            self.updateContact(contact)
//        }
    }

    // Update the timestamp and change the unread message flag to true
    private func updateContact(_ contact: Chat) {
//        let path = "\(contact.uid)/contacts/\(senderUid)"
//        let value: [String : Any] = ["name": Session.user.name,
//                                     "unread": true,
//                                     "timestamp": ServerValue.timestamp()]
//
//        FirebaseManager.userRef.child(path).setValue(value) { (error, reference) in
//            guard error == nil else { return }
//            self.updateUserContact(contact)
//        }
    }

    // Update the timestamp for the conversation to be on top
    private func updateUserContact(_ contact: Chat) {
//        let path = "\(senderUid)/contacts/\(contact.uid)"
//        let value: [String : Any] = ["name": contact.name,
//                                     "timestamp": ServerValue.timestamp()]
//
//        FirebaseManager.userRef.child(path).updateChildValues(value) { (error, reference) in
//            guard error == nil else { return }
//        }
    }
}
