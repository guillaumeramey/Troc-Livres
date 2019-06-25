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

    @IBOutlet var labels: [PaddingLabel]!
    @IBOutlet weak var titleLabel: PaddingLabel!
    @IBOutlet weak var authorLabel: PaddingLabel!
    @IBOutlet weak var descriptionLabel: PaddingLabel!
    @IBOutlet weak var imageView: UIImageView!

    // MARK: - Properties

    var book: Book!
    var user: User!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setLabelsDesign()
        setRightBarButton()
        setBookData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func setLabelsDesign() {
        for label in labels {
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
        }
    }

    private func setBookData() {
        titleLabel.text = book.title
        authorLabel.text = book.authors?.joined(separator: "\n")
        descriptionLabel.text = book.bookDescription
        if let imageURL = book.imageURL, let url = URL(string: imageURL) {
            imageView.kf.setImage(with: url)
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

//            let buttonImage: UIImage!
//
//            if let applicants = book.applicants, applicants.contains(Session.user.uid) {
//                buttonImage = Constants.Image.starTrue
//            } else {
//                buttonImage = Constants.Image.starFalse
//            }
//
//            navigationItem.rightBarButtonItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(starTapped))

            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(starTapped))
        }
    }

    // MARK: - Actions

    // Add the book to the user's collection
    @objc func addTapped(_ sender: Any) {
//        guard book.id != nil else { return }

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

    // Remove the book from the user's collection
    @objc func trashTapped(_ sender: Any) {
        let alert = UIAlertController(title: "La suppression d'un livre est définitive et irréversible.", message: nil, preferredStyle: .actionSheet)
        let actionDelete = UIAlertAction(title: "Supprimer", style: .destructive, handler: deleteHandler)
        alert.addAction(actionDelete)
        let actionCancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }

    private func deleteHandler(alert: UIAlertAction) {
        FirebaseManager.deleteBook(book) { result in
            switch result {
            case .success(_):
                Session.user.books.removeAll(where: { $0.id == self.book.id })
                ProgressHUD.showSuccess("Livre supprimé")
                self.performSegue(withIdentifier: "unwindToMyBooks", sender: self)
            case .failure(let error):
                print(error.localizedDescription)
                ProgressHUD.showError("Echec de la suppression du livre")
            }
        }
    }

    // Send a message to the owner of the book
    @objc func starTapped(_ sender: Any) {
        // Check if this user wants one of my books
        FirebaseManager.getMatches(uid: user.uid) { book in
            if book.isEmpty {
                // No match, add the book to wishlist
                FirebaseManager.addBookToWishlist(uid: self.user.uid, self.book)
            } else {
                self.alert(title: "Match !!", message: "Cet utilisateur veut également un livre à vous : \"\(book)\"")
            }
        }
    }
}
