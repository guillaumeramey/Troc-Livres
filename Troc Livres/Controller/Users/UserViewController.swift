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
    @IBOutlet weak var booksCollectionView: UICollectionView!

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        title = user.name
        image.sd_setImage(with: user.imageRef, placeholderImage: UIImage(named: "Image-User"))
        image.layer.cornerRadius = 8
        image.contentMode = .scaleAspectFill

        booksCollectionView.register(UINib(nibName: "UserBookCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
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

extension UserViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user == nil ? 0 : user.books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserBookCollectionViewCell
        cell.set(book: user.books[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedBook = user.books[indexPath.row]
        performSegue(withIdentifier: "bookDetail", sender: self)
    }
}
