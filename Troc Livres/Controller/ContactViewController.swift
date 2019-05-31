//
//  ContactViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class ContactViewController: UITableViewController {

    var contacts = [Contact]()
    var selectedContact: Contact!
    private let cellId = "contactCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ContactViewCell", bundle: nil), forCellReuseIdentifier: cellId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        retrieveContacts()
    }

    func retrieveContacts() {
        var contacts = [Contact]()
        Constants.Firebase.userRef.child("\(Session.user.uid)/contacts").queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { snapshot in
            for contactSnapshot in snapshot.children {
                if let contact = Contact(from: contactSnapshot as! DataSnapshot) {
                    contacts.insert(contact, at: 0)
                }
            }
            self.contacts = contacts
            self.tableView.reloadData()
        }
    }

//    func refresh() {
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactViewCell
        cell.set(contact: contacts[indexPath.row])
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedContact = contacts[indexPath.row]
        performSegue(withIdentifier: "chat", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chat" {
            let chatVC = segue.destination as! ChatViewController
            chatVC.contact = selectedContact
        }
    }
}
