//
//  ChatMessagesTableViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class ChatMessagesTableViewController: UITableViewController {

    var chat: Chat!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = chat.key
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)

        cell.textLabel?.text = chat.messages[indexPath.row].text
        cell.detailTextLabel?.text = chat.messages[indexPath.row].uid

        return cell
    }

}
