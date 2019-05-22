//
//  BookViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import ProgressHUD

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

        deleteButton.isHidden = book.uid == Persist.userUID ? false : true
    }

    @IBAction func deleteBook(_ sender: Any) {

        let alert = UIAlertController(title: "Etes-vous sûr de vouloir supprimer ce livre ?", message: "Cette action est irréversible", preferredStyle: .actionSheet)
        let actionDelete = UIAlertAction(title: "Supprimer", style: .destructive, handler: deleteHandler)
        alert.addAction(actionDelete)
        let actionCancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        alert.addAction(actionCancel)

        present(alert, animated: true)
    }

    private func deleteHandler(alert: UIAlertAction) {
        BookManager.deleteBook(book: book)
        self.navigationController?.popViewController(animated: true)
        ProgressHUD.showSuccess("Livre supprimé")
    }
}
