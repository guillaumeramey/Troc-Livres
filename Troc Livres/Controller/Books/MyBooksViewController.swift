//
//  MyBooksViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 22/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase

class MyBooksViewController: UITableViewController {

    // MARK: - Properties

    var selectedBook: Book!

    // MARK: - Outlets

    @IBOutlet weak var tableViewBackgroundView: UIView!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = tableViewBackgroundView
        tableView.register(UINib(nibName: Constants.Cell.book, bundle: nil), forCellReuseIdentifier: Constants.Cell.book)

        FirebaseManager.getBooks(uid: Session.user.uid, completion: { books in
            Session.user.books = books
            self.tableView.reloadData()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.reloadData()
        tableView.backgroundView?.isHidden = Session.user.books.count > 0 ? true : false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Session.user.books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.book, for: indexPath) as! BookViewCell
        cell.book = Session.user.books[indexPath.row]
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedBook = Session.user.books[indexPath.row]
        performSegue(withIdentifier: Constants.Segue.bookVC, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.bookVC {
            let destinationVC = segue.destination as! BookViewController
            destinationVC.book = selectedBook
            destinationVC.user = Session.user
        }
    }

    @IBAction func unwindToMyBooks(segue:UIStoryboardSegue) { }
}
