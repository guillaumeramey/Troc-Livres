//
//  ChatViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import ProgressHUD

class ChatViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties

    var chat: Chat!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        chat.getUser()
        title = chat.user.name
        hideKeyboardWhenTappedAround()
        setKeyboardNotifications()
        let nib = UINib(nibName: Constants.Cell.message, bundle: nil)
        chatTableView.register(nib, forCellReuseIdentifier: Constants.Cell.message)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        tabBarController?.tabBar.isHidden = true
        chat.markAsRead()
        enterChat()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chat.markAsRead()
        DependencyInjection.shared.dataManager.leaveChat()
        ProgressHUD.dismiss()
    }

    private func enterChat() {
        chat.getMessages { success in
            guard success else { return }
            self.chatTableView.reloadData()
            self.scrollTableViewToBottom()
        }
    }
}

// MARK: - Keyboard management

extension ChatViewController: UITextFieldDelegate {

    // observe when the keyboard shows and hides
    private func setKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func handleKeyboard(_ notification: NSNotification) {
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
        if chat.messages.count > 0 {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.chat.messages.count - 1, section: 0)
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    // Send button action
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard messageTextField.text?.isEmpty == false else { return false }
        chat.newMessage(content: messageTextField.text!) { success in
            if success {
                self.messageTextField.text = nil                
            } else {
                ProgressHUD.showError("Impossible d'envoyer le message")
            }
        }
        return true
    }
}

// MARK: - TableView data source

extension ChatViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.message, for: indexPath) as! MessageCell
        cell.message = chat.messages[indexPath.row]
        return cell
    }
}
