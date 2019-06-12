//
//  BookViewCell.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 09/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import Kingfisher

class BookViewCell: UITableViewCell {

    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookImage: UIImageView!

    var book: Book! {
        didSet {
            resetCell()
            updateCell()
        }
    }

    private func resetCell() {
        bookImage.image = Constants.Image.noBookCover
    }

    private func updateCell() {
        bookTitle.text = book.title
        bookAuthor.text = book.authors?.joined(separator: " & ")
        if let imageURL = book.imageURL, let url = URL(string: imageURL) {
            bookImage.kf.indicatorType = .activity
            bookImage.kf.setImage(with: url)
        }
    }
}
