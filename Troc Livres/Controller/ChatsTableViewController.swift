//
//  ChatsTableViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import ProgressHUD

class ChatsTableViewController: UITableViewController {

    var chatKey: String!
    var chatTitle: String!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Session.user.contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        cell.textLabel?.text = Session.user.contacts[indexPath.row].name
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatKey = Session.user.contacts[indexPath.row].chatKey
        chatTitle = Session.user.contacts[indexPath.row].name
        performSegue(withIdentifier: "chatMessages", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatMessages" {
            let messageVC = segue.destination as! ChatMessagesTableViewController
            messageVC.chat = Chat(fromKey: chatKey)
            messageVC.title = chatTitle
        }
    }
}
