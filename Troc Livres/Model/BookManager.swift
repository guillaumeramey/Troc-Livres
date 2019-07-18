//
//  BookManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 17/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

class BookManager: FirebaseManager {
    
    // Update an existing book's owners or create a new entry
    static func addBook(_ book: Book, completion: @escaping (Error?) -> Void) {
        guard let id = book.id else { return }

        booksCollection.document(id).getDocument { (document, error) in
            let batch = db.batch()
            let bookData: [String : Any]
            if let document = document, document.exists {
                bookData = ["owners": FieldValue.arrayUnion([Persist.uid])]
            } else {
                bookData = ["title": book.title as Any,
                            "authors": book.authors as Any,
                            "description": book.bookDescription as Any,
                            "imageURL": book.imageURL as Any,
                            "language": book.language as Any,
                            "owners": [Persist.uid] as Any]
            }
            batch.setData(bookData, forDocument: booksCollection.document(id), merge: true)
            // Add 1 to the number of books
            batch.updateData(["numberOfBooks": FieldValue.increment(Int64(1))],
                             forDocument: usersCollection.document(Persist.uid))
            batch.commit { error in
                completion(error)
            }
        }
    }
    
    static func getBooks(uid: String, completion: @escaping ([Book]) -> Void) {
        booksCollection.whereField("owners", arrayContains: uid).getDocuments { (snapshot, error) in
            guard error == nil, let snapshot = snapshot else { return }
            var books = [Book]()
            for document in snapshot.documents {
                books.append(Book(from: document))
            }
            completion(books)
        }
    }
    
    static func deleteBook(_ book: Book, completion: @escaping (Error?) -> Void) {
        guard let id = book.id else { return }
        
        wishlistCollectionGroup.whereField("owner", isEqualTo: Persist.uid).whereField("bookId", isEqualTo: id)
            .getDocuments { (snapshot, error) in
                guard error == nil else {
                    completion(error)
                    return
                }
                let batch = db.batch()
                if let snapshot = snapshot {
                    // Remove the book from the users whislists
                    for document in snapshot.documents {
                        batch.deleteDocument(document.reference)
                    }
                }
                // Remove the user from the book's owners
                batch.updateData(["owners": FieldValue.arrayRemove([Persist.uid])],
                                 forDocument: booksCollection.document(id))
                // Substract 1 to the number of books
                batch.updateData(["numberOfBooks": FieldValue.increment(Int64(-1))],
                                 forDocument: usersCollection.document(Persist.uid))
                batch.commit { error in
                    completion(error)
                }
        }
    }
    
    static func deleteBooks(completion: @escaping (Error?) -> Void) {
        getBooks(uid: Persist.uid) { books in
            let batch = db.batch()
            for book in books {
                if let id = book.id {
                    batch.updateData(["owners": FieldValue.arrayRemove([Persist.uid])],
                                     forDocument: booksCollection.document(id))
                }
            }
            batch.commit { error in
                completion(error)
            }
        }
    }
    
    // Delete the user's books in all the wishlists
    static func deleteBooksInWishlists(completion: @escaping (Error?) -> Void) {
        wishlistCollectionGroup.whereField("owner", isEqualTo: Persist.uid).getDocuments { (snapshot, error) in
            guard error == nil else {
                completion(error)
                return
            }
            if let snapshot = snapshot {
                let batch = db.batch()
                for document in snapshot.documents {
                    batch.deleteDocument(document.reference)
                }
                batch.commit { error in
                    completion(error)
                }
            }
        }
    }

}
