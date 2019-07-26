//
//  ChatListViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class ChatListViewController: UITableViewController, DataManagerInjectable {

    // MARK: - Properties

    var selectedChat: Chat!

    // MARK: - Outlets
    
    @IBOutlet weak var tableViewBackgroundView: UIView!
    
    // MARK: - Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.items?[1].badgeValue = nil
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        tableView.tableFooterView = UIView()
        getChats()
    }

    private func getChats() {
        ProgressHUD.show()
        currentUser.getChats {
            ProgressHUD.dismiss()
            self.tableView.backgroundView = currentUser.chats.count > 0 ? nil : self.tableViewBackgroundView
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser.chats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.chat, for: indexPath)
        cell.textLabel?.text = currentUser.chats[indexPath.row].user.name
        cell.textLabel?.isHighlighted = currentUser.chats[indexPath.row].unread
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedChat = currentUser.chats[indexPath.row]
        performSegue(withIdentifier: Constants.Segue.chatVC, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.chatVC {
            let destinationVC = segue.destination as! ChatViewController
            destinationVC.chat = selectedChat
        }
    }
}
