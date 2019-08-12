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

class SearchBookViewController: UIViewController, ScannerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBackgroundView: UIView!
    @IBOutlet weak var tableViewBackgroundLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    // MARK: - Properties

    var results = [Book]()
    var selectedBook: Book!
    private var backgroundText: String! {
        didSet {
            if backgroundText != nil {
                tableViewBackgroundLabel.text = backgroundText
            } else {
                tableViewBackgroundLabel.text = """
                    Scannez le code-barres

                    - ou -

                    Remplissez les champs de texte
                    """
            }
        }
    }

    // MARK: - Actions

    @IBAction func searchButtonPressed(_ sender: Any) {
        getBooks()
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        searchButton.layer.cornerRadius = 8
        tableView.backgroundView = tableViewBackgroundView
        backgroundText = nil
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: Constants.Cell.book, bundle: nil), forCellReuseIdentifier: Constants.Cell.book)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }

    private func scrollTableViewToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    func getBooks(isbn: String = "") {
        ProgressHUD.show("Recherche en cours")
        backgroundText = ""
        let networkManager = NetworkManager()
        networkManager.getBooks(isbn: isbn, title: titleTextField.text!, author: authorTextField.text!) { result in
            switch result {
            case .success(let books):
                self.results = books
                self.tableView.reloadData()
                self.scrollTableViewToTop()
            case .failure(let error):
                self.results.removeAll()
                self.tableView.reloadData()
                self.tableViewBackgroundLabel.text = error.rawValue
            }
            ProgressHUD.dismiss()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.scannerVC {
            let destinationVC = segue.destination as! ScannerViewController
            destinationVC.delegate = self
        } else if segue.identifier == Constants.Segue.bookVC {
            let destinationVC = segue.destination as! BookViewController
            destinationVC.book = selectedBook
            destinationVC.bookOwner = currentUser
        }
    }
}

extension SearchBookViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.book, for: indexPath) as! BookCell
        cell.book = results[indexPath.row]
        return cell
    }
}

extension SearchBookViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedBook = results[indexPath.row]
        performSegue(withIdentifier: Constants.Segue.bookVC, sender: self)
    }
}
