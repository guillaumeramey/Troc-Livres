//
//  WishlistManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 17/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

class WishlistManager: FirebaseManager {
        
    // If matches are found, return the 1st book
    static func getMatch(with uid: String, completion: @escaping (String?) -> Void) {
        wishlistCollectionGroup
            .whereField("owner", isEqualTo: Persist.uid)
            .whereField("applicant", isEqualTo: uid)
            .order(by: "timestamp")
            .getDocuments { (snapshot, error) in
                guard error == nil else {
                    completion(nil)
                    return
                }
                if let snapshot = snapshot {
                    completion(snapshot.documents.first?.get("bookTitle") as? String)
                    return
                }
                completion(nil)
        }
    }
    
    static func isBookInWishlist(uid: String, _ book: Book, completion: @escaping (Bool) -> Void) {
        guard let id = book.id else { return }
        wishlistCollection.document(uid + id).getDocument { (document, error) in
            if let document = document {
                completion(document.exists)
            }
        }
    }
    
    static func addBookToWishlist(uid: String, _ book: Book, completion: @escaping (Error?) -> Void) {
        guard let id = book.id else { return }
        let data = ["applicant": Persist.uid,
                    "owner": uid,
                    "bookTitle": book.title,
                    "bookId": id,
                    "timestamp": FieldValue.serverTimestamp()] as [String : Any]
        wishlistCollection.document(uid + id).setData(data, completion: { error in
            completion(error)
        })
    }
    
    static func removeBookFromWishlist(uid: String, _ book: Book, completion: @escaping (Error?) -> Void) {
        guard let id = book.id else { return }
        wishlistCollection.document(uid + id).delete { error in
            completion(error)
        }
    }
    
    static func deleteWishlist(completion: @escaping (Error?) -> Void) {
        wishlistCollection.getDocuments { (snapshot, error) in
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
