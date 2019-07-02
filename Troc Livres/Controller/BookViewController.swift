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

protocol BookDelegate {
    func updateBooks(_ books: [Book])
}

class BookViewController: UITableViewController {

    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCell: UITableViewCell!
    
    // MARK: - Properties

    var delegate: BookDelegate?
    var book: Book!
    var books: [Book]!
    var user: User!
    private var rightBarButton: UIBarButtonItem!
    private var bookIsInWishlist: Bool! {
        didSet {
            rightBarButton.image = bookIsInWishlist ? Constants.Image.starFill : Constants.Image.star
        }
    }

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setRightBarButton()
        setBookData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setBookData() {
        titleLabel.text = book.title
        authorLabel.text = book.authors?.joined(separator: "\n")
        descriptionLabel.text = book.bookDescription == nil ?
            "Non disponible" :
            book.bookDescription
        if let imageURL = book.imageURL, imageURL != "", let url = URL(string: imageURL) {
            imageView.kf.setImage(with: url)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            guard let imageURL = book.imageURL, imageURL != "" else { return 0 }
        }
        return 1
    }

    // Different buttons depending if the book belongs to the user
    private func setRightBarButton() {
        if user == nil {
            if books.contains(where: { $0.id == book.id }) {
                rightBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
                rightBarButton.tintColor = .red
            } else {
                rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            }
        } else {
            rightBarButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(starTapped))
            FirebaseManager.isBookInWishlist(uid: user.uid, book, completion: { (bookIsInWishlist) in
                self.bookIsInWishlist = bookIsInWishlist
            })
        }
        navigationItem.rightBarButtonItem = rightBarButton
    }

    // MARK: - Actions

    // Add the book to the user's collection
    @objc func addTapped(_ sender: Any) {
        ProgressHUD.show("Ajout du livre")
        FirebaseManager.addBook(book) { result in
            switch result {
            case .success(_):
                ProgressHUD.showSuccess("Livre ajouté")
                self.books.append(self.book)
                self.delegate?.updateBooks(self.books)
                self.performSegue(withIdentifier: "unwindToMyBooks", sender: self)
            case .failure(let error):
                print(error.localizedDescription)
                ProgressHUD.showError("Echec de l'ajout du livre")
            }
        }
    }

    // Remove the book from the user's collection
    @objc func trashTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionDelete = UIAlertAction(title: "Supprimer le livre", style: .destructive, handler: deleteHandler)
        alert.addAction(actionDelete)
        let actionCancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }

    private func deleteHandler(alert: UIAlertAction) {
        ProgressHUD.show("Suppression du livre")
        FirebaseManager.deleteBook(book) { result in
            switch result {
            case .success(_):
                ProgressHUD.showSuccess("Livre supprimé")
                self.books.removeAll(where: { $0.id == self.book.id })
                self.delegate?.updateBooks(self.books)
                self.performSegue(withIdentifier: "unwindToMyBooks", sender: self)
            case .failure(let error):
                print(error.localizedDescription)
                ProgressHUD.showError("Echec de la suppression du livre")
            }
        }
    }
    
    // Add or remove the book from the wishlist
    @objc func starTapped(_ sender: Any) {
        bookIsInWishlist.toggle()
        if bookIsInWishlist {
            FirebaseManager.addBookToWishlist(uid: user.uid, book)
            getMatch()
        } else {
            FirebaseManager.removeBookFromWishlist(uid: user.uid, book)
        }
    }
    
    // Check if this user wants one of the current user's books
    private func getMatch() {
        FirebaseManager.getMatch(with: user.uid) { book in
            if book.isEmpty == false {
                // Create a chat or reuse existing one
                FirebaseManager.getChat(with: self.user, completion: { result in
                    switch result {
                    case .success(let chat):
                        FirebaseManager.sendMessage(in: chat, content: "Message automatique pour un troc : \"\(book)\" contre \"\(self.book.title ?? "")\"", system: true)
                        self.alert(title: "Troc disponible !", message: "\(self.user.name) veut également votre livre : \"\(book)\". Une discussion a été créée pour vous permettre de les échanger.")
                        self.tabBarController?.tabBar.items?[1].badgeValue = "!"
                    case .failure(let error):
                        print(error.localizedDescription)
                        ProgressHUD.showError("Impossible de créer une discussion avec \(self.user.name)")
                    }
                })
            }
        }
    }
}
