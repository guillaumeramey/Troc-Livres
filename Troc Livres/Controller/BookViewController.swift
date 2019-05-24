//
//  BookViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class BookViewController: UIViewController {

    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!

    var book: Book!

    override func viewDidLoad() {
        super.viewDidLoad()

        bookTitle.text = book.title
        author.text = book.author
        condition.text = book.condition
        image.image = UIImage(named: "book")
//        if let url = URL(string: book.image) {
//            image.load(url: url)
//        }

        if book.uid == Auth.auth().currentUser?.uid {
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
    }

    @IBAction func deleteBook(_ sender: Any) {
        let alert = UIAlertController(title: "La suppression d'un livre est définitive et irréversible.", message: nil, preferredStyle: .actionSheet)
        let actionDelete = UIAlertAction(title: "Supprimer", style: .destructive, handler: deleteHandler)
        alert.addAction(actionDelete)
        let actionCancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }

    private func deleteHandler(alert: UIAlertAction) {
        BookManager.deleteBook(book)
        UserManager.modifyNumberOfBooks(.remove)
        self.navigationController?.popViewController(animated: true)
        ProgressHUD.showSuccess("Livre supprimé")
    }
}
