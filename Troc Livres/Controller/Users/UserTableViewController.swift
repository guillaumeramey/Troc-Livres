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
    private let cellId = "bookCell"

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.name
        tableView.register(UINib(nibName: "BookViewCell", bundle: nil), forCellReuseIdentifier: cellId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookDetail" {
            let bookVC = segue.destination as! BookViewController
            bookVC.book = selectedBook
            bookVC.user = user
        }
    }

    // MARK: - TableView DataSource {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user == nil ? 0 : user.books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BookViewCell
        cell.book = user.books[indexPath.row]
        return cell
    }

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedBook = user.books[indexPath.row]
        performSegue(withIdentifier: "bookDetail", sender: self)
    }
}
