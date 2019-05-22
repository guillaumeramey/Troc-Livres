//
//  NewsViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 18/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import ProgressHUD

class NewsViewController: UITableViewController {

    // MARK: - PROPERTIES
    private var books = [Book]()
    private var selectedBook: Book!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayBooks()
    }

    private func displayBooks() {
        ProgressHUD.show("Récupération des derniers livres")
        BookManager.getBooks(completion: { (books) in
            if let books = books {
                self.books = books
            }
            ProgressHUD.dismiss()
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view datasource
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
        performSegue(withIdentifier: "fromNewsToBook", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromNewsToBook" {
            let bookVC = segue.destination as! BookViewController
            bookVC.book = selectedBook
        }
    }
}
