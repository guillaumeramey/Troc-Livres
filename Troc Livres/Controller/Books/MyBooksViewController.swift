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

    var books = [Book]()
    var selectedBook: Book!

    // MARK: - Outlets

    @IBOutlet weak var tableViewBackgroundView: UIView!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: Constants.Cell.book, bundle: nil), forCellReuseIdentifier: Constants.Cell.book)
        
//        if Session.user == nil {
//            FirebaseManager.getUser(uid: Persist.uid) { user in
//                Session.user = user
//                self.getUserBooks()
//            }
//        } else {
            getUserBooks()
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        books = Session.user.books
        tableView.reloadData()
    }
    
    private func getUserBooks() {
        FirebaseManager.getBooks(uid: Persist.uid, completion: { books in
            self.books = books
            Session.user.books = books
            self.tableView.backgroundView = self.tableViewBackgroundView
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = books.count > 0 ? true : false
        return books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.book, for: indexPath) as! BookViewCell
        cell.book = books[indexPath.row]
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedBook = books[indexPath.row]
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
