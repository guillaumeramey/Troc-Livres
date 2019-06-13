//
//  UserTableViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 19/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {

    // MARK: - Properties

    var user: User!
    var books = [Book]()
    var selectedBook: Book!
    private let bookViewCell = "BookViewCell"
    private let userViewCell = "UserViewCell"
    private let bookSegue = "bookSegue"

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
//        title = user.name
        tableView.register(UINib(nibName: bookViewCell, bundle: nil), forCellReuseIdentifier: bookViewCell)
        tableView.register(UINib(nibName: userViewCell, bundle: nil), forCellReuseIdentifier: userViewCell)
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.navigationBar.prefersLargeTitles = true
//    }

    // MARK: - TableView DataSource {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.books.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: userViewCell, for: indexPath) as! UserViewCell
            cell.user = user
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: bookViewCell, for: indexPath) as! BookViewCell
            cell.book = user.books[indexPath.row - 1]
            return cell
        }
    }

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedBook = user.books[indexPath.row - 1]
        performSegue(withIdentifier: bookSegue, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == bookSegue {
            let destinationVC = segue.destination as! BookViewController
            destinationVC.book = selectedBook
            destinationVC.user = user
        }
    }
}
