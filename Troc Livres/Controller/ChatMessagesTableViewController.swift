//
//  ChatMessagesTableViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase

class ChatMessagesTableViewController: UITableViewController {

    var chat: Chat!

    override func viewDidLoad() {
        super.viewDidLoad()

        retrieveMessages()
    }

    func retrieveMessages() {
        var messages = [Message]()
        Constants.Firebase.chatRef.child(chat.key).observe(.childAdded) { snapshot in
            if let message = Message(from: snapshot) {
                messages.append(message)
            }
            self.chat.messages = messages
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)

        let text = chat.messages[indexPath.row].text
        let sender = chat.messages[indexPath.row].sender
        let timestamp = chat.messages[indexPath.row].timestamp
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = "\(sender) \(timestamp)"

        return cell
    }

}
