//
//  NetworkManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 15/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import UserNotifications

enum NetworkError: String, Error {
    case encodingString = "network error encodingString"
    case badURL = "network error badURL"
    case error = "unknown error"
    case noData = "network error noData"
    case noResult = "network error noResult"
    case noResponse = "network error noResponse"
}

class NetworkManager: NSObject {

    private var task: URLSessionDataTask!
    private let session: URLSession
    private let booksURL = "https://www.googleapis.com/books/v1/volumes?"
    private let booksKey = Constants.valueForAPIKey("API_KEY")
    private let pushURL = URL(string: "https://fcm.googleapis.com/fcm/send")!
    private let pushKey = "AAAA8TOxNeI:APA91bF3yijB0uC4yn5WMtn8xwO9bdoeTf-GtFJRcH7lzE50kidIjKFmIfexUhv1kddxQ73rrSeFJPPJ8WtgHciv_f9tPYQAiANo4scLv8rL9BPhcVN8Ym2rBkVrQR5kEimdyAFl1x5c"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

// MARK: - Books API

extension NetworkManager {
    
    func getBooks(isbn: String = "", title: String = "", author: String = "", completion: @escaping (Result<[Book], NetworkError>) -> Void) {

        let query = createBookQuery(
            isbn: isbn,
            title: title.trimmingCharacters(in: CharacterSet(charactersIn: " ")),
            author: author.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        )

        // remove forbidden characters
        guard
            let encodeString = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let queryURL = URL(string: encodeString) else {
                completion(.failure(.badURL))
                return
        }

        task?.cancel()
        task = session.dataTask(with: queryURL) { (data, response, error) in
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
    
    private func createBookQuery(isbn: String, title: String, author: String) -> String {
        var query = booksURL + "key=" + booksKey + "&q="

        if isbn != "" {
            query += "isbn:" + isbn
        } else {
            if title != "" {
                query += "intitle:" + title.replacingOccurrences(of: " ", with: "+intitle:")
            }
            
            if author != "" {
                if title != "" {
                    query += "+"
                }
                query += "inauthor:" + author.replacingOccurrences(of: " ", with: "+inauthor:")
            }
            
            if Persist.preferredLanguage, let languageCode = Locale.current.languageCode {
                query += "&langRestrict=" + languageCode
            }
        }
        query += "&fields=items/id,items/volumeInfo(title,authors,description,pageCount,imageLinks/thumbnail,language)"
        
        return query
    }
}

// MARK: - Push notifications

extension NetworkManager: UNUserNotificationCenterDelegate {
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: {_, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        DependencyInjection.shared.dataManager.setToken()
    }
    
    func sendPushNotification(to token: String, title: String, body: String) {
        let notification: [String : Any] = [
            "to" : token,
            "notification" : ["title" : title, "body" : body, "badge" : 1, "sound": "default", "vibrate" : 1]
        ]
        
        var request = URLRequest(url: pushURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: notification, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(pushKey)", forHTTPHeaderField: "Authorization")
        
        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
        task.resume()
    }
}
