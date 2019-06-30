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

class ChatListViewController: UITableViewController {

    // MARK: - Properties

    var chats = [Chat]()
    var selectedChat: Chat!

    // MARK: - Outlets
    
    @IBOutlet weak var tableViewBackgroundView: UIView!
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.items?[1].badgeValue = nil
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        getChats()
    }

    private func getChats() {
        ProgressHUD.show()
        FirebaseManager.getUserChats { chats in
            ProgressHUD.dismiss()
            self.chats = chats
            self.tableView.backgroundView = self.tableViewBackgroundView
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = chats.count > 0 ? true : false
        return chats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        cell.textLabel?.text = chats[indexPath.row].name
        cell.textLabel?.isHighlighted = chats[indexPath.row].unread
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedChat = chats[indexPath.row]
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
