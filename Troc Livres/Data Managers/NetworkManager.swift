//
//  NetworkManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 15/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation

enum NetworkError: String, Error {
    case encodingString = "Caractères interdits"
    case badURL = "Erreur dans la requête"
    case error = "Une erreur est survenue"
    case noData = "Aucune donnée reçue"
    case noResult = "Aucun résultat"
    case noResponse = "Erreur réseau"
}

class NetworkManager {
    private let apiURL = "https://www.googleapis.com/books/v1/volumes?"
    private let apiKey = Constants.valueForAPIKey("API_KEY")
    private var task: URLSessionDataTask!
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getBooks(isbn: String = "", title: String = "", author: String = "", langRestrict: String = "fr", completion: @escaping (Result<[Book], NetworkError>) -> Void) {

        let request = createRequest(isbn: isbn,
                                    title: title.trimmingCharacters(in: CharacterSet(charactersIn: " ")),
                                    author: author.trimmingCharacters(in: CharacterSet(charactersIn: " ")),
                                    langRestrict: langRestrict)

        // remove forbidden characters
        guard
            let encodeString = request.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let url = URL(string: encodeString) else {
                completion(.failure(.badURL))
                return
        }

        task?.cancel()
        task = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    completion(.failure(.noResponse))
                    return
                }
                
                guard error == nil else {
                    completion(.failure(.error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let bookJSON = try JSONDecoder().decode(BookJSON.self, from: data)

                    var items = [Item]()

                    for var item in bookJSON.items {
                        item.volumeInfo.id = item.id
                        items.append(item)
                    }

                    completion(.success(items.map { $0.volumeInfo }))
                } catch {
                    completion(.failure(.noResult))
                }
            }
        }
        task?.resume()
    }
    
    private func createRequest(isbn: String, title: String, author: String, langRestrict: String) -> String {
        var request = apiURL + "key=" + apiKey + "&q="
        if isbn != "" {
            request += "isbn:" + isbn
        } else {
            if title != "" {
                request += "intitle:" + title.replacingOccurrences(of: " ", with: "+intitle:")
            }
            
            if author != "" {
                if title != "" {
                    request += "+"
                }
                request += "inauthor:" + author.replacingOccurrences(of: " ", with: "+inauthor:")
            }
            
            if langRestrict != "" {
                request += "&langRestrict=" + langRestrict
            }
        }
        request += "&fields=items/id,items/volumeInfo(title,authors,description,pageCount,imageLinks/thumbnail,language)"
        
        return request
    }

}
