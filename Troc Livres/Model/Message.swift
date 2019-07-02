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

    init(from document: DocumentSnapshot) {
        content = document.get("content") as? String ?? "Erreur content"
        sender = document.get("sender") as? String ?? "Erreur sender"
        timestamp = document.get("timestamp") as? Timestamp
    }
}
