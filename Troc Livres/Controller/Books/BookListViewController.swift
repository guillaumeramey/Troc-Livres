//
//  BookListViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 22/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class BookListViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableViewBackgroundView: UIView!

    // MARK: - Properties

    var user: User!
    var loading = false {
        didSet {
            loading ? ProgressHUD.show() : ProgressHUD.dismiss()
        }
    }
    private var sortedBooks = [(header: Character, books: [Book])]()
    private var selectedBook: Book!

    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setDisplay()
        let nib = UINib(nibName: Constants.Cell.book, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constants.Cell.book)
        tableView.backgroundView = nil
        tableView.tableFooterView = UIView()
        getUserBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        if !loading {
            updateTableView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }

    private func setDisplay() {
        if user != nil {
            title = user.name
        } else {
            user = currentUser
            title = "Mes livres"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        }
    }

    private func getUserBooks() {
        loading = true
        user.getBooks {
            self.loading = false
            self.updateTableView()
        }
    }

    private func updateTableView() {
        sortedBooks.removeAll()
        if user.books.isEmpty {
            tableView.backgroundView = tableViewBackgroundView
        } else {
            tableView.backgroundView = nil
            user.books.sorted(by: { $0.title < $1.title }).forEach { book in
                guard let letter = book.title.first else { return }
                if let section = self.sortedBooks.firstIndex(where: { $0.header == letter }) {
                    sortedBooks[section].books.append(book)
                } else {
                    sortedBooks.append((header: letter, books: [book]))
                }
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc func addTapped(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segue.searchBookVC, sender: self)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sortedBooks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedBooks[section].header.description
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedBooks[section].books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.book, for: indexPath) as! BookCell
        cell.book = sortedBooks[indexPath.section].books[indexPath.row]
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedBook = sortedBooks[indexPath.section].books[indexPath.row]
        performSegue(withIdentifier: Constants.Segue.bookVC, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.bookVC {
            let destinationVC = segue.destination as! BookViewController
            destinationVC.book = selectedBook
            destinationVC.bookOwner = user
        }
    }

    @IBAction func unwindToUserBooks(segue: UIStoryboardSegue) {
        updateTableView()
    }
}
