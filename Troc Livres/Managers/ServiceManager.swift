//
//  DataManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 02/08/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import CoreLocation

class DependencyInjection {
    
    static let shared = DependencyInjection()
    var serviceManager: DataManager!
}

protocol DataManager {
    
    // MARK: - Account
    
    func signIn(withEmail email: String, password: String, completion: @escaping (String?) -> Void)
    func setToken()
    func signOut()
    func reauthenticate(withPassword password: String, completion: @escaping (Bool) -> Void)
    func resetPassword(withEmail email: String, completion: @escaping (String?) -> Void)
    func createAccount(name: String, email: String, password: String, completion: @escaping (String?) -> Void)
    
    // MARK: - User
    
    func getCurrentUser(completion: @escaping (Bool) -> Void)
    func getUser(uid: String, completion: @escaping (User?) -> Void)
    func getUsers(completion: @escaping ([User]) -> Void)
    func setLocation(address: String, location: CLLocation, completion: @escaping (Bool) -> Void)
    func deleteUser(completion: @escaping (Error?) -> Void)
    func deleteUserBooks(completion: @escaping (Error?) -> Void)
    func deleteUserBooksInWishes(completion: @escaping (Error?) -> Void)
    
    // MARK: - Book
    
    func addBook(_ book: Book, completion: @escaping (Error?) -> Void)
    func getBooks(ownedBy owner: User, completion: @escaping ([Book]) -> Void)
    func removeBook(_ book: Book, completion: @escaping (Error?) -> Void)
    
    // MARK: - Chat
    
    func newChat(with user: User, completion: @escaping (Result<Chat, Error>) -> Void)
    func getChats(completion: @escaping ([Chat]) -> Void)
    func getMessages(in chat: Chat, completion: @escaping ([Message]) -> Void)
    func newMessage(in chat: Chat, content: String, system: Bool, completion: @escaping (Error?) -> Void)
    func markAsRead(_ chat: Chat)
    
    // MARK: - Wishes
    
    func getWishes(completion: @escaping ([Wish]) -> Void)
    func getMatch(with user: User, completion: @escaping (Wish?) -> Void)
    func addWish(_ wish: Wish, completion: @escaping (Error?) -> Void)
    func deleteWish(_ wish: Wish, completion: @escaping (Error?) -> Void)
    func deleteWishes(completion: @escaping (Error?) -> Void)
}
