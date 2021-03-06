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

    var selectedChat: Chat!
    var firstLoad = true

    // MARK: - Outlets
    
    @IBOutlet weak var tableViewBackgroundView: UIView!
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(getChats), name: .updateChats, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.items?[1].badgeValue = nil
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        tableView.tableFooterView = UIView()
        getChats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }

    @objc private func getChats() {
        if firstLoad { ProgressHUD.show() }
        currentUser.getChats {
            if self.firstLoad {
                ProgressHUD.dismiss()
                self.firstLoad = false
            }
            self.setBackgroundView()
        }
    }
    
    private func setBackgroundView() {
        if currentUser.chats.count == 0 {
            tableView.backgroundView = tableViewBackgroundView
        } else {
            tableView.backgroundView = nil
        }
        tableView.reloadData()
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
