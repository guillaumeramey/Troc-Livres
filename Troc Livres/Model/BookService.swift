//
//  BookService.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 15/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case error
    case noData
    case jsonKO
}

class BookService {
//    private let apiURL = "https://openlibrary.org/api/books?"
//    private var task: URLSessionDataTask!
//    private var bookSession = URLSession.init(configuration: .default)
//
//    func getBook(isbn: String, completion: @escaping (Result<[String: Book], NetworkError>) -> Void) {
//
//        let urlString = apiURL
//            + "bibkeys="
//            + "ISBN:" + isbn
//            + "&jscmd=data"
//            + "&format=json"
//
//        guard let url = URL(string: urlString) else {
//            completion(.failure(.badURL))
//            return
//        }
//
//        task?.cancel()
//        task = bookSession.dataTask(with: url) { (data, response, error) in
//            DispatchQueue.main.async {
//                if error != nil {
//                    completion(.failure(.error))
//                    return
//                }
//
//                guard let data = data else {
//                    completion(.failure(.noData))
//                    return
//                }
//
//                do {
//                    let books = try JSONDecoder().decode([String: Book].self, from: data)
//                    completion(.success(books))
//                } catch {
//                    completion(.failure(.jsonKO))
//                }
//            }
//        }
//        task?.resume()
//    }
}
