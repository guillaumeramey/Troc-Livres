//
//  ChatViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties

    var contact: Contact!
    var messages = [Message]()

    private let cellId = "chatCell"

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        title = contact.name
        hideKeyboardWhenTappedAround()
        keyboardNotifications()
        chatTableView.register(UINib(nibName: "ChatViewCell", bundle: nil), forCellReuseIdentifier: cellId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        contact.markAsRead()
        enterChat()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contact.markAsRead()
        FirebaseManager.leaveChat()
    }

    private func enterChat() {
        FirebaseManager.enterChat(withUid: contact.uid) { messages in
            self.messages = messages
            self.chatTableView.reloadData()
            self.scrollTableViewToBottom()
        }
    }
}

// MARK: - Keyboard management

extension ChatViewController: UITextFieldDelegate {

    // observe when the keyboard shows and hides
    private func keyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func handleKeyboard(_ notification: NSNotification) {

        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            bottomConstraint.constant = keyboardFrame.cgRectValue.height
        }

        // the bottom is different between phones
        if #available(iOS 11.0, *) {
            bottomConstraint.constant -=  view.safeAreaInsets.bottom
        }

        if notification.name == UIResponder.keyboardWillHideNotification {
            bottomConstraint.constant = 0
        }

        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { completed in
            self.scrollTableViewToBottom()
        }
    }

    private func scrollTableViewToBottom() {
        if messages.count > 0 {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    // Send button action
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard messageTextField.text != "" else { return false }
        _ = Message(messageTextField.text!, to: contact)
        messageTextField.text = nil
        return true
    }
}

// MARK: - TableView data source

extension ChatViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatViewCell
        cell.set(with: messages[indexPath.row])
        return cell
    }
}
