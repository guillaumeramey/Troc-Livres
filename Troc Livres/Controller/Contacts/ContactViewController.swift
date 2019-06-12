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

    // MARK: - Properties

    var contacts = [Contact]()
    var selectedContact: Contact!
    
    private let cellId = "contactCell"

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ContactViewCell", bundle: nil), forCellReuseIdentifier: cellId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        getContacts()
    }

    private func getContacts() {
        FirebaseManager.getContacts { contacts in
            self.contacts = contacts
            self.tableView.reloadData()
        }
    }

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
        tableView.deselectRow(at: indexPath, animated: true)
        selectedContact = contacts[indexPath.row]
        performSegue(withIdentifier: "chat", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chat" {
            let destinationVC = segue.destination as! ChatViewController
            destinationVC.contact = selectedContact
        }
    }
}
