//
//  UserBooksViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 22/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class UserBooksViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableViewBackgroundView: UIView!

    // MARK: - Properties

    var user: User!
    private var userBooks = [Book]()
    private var tableViewData = [(header: Character, books: [Book])]()
    private var selectedBook: Book!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setDisplay()
        tableView.register(UINib(nibName: Constants.Cell.book, bundle: nil), forCellReuseIdentifier: Constants.Cell.book)
        tableView.tableFooterView = UIView()
        getBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setDisplay() {
        if user != nil {
            title = user.name
        } else {
            title = "Mes livres"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        }
    }

    private func getBooks() {
        ProgressHUD.show()
        let uid = user != nil ? user.uid : Persist.uid
        FirebaseManager.getBooks(uid: uid, completion: { books in
            ProgressHUD.dismiss()
            self.userBooks = books
            self.updateTableView()
        })
    }

    private func updateTableView() {
        tableViewData.removeAll()
        userBooks.sorted(by: { $0.title < $1.title }).forEach { book in
            guard let letter = book.title.first else { return }

            if let section = self.tableViewData.firstIndex(where: { $0.header == letter }) {
                self.tableViewData[section].books.append(book)
            } else {
                self.tableViewData.append((header: letter, books: [book]))
            }
        }
        tableView.backgroundView = self.tableViewBackgroundView
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc func addTapped(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segue.searchBookVC, sender: self)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewData[section].header.description
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = tableViewData.count > 0 ? true : false
        return tableViewData[section].books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.book, for: indexPath) as! BookCell
        cell.book = tableViewData[indexPath.section].books[indexPath.row]
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedBook = tableViewData[indexPath.section].books[indexPath.row]
        performSegue(withIdentifier: Constants.Segue.bookVC, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.bookVC {
            let destinationVC = segue.destination as! BookViewController
            destinationVC.book = selectedBook
            destinationVC.user = user
            destinationVC.userBooks = userBooks
            destinationVC.delegate = self
        } else if segue.identifier == Constants.Segue.searchBookVC {
            let destinationVC = segue.destination as! SearchBookViewController
            destinationVC.userBooks = userBooks
        }
    }

    @IBAction func unwindToUserBooks(segue: UIStoryboardSegue) {
        if segue.source is BookViewController {
            let sourceVC = segue.source as! BookViewController
            userBooks = sourceVC.userBooks
            updateTableView()
        }
    }
}

extension UserBooksViewController: BookDelegate {
    func updateBooks(_ books: [Book]) {
        userBooks = books
        updateTableView()
    }
}
