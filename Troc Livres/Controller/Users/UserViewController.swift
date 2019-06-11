//
//  UserViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 19/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    // MARK: - Properties

    var user: User!
    var books = [Book]()
    var selectedBook: Book!
    private let cellId = "bookCell"

    // MARK: - Outlets

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var booksTableView: UITableView!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = user.name
        image.sd_setImage(with: user.imageRef, placeholderImage: UIImage(named: "Image-User"))
        image.layer.cornerRadius = 8
        image.contentMode = .scaleAspectFill

        booksTableView.register(UINib(nibName: "BookViewCell", bundle: nil), forCellReuseIdentifier: cellId)

    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookDetail" {
            let bookVC = segue.destination as! BookViewController
            bookVC.book = selectedBook
            bookVC.user = user
        }
    }
}

extension UserViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user == nil ? 0 : user.books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BookViewCell
        cell.book = user.books[indexPath.row]
        return cell
    }
}

extension UserViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedBook = user.books[indexPath.row]
        performSegue(withIdentifier: "bookDetail", sender: self)
    }
}
