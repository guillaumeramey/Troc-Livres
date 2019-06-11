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
    @IBOutlet weak var addBookButton: UIButton!
    @IBOutlet weak var deleteBookButton: UIButton!
    @IBOutlet weak var contactUserStackView: UIStackView!
    
    var book: Book!
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        bookTitle.text = book.title
        author.text = book.authors?.joined(separator: " & ")

        if let imageURL = book.imageURL, let url = URL(string: imageURL) {
            image.load(url: url)
        }

        // Different actions depending if the book belongs to the user
        contactUserStackView.isHidden = user.uid == Session.user.uid ? true : false

        if user.uid == Session.user.uid {
            if user.books.contains(where: { $0.id == book.id }) {
                addBookButton.isHidden = true
                deleteBookButton.isHidden = false
            } else {
                addBookButton.isHidden = false
                deleteBookButton.isHidden = true
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: - Actions

    @IBAction func deleteBookButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "La suppression d'un livre est définitive et irréversible.", message: nil, preferredStyle: .actionSheet)
        let actionDelete = UIAlertAction(title: "Supprimer", style: .destructive, handler: deleteHandler)
        alert.addAction(actionDelete)
        let actionCancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }

    private func deleteHandler(alert: UIAlertAction) {
        Session.user.deleteBook(key: book.id)
        ProgressHUD.showSuccess("Livre supprimé")
        self.goBack()
    }

    // Write a message to another user for the book
    @IBAction func contactUserButtonPressed(_ sender: Any) {
        _ = Message("Bonjour ! Je suis intéressé(e) par \"\(book.title ?? "Erreur de titre")\"", to: Contact(with: user))
        #warning("Gérer les erreurs d'envoi")
        alert(title: "Message envoyé !", message: "Retrouvez cette discussion dans l'onglet Contacts")
    }

    // Add the book to the current user's collection
    @IBAction func addBookButtonPressed(_ sender: Any) {
        guard book.id != nil else { return }

        ProgressHUD.show("Ajout du livre")

        FirebaseManager.addBook(book) { result in
            switch result {
            case .success(_):
                Session.user.books.append(self.book)
                ProgressHUD.showSuccess("Livre ajouté")
                self.performSegue(withIdentifier: "unwindToMyBooks", sender: self)
            case .failure(let error):
                print(error.localizedDescription)
                ProgressHUD.showError("Echec d'ajout du livre")
            }
        }
    }
}
