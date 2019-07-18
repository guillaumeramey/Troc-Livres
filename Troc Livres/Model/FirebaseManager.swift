//
//  FirebaseManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 05/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class FirebaseManager {
    
    static let db = Firestore.firestore()
    static let usersCollection = db.collection("users")
    static let chatsCollection = db.collection("chats")
    static let booksCollection = db.collection("books")
    static let wishlistCollection = usersCollection.document(Persist.uid).collection("wishlist")
    static let wishlistCollectionGroup = db.collectionGroup("wishlist")
    
    static func getErrorMessage(from error: Error) -> String {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            switch errorCode {
            case .invalidEmail:
                return "E-mail invalide"
            case .emailAlreadyInUse:
                return "E-mail déjà utilisé"
            case .userNotFound:
                return "Utilisateur introuvable"
            case .networkError:
                return "Problème de connexion"
            case .wrongPassword:
                return "Mot de passe incorrect"
            default:
                return "Error \(errorCode.rawValue): \(error.localizedDescription)"
            }
        }
        return "Erreur inconnue"
    }
}
