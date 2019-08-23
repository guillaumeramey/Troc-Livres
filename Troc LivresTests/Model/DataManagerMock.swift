//
//  DataManagerMock.swift
//  Troc LivresTests
//
//  Created by Guillaume Ramey on 04/08/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import CoreLocation

@testable import Troc_Livres

class DataManagerMock: DataManager {
    
    var shouldSucceed: Bool
    
    enum ErrorMock: Error {
        case error
    }
    
    init(shouldSucceed: Bool = true) {
        self.shouldSucceed = shouldSucceed
    }
    
    // MARK: - Account
    
    func signIn(withEmail email: String, password: String, completion: @escaping (String?) -> Void) { }
    
    func setToken() { }
    
    func signOut() { }
    
    func reauthenticate(withPassword password: String, completion: @escaping (Bool) -> Void) { }
    
    func resetPassword(withEmail email: String, completion: @escaping (String?) -> Void) { }
    
    func createAccount(name: String, email: String, password: String, completion: @escaping (String?) -> Void) { }
    
    // MARK: - User
    
    func getCurrentUser(completion: @escaping (Bool) -> Void) {
        if shouldSucceed {
            currentUser = User(uid: "currentUid", name: "currentUser", fcmToken: "currentToken")
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func getUser(uid: String, completion: @escaping (User?) -> Void) {
        if shouldSucceed {
            completion(user1)
        } else {
            completion(nil)
        }
    }
    
    func getUsers(completion: @escaping ([User]) -> Void) {
        if shouldSucceed {
            completion([user1, user2])
        } else {
            completion([])
        }
    }
    
    func setLocation(address: String, location: CLLocation, completion: @escaping (Error?) -> Void) { }

    func deleteUser(completion: @escaping (Error?) -> Void) { }
    
    // MARK: - Books
    
    func deleteUserBooks(completion: @escaping (Error?) -> Void) { }
    
    func deleteUserBooksInWishes(completion: @escaping (Error?) -> Void) { }
    
    func addBook(_ book: Book, completion: @escaping (Error?) -> Void) {
        if shouldSucceed {
            completion(nil)
        } else {
            completion(ErrorMock.error)
        }
    }
    
    func getBooks(ownedBy owner: User, completion: @escaping ([Book]) -> Void) {
        if shouldSucceed {
            completion([book1, book2])
        } else {
            completion([])
        }
    }
    
    func removeBook(_ book: Book, completion: @escaping (Error?) -> Void) {
        if shouldSucceed {
            completion(nil)
        } else {
            completion(ErrorMock.error)
        }
    }
    
    // MARK: - Chat
    
    func newChat(with user: User, completion: @escaping (Result<Chat, Error>) -> Void) {
        if shouldSucceed {
            completion(.success(Chat(with: user)))
        } else {
            completion(.failure(ErrorMock.error))
        }
    }
    
    func getChats(completion: @escaping ([Chat]) -> Void) {
        if shouldSucceed {
            completion([chat1, chat2])
        } else {
            completion([])
        }
    }
    
    func getMessages(in chat: Chat, completion: @escaping ([Message]) -> Void) {
        if shouldSucceed {
            completion([message1, message2])
        } else {
            completion([])
        }
    }
    
    func newMessage(in chat: Chat, content: String, system: Bool, completion: @escaping (Error?) -> Void) { }
    
    func markAsRead(_ chat: Chat) { }
    
    func leaveChat() { }
    
    // MARK: - Wishes
    
    func getWishes(completion: @escaping ([Wish]) -> Void) {
        if shouldSucceed {
            completion([wish1, wish2])
        } else {
            completion([])
        }
    }
    
    func getMatch(with user: User, completion: @escaping (Wish?) -> Void) { }
    
    func addWish(_ wish: Wish, completion: @escaping (Error?) -> Void) {
        if shouldSucceed {
            completion(nil)
        } else {
            completion(ErrorMock.error)
        }
    }
    
    func deleteWish(_ wish: Wish, completion: @escaping (Error?) -> Void) {
        if shouldSucceed {
            completion(nil)
        } else {
            completion(ErrorMock.error)
        }
    }
    
    func deleteWishes(completion: @escaping (Error?) -> Void) { }
}
