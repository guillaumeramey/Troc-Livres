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

    // MARK: - Outlets

    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var image: UIImageView!

    // MARK: - Properties

    var book: Book!
    var user: User!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setRightBarButton()
        displayBookDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func displayBookDetails() {
        bookTitle.text = book.title
        author.text = book.authors?.joined(separator: " & ")
        bookDescription.text = book.bookDescription

        if let imageURL = book.imageURL, let url = URL(string: imageURL) {
            image.kf.setImage(with: url)
        }
    }

    // Different buttons depending if the book belongs to the user
    private func setRightBarButton() {
        if user.uid == Session.user.uid {
            if user.books.contains(where: { $0.id == book.id }) {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
                navigationItem.rightBarButtonItem?.tintColor = .red
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            }
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeTapped))
        }
    }

    // MARK: - Actions

    // Add the book to the user's collection
    @objc func addTapped(_ sender: Any) {
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

    // Delte the book from the user's collection
    @objc func trashTapped(_ sender: Any) {
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

    // Send a message to the owner of the book
    @objc func composeTapped(_ sender: Any) {
        _ = Message("Bonjour ! Je suis intéressé(e) par \"\(book.title ?? "Erreur de titre")\"", to: Contact(with: user))
        #warning("Gérer les erreurs d'envoi")
        alert(title: "Message envoyé !", message: "Retrouvez cette discussion dans l'onglet Contacts")
    }

}
