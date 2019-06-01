//
//  AddBookViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class AddBookViewController: UIViewController {

    @IBOutlet var authorTextField: UITextField!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var conditionTextView: UITextView!
    @IBOutlet weak var isbnTextField: UITextField!

    private var scanner = ScannerViewController()
    private var isbn = "" {
        didSet {
            isbnTextField.text = isbn
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        scanner.delegate = self
    }

    private func getBookDetails() {
        //        let bookService = BookService()
        //        bookService.getBook(isbn: isbn) { (result) in
        //            switch result {
        //            case .success(let books):
        //                self.book = books.first?.value
        //                self.updateDisplay()
        //            case .failure(let error):
        //                print("Failure : ", error)
        //            }
        //        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        goBack()
    }

    // Add a book for the current user
    @IBAction func addButtonPressed(_ sender: Any) {
        ProgressHUD.show("Ajout du livre")
        #warning("tester les données saisies")
        let title = titleTextField.text!
        let author = authorTextField.text!
        let condition = conditionTextView.text!
        let book = ["title": title, "author": author, "condition": condition]

        let bookRef = Constants.Firebase.userRef.child("\(Session.user.uid)/books").childByAutoId()
        bookRef.setValue(book) { (error, reference) in
            guard error == nil else {
                ProgressHUD.showError("Erreur lors de l'ajout du livre")
                return
            }
            Session.user.books.append(Book(key: bookRef.key!, title: title, author: author, condition: condition))
            ProgressHUD.showSuccess("Livre ajouté")
            self.goBack()
        }
    }

    private func validateData() {

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanner" {
            let destinationVC = segue.destination as! ScannerViewController
            destinationVC.delegate = self
        }
    }
}

extension AddBookViewController: scanDelegate {

    // Barcode successfully scanned
    func updateIsbn(isbn: String) {
        self.isbn = isbn
    }
}
