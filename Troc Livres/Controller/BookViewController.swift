//
//  BookViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class BookViewController: UIViewController {

    var book: Book!

    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var image: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        bookTitle.text = book.title
//        if let url = URL(string: book.image) {
//            image.load(url: url)
//        }
    }
}
