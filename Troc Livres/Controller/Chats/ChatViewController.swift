//
//  ChatViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class ChatViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties

    var chat: Chat!
    private var messages = [Message]()
    private var user: User!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setTitle()
        setKeyboardNotifications()
        chatTableView.register(UINib(nibName: Constants.Cell.message, bundle: nil), forCellReuseIdentifier: Constants.Cell.message)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true
        FirebaseManager.markChatAsRead(id: chat.id)
        enterChat()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirebaseManager.markChatAsRead(id: chat.id)
        FirebaseManager.leaveChat()
    }

    private func setTitle() {
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.setTitle(chat.name, for: .normal)
        button.setTitleColor(Constants.Color.button, for: .normal)
        button.addTarget(self, action: #selector(titleButtonPressed), for: .touchUpInside)
        navigationItem.titleView = button
    }

    @objc private func titleButtonPressed() {
        ProgressHUD.show()
        FirebaseManager.getUser(withUid: chat.uid, completion: { user in
            if let user = user {
                ProgressHUD.dismiss()
                self.user = user
                self.performSegue(withIdentifier: Constants.Segue.userTableVC, sender: self)
            } else {
                ProgressHUD.showError("Impossible de récupérer les données de l'utilisateur")
            }
        })
    }

    private func enterChat() {
        FirebaseManager.getMessages(in: chat) { messages in
            self.messages = messages
            self.chatTableView.reloadData()
            self.scrollTableViewToBottom()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.userTableVC {
            let destinationVC = segue.destination as! UserTableViewController
            destinationVC.user = user
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
        if messages.count > 0 {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    // Send button action
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard messageTextField.text?.isEmpty == false else { return false }
        FirebaseManager.sendMessage(in: chat, content: messageTextField.text!)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.message, for: indexPath) as! MessageViewCell
        cell.message = messages[indexPath.row]
        return cell
    }
}
