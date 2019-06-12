//
//  SearchBookViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class SearchBookViewController: UIViewController {

    // MARK: - Properties

    var books = [Book]()
    var selectedBook: Book!
    private let cellId = "bookCell"

    // MARK: - Outlets

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Actions

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        let bookService = BookService()
        bookService.getBook(title: titleTextField.text!, author: authorTextField.text!) { result in
            switch result {
            case .success(let books):
                self.books = books
                self.tableView.reloadData()
                self.scrollTableViewToTop()
            case .failure(let error):
                ProgressHUD.showError(error.localizedDescription)
            }
        }
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        tableView.register(UINib(nibName: "BookViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        tableView.backgroundView = UINib(nibName: "SearchBookAdviceView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }


    private func scrollTableViewToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    private func validateData() {
        #warning("tester les données saisies")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanner" {
            let destinationVC = segue.destination as! ScannerViewController
            destinationVC.delegate = self
        }
        if segue.identifier == "bookDetail" {
            let destinationVC = segue.destination as! BookViewController
            destinationVC.book = selectedBook
            destinationVC.user = Session.user
        }
    }
}

extension SearchBookViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BookViewCell
        cell.book = books[indexPath.row]
        return cell
    }
}
extension SearchBookViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedBook = books[indexPath.row]
        performSegue(withIdentifier: "bookDetail", sender: self)
    }
}

extension SearchBookViewController: ScannerDelegate {

    // Barcode successfully scanned
    func getBook(isbn: String) {
        let bookService = BookService()
        bookService.getBook(isbn: isbn) { result in
            switch result {
            case .success(let books):
                self.books = books
                self.tableView.reloadData()
            case .failure(let error):
                ProgressHUD.showError(error.localizedDescription)
            }
        }
    }
}
