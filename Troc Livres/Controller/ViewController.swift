//
//  ViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 15/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class ViewController: UIViewController, scanDelegate {

    func updateIsbn(isbn: String) {
        isbnInput.text = isbn
        print(isbn)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanner" {
            let destinationVC = segue.destination as! ScannerViewController
            destinationVC.delegate = self
        }
    }

    @IBOutlet var author: UILabel!
    @IBOutlet var bookTitle: UILabel!
    @IBOutlet weak var isbnInput: UITextField!

    private var scanner = ScannerViewController()

    private var isbn = ""
    private var book: Book!

    override func viewDidLoad() {
        super.viewDidLoad()

        scanner.delegate = self

    }

    private func getBook() {
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

    @IBAction func addButtonPressed(_ sender: Any) {
//        isbn = isbnInput.text!
//        getBook()
    }

    private func updateDisplay() {
//        bookTitle.text = book.title
//        author.text = book.authors[0].name
    }

}
