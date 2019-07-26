//
//  User.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 19/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import CoreLocation

class User: NSObject, MKAnnotation {
    let uid: String
    var name: String
    var fcmToken: String
    var numberOfBooks: Int?
    var books = [Book]()
    var wishes = [Wish]()
    var chats = [Chat]()
    var address: String?
    var location: GeoPoint?

    init(uid: String, name: String, fcmToken: String) {
        self.uid = uid
        self.name = name
        self.fcmToken = fcmToken
    }

    init(from document: DocumentSnapshot) {
        self.uid = document.documentID
        self.name = document.get("name") as? String ?? ""
        self.fcmToken = document.get("fcmToken") as? String ?? ""
        self.numberOfBooks = document.get("numberOfBooks") as? Int
        self.address = document.get("address") as? String
        self.location = document.get("location") as? GeoPoint
    }

    // MKAnnotation properties
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        if let numberOfBooks = numberOfBooks {
            return "\(numberOfBooks) livre" + (numberOfBooks > 1 ? "s" : "")
        }
        return nil
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D.init(latitude: location?.latitude ?? 0,
                                           longitude: location?.longitude ?? 0)
    }
}

extension User: BookManagerInjectable {
    
    func addBook(_ book: Book, completion: @escaping (Error?) -> Void) {
        bookManager.add(book) { error in
            if error == nil {
                self.books.append(book)
            }
            completion(error)
        }
    }
    
    func getBooks(completion: @escaping () -> Void) {
        bookManager.getAll(ownedBy: self) { books in
            self.books = books
            completion()
        }
    }
    
    func removeBook(_ book: Book, completion: @escaping (Error?) -> Void) {
        bookManager.remove(book) { error in
            if error == nil, let index = self.books.firstIndex(of: book) {
                self.books.remove(at: index)
            }
            completion(error)
        }
    }
}

extension User: WishManagerInjectable {
    
    func addWish(_ wish: Wish, completion: @escaping (Error?) -> Void) {
        wishManager.add(wish) { error in
            if error == nil {
                self.wishes.append(wish)
            }
            completion(error)
        }
    }
    
    func getWishes() {
        wishManager.getAll() { wishes in
            self.wishes = wishes
        }
    }
    
    func removeWish(_ wish: Wish, completion: @escaping (Error?) -> Void) {
        wishManager.delete(wish) { error in
            if error == nil, let index = self.wishes.firstIndex(of: wish) {
                self.wishes.remove(at: index)
            }
            completion(error)
        }
    }
    
    func getMatch(with user: User, completion: @escaping (Wish?) -> Void) {
        wishManager.getMatch(with: user) { wish in
            completion(wish)
        }
    }
}


extension User: ChatManagerInjectable {
    
    func newChat(with user: User, completion: @escaping (Error?) -> Void) {
        chatManager.newChat(with: user) { result in
            switch result {
            case .success(let chat):
                self.chats.append(chat)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func getChats(completion: @escaping () -> Void) {
        chatManager.getAll { chats in
            currentUser.chats = chats
            completion()
        }
    }
}
