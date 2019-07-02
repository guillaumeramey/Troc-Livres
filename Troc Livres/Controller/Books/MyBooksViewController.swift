//
//  MyBooksViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 22/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class MyBooksViewController: UITableViewController {

    // MARK: - Properties

    private var books = [Book]()
    private var selectedBook: Book!

    // MARK: - Outlets

    @IBOutlet weak var tableViewBackgroundView: UIView!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: Constants.Cell.book, bundle: nil), forCellReuseIdentifier: Constants.Cell.book)
        tableView.tableFooterView = UIView()
        getBooks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func getBooks() {
        ProgressHUD.show()
        FirebaseManager.getBooks(uid: Persist.uid, completion: { books in
            ProgressHUD.dismiss()
            self.books = books
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
            destinationVC.books = books
            destinationVC.delegate = self
        } else if segue.identifier == Constants.Segue.searchBookVC {
            let destinationVC = segue.destination as! SearchBookViewController
            destinationVC.userBooks = books
        }
    }

    @IBAction func unwindToMyBooks(segue: UIStoryboardSegue) {
        if segue.source is BookViewController {
            let sourceVC = segue.source as! BookViewController
            books = sourceVC.books
            tableView.reloadData()
        }
    }
}

extension MyBooksViewController: BookDelegate {
    func updateBooks(_ books: [Book]) {
        self.books = books
        tableView.reloadData()
    }
}
