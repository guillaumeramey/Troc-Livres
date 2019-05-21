//
//  NewsViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 18/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController {

    // MARK: - PROPERTIES
    private var tableViewData = [Book]()
    private var selectedBook: Book!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        let book = tableViewData[indexPath.row]
        cell.textLabel?.text = book.title
        cell.detailTextLabel?.text = book.author
        return cell
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = tableViewData[indexPath.row]
        performSegue(withIdentifier: "fromNewsToBook", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromNewsToBook" {
            let bookVC = segue.destination as! BookViewController
            bookVC.book = selectedBook
        }
    }
}
