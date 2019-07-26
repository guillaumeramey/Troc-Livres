//
//  ChatManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation

protocol ChatManager {
    func newChat(with user: User, completion: @escaping (Result<Chat, Error>) -> Void)
    func getAll(completion: @escaping ([Chat]) -> Void)
    func getMessages(in chat: Chat, completion: @escaping ([Message]) -> Void)
    func newMessage(in chat: Chat, content: String, system: Bool, completion: @escaping (Error?) -> Void)
    func markAsRead(_ chat: Chat)
}

protocol ChatManagerInjectable {
    var chatManager: ChatManager { get }
}

extension ChatManagerInjectable {
    var chatManager: ChatManager {
        return FirebaseManager()
    }
}
