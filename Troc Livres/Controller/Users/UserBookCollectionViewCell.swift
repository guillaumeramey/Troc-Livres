//
//  UserBookCollectionViewCell.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 04/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class UserBookCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookImage: UIImageView!

    func set(book: Book) {
        bookTitle.text = book.title
        bookAuthor.text = book.author
        let imageRef = FirebaseManager.imageRef.child("books/\(book.key).jpg")
        bookImage.sd_setImage(with: imageRef, placeholderImage: UIImage(named: "Image-Book1"))
        bookImage.layer.cornerRadius = 8
    }
}
