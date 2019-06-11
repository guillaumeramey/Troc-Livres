//
//  SearchResultViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 10/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class SearchResultViewController: UITableViewController {

    // MARK: - Properties

    var bookTitle: String!
    var bookAuthor: String!
    var books = [Book]()
    var selectedBook: Book!
    private let cellId = "bookCell"

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UINib(nibName: "BookViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        let bookService = BookService()
        bookService.getBook(title: bookTitle, author: bookAuthor) { result in
            switch result {
            case .success(let books):
                self.books = books
                self.tableView.reloadData()
            case .failure(let error):
                ProgressHUD.showError(error.localizedDescription)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BookViewCell
        cell.book = books[indexPath.row]
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedBook = books[indexPath.row]
        performSegue(withIdentifier: "bookDetail", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookDetail" {
            let bookVC = segue.destination as! BookViewController
            bookVC.book = selectedBook
            bookVC.user = Session.user
        }
    }
}
