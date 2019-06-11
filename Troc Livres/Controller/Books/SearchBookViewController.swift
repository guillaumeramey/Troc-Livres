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

    @IBOutlet var authorTextField: UITextField!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet weak var isbnTextField: UITextField!

    private var isbn = "" {
        didSet {
            isbnTextField.text = isbn
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        goBack()
    }


    private func validateData() {
        #warning("tester les données saisies")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanner" {
            let scannerVC = segue.destination as! ScannerViewController
            scannerVC.delegate = self
        }
        if segue.identifier == "searchBook" {
            let searchBookVC = segue.destination as! SearchResultViewController
            searchBookVC.bookTitle = titleTextField.text!
            searchBookVC.bookAuthor = authorTextField.text!
        }
    }
}

extension SearchBookViewController: ScannerDelegate {

    // Barcode successfully scanned
    func updateIsbn(isbn: String) {
        self.isbn = isbn
    }
}
