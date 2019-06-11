//
//  BookViewCell.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 09/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class BookViewCell: UITableViewCell {

    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookImage: UIImageView!

    var book: Book? {
        didSet {
            updateCell()
        }
    }

    private func updateCell() {
        guard let book = book else { return }
        bookTitle.text = book.title
        bookAuthor.text = book.authors?.joined(separator: " & ")
//        bookImage.sd_setImage(with: book.imageRef, placeholderImage: UIImage(named: "Image-Book1"))
        if let imageURL = book.imageURL, let url = URL(string: imageURL) {
            bookImage.load(url: url)
        }
    }
}
