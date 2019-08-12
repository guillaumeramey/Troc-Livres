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
    var bookOwner: User!
    private var imageData: Bool!
    private var rightBarButton: UIBarButtonItem!
    private var bookIsAWish: Bool! {
        didSet {
            rightBarButton.image = bookIsAWish ? Constants.Image.starFill : Constants.Image.star
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
            imageData = imageView.image?.pngData()?.base64EncodedString() != Constants.noImageData
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Don't display the image if unavailable
        if section == 0 {
            guard let imageURL = book.imageURL, imageURL != "" else {
                return 0
            }
            guard imageData else {
                return 0
            }
        }
        return 1
    }

    // Different buttons depending if the book belongs to the user
    private func setRightBarButton() {
        if bookOwner.uid == currentUser.uid {
            currentUser.books.contains(book) ? setTrashButton() : setAddButton()
        } else {
            setStarButton()
        }
        navigationItem.rightBarButtonItem = rightBarButton
    }

    private func setAddButton() {
        rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }

    private func setTrashButton() {
        rightBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
        rightBarButton.tintColor = .red
    }

    private func setStarButton() {
        rightBarButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(starTapped))
        let wish = Wish(owner: bookOwner, book: book)
        self.bookIsAWish = currentUser.wishes.contains(wish)
    }

    // MARK: - Actions

    // Add the book to the user's collection
    @objc func addTapped(_ sender: Any) {
        ProgressHUD.show("Ajout du livre")
        currentUser.addBook(book) { error in
            if let error = error {
                print(error.localizedDescription)
                ProgressHUD.showError("Impossible d'ajouter le livre")
                return
            }
            ProgressHUD.showSuccess("Livre ajouté")
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
        currentUser.removeBook(book) { error in
            if let error = error {
                print(error.localizedDescription)
                ProgressHUD.showError("Impossible de supprimer le livre")
                return
            }
            ProgressHUD.showSuccess("Livre supprimé")
            self.performSegue(withIdentifier: "unwindToUserBooks", sender: self)
        }
    }
    
    // Add or remove the book from the wishes
    @objc func starTapped(_ sender: Any) {
        rightBarButton.isEnabled = false
        let wish = Wish(owner: bookOwner, book: book)
        bookIsAWish ? removeWish(wish) : addWish(wish)
    }
    
    private func addWish(_ wish: Wish) {
        currentUser.addWish(wish) { error in
            if let error = error {
                print(error.localizedDescription)
                ProgressHUD.showError("Impossible d'ajouter le livre à votre liste de souhaits")
            } else {
                self.bookIsAWish.toggle()
                self.getMatch()
            }
            self.rightBarButton.isEnabled = true
            
            NetworkManager().registerForPushNotifications()
        }
    }
    
    private func removeWish(_ wish: Wish) {
        currentUser.removeWish(wish) { error in
            if let error = error {
                print(error.localizedDescription)
                ProgressHUD.showError("Impossible de supprimer le livre de votre liste de souhaits")
            } else {
                self.bookIsAWish.toggle()
            }
            self.rightBarButton.isEnabled = true
        }
    }
    
    // Check if this user wants one of the current user's books
    private func getMatch() {
        DependencyInjection.shared.dataManager.getMatch(with: bookOwner) { wish in
            guard let wish = wish else { return }
            self.createMessage(for: wish)
        }
    }
    
    private func createMessage(for wish: Wish) {
        
        let message = "\"\(wish.book.title)\" contre \"\(book.title)\""
        
        // Create a new chat if it does not exist
        let index = currentUser.chats.firstIndex(where: { $0.user == bookOwner })
        if let index = index {
            self.sendMessage(message, in: currentUser.chats[index])
        } else {
            currentUser.newChat(with: self.bookOwner, completion: { error in
                if let error = error {
                    print(error.localizedDescription)
                    ProgressHUD.showError("Impossible de créer une discussion avec \(self.bookOwner.name)")
                } else {
                    self.sendMessage(message, in: currentUser.chats.last)
                }
            })
        }
    }
    
    private func sendMessage(_ message: String, in chat: Chat?) {
        guard let chat = chat else { return }
        chat.newMessage(content: message, system: true) { success in
            if success {
                let alertTitle = "Troc disponible !"
                let alertMessage = "\(self.bookOwner.name) veut également un de vos livres. Une discussion a été créée pour vous permettre de les échanger."
                self.alert(title: alertTitle, message: alertMessage)
                self.tabBarController?.tabBar.items?[1].badgeValue = "!"
            } else {
                ProgressHUD.showError("Erreur lors de la création du troc")
            }
        }
    }
}
