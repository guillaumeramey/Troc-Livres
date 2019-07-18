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

class BookViewController: UITableViewController {

    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCell: UITableViewCell!
    
    // MARK: - Properties

    var book: Book!
    var userBooks: [Book]!
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
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setBookData() {
        titleLabel.text = book.title
        if let authors = book.authors {
            authorLabel.text = authors.joined(separator: "\n")
        } else {
            authorLabel.text = "Non disponible"
        }
        if let description = book.bookDescription {
            descriptionLabel.text = description
        } else {
            descriptionLabel.text = "Non disponible"
        }
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
            if userBooks.contains(where: { $0.id == book.id }) {
                rightBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
                rightBarButton.tintColor = .red
            } else {
                rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            }
        } else {
            rightBarButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(starTapped))
            WishlistManager.isBookInWishlist(uid: user.uid, book) { bookIsInWishlist in
                self.bookIsInWishlist = bookIsInWishlist
            }
        }
        navigationItem.rightBarButtonItem = rightBarButton
    }

    // MARK: - Actions

    // Add the book to the user's collection
    @objc func addTapped(_ sender: Any) {
        ProgressHUD.show("Ajout du livre")
        BookManager.addBook(book) { error in
            if let error = error {
                print(error.localizedDescription)
                ProgressHUD.showError("Impossible d'ajouter le livre")
                return
            }
            ProgressHUD.showSuccess("Livre ajouté")
            self.userBooks.append(self.book)
            self.performSegue(withIdentifier: "unwindToUserBooks", sender: self)
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
        BookManager.deleteBook(book) {  error in
            if let error = error {
                print(error.localizedDescription)
                ProgressHUD.showError("Impossible de supprimer le livre")
                return
            }
            ProgressHUD.showSuccess("Livre supprimé")
            self.userBooks.removeAll(where: { $0.id == self.book.id })
            self.performSegue(withIdentifier: "unwindToUserBooks", sender: self)
        }
    }
    
    // Add or remove the book from the wishlist
    @objc func starTapped(_ sender: Any) {
        rightBarButton.isEnabled = false
        if bookIsInWishlist {
            WishlistManager.removeBookFromWishlist(uid: user.uid, book) { error in
                if let error = error {
                    print(error.localizedDescription)
                    ProgressHUD.showError("Impossible de supprimer le livre de votre liste de souhaits")
                } else {
                    self.bookIsInWishlist.toggle()
                }
                self.rightBarButton.isEnabled = true
            }
        } else {
            WishlistManager.addBookToWishlist(uid: user.uid, book) { error in
                if let error = error {
                    print(error.localizedDescription)
                    ProgressHUD.showError("Impossible d'ajouter le livre à votre liste de souhaits")
                } else {
                    self.bookIsInWishlist.toggle()
                    self.getMatch()
                }
                self.rightBarButton.isEnabled = true
                
                PushNotificationManager().registerForPushNotifications()
            }
        }
    }
    
    // Check if this user wants one of the current user's books
    private func getMatch() {
        WishlistManager.getMatch(with: user.uid) { bookTitle in
            guard let bookTitle = bookTitle, bookTitle != "" else { return }
            // Create a chat or reuse existing one
            ChatManager.getChat(with: self.user) { result in
                switch result {
                case .success(let chat):
                    let message = "\(bookTitle)\" contre \"\(self.book.title)\""
                    chat.sendMessage(content: message, system: true) { success in
                        if success {
                            self.alert(title: "Troc disponible !", message: "\(self.user.name) veut également votre livre : \"\(bookTitle)\". Une discussion a été créée pour vous permettre de les échanger.")
                            self.tabBarController?.tabBar.items?[1].badgeValue = "!"
                        } else {
                            ProgressHUD.showError("Erreur lors de la création du troc")
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    ProgressHUD.showError("Impossible de créer une discussion avec \(self.user.name)")
                }
            }
        }
    }
}
