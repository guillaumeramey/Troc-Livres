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

    var books = [Book]()
    var selectedBook: Book!

    override func viewDidLoad() {
        super.viewDidLoad()
        displayBooks()
    }

    private func displayBooks() {
        BookManager.getBooks(requestedUid: Constants.currentUid) { books in
            if let books = books {
                self.books = books
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        let book = books[indexPath.row]
        cell.textLabel?.text = book.title
        cell.detailTextLabel?.text = book.author
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = books[indexPath.row]
        print("selectedBook: \(String(describing: selectedBook))")
        performSegue(withIdentifier: "bookDetail", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookDetail" {
            let bookVC = segue.destination as! BookViewController
            bookVC.book = selectedBook
            print("bookVC.book: \(String(describing: bookVC.book))")
        }
    }
}
