//
//  UserBooksTableViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 22/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase

class UserBooksTableViewController: UITableViewController {

    var selectedBook: Book!
    var currentUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        displayUser()
    }

    private func displayUser() {
        guard let currentUid = Auth.auth().currentUser?.uid else { fatalError() }

        UserManager.getUser(currentUid) { user in
            self.currentUser = user

            print(self.currentUser.books.count)

            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser == nil ? 0 : currentUser.books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        let book = currentUser.books[indexPath.row]
        cell.textLabel?.text = book.title
        cell.detailTextLabel?.text = book.author
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = currentUser.books[indexPath.row]
        performSegue(withIdentifier: "bookDetail", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookDetail" {
            let bookVC = segue.destination as! BookViewController
            bookVC.book = selectedBook
        }
    }
}
