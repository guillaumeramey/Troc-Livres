//
//  ChatManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 17/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

protocol <#name#> {
    <#requirements#>
}

class FChatManager: FirebaseManager {
    
    private func createChat(id: String, with user: User, completion: @escaping (Result<Chat, Error>) -> Void) {
        let user1Data = ["name": user.name,
                         "uid": user.uid,
                         "unread": false,
                         "fcmToken": user.fcmToken] as [String : Any]
        let user2Data = ["name": Persist.name,
                         "uid": Persist.uid,
                         "unread": true,
                         "fcmToken": Messaging.messaging().fcmToken as Any] as [String : Any]
        let chatData = ["users": [Persist.uid, user.uid],
                        "timestamp": FieldValue.serverTimestamp(),
                        Persist.uid: user1Data,
                        user.uid: user2Data] as [String : Any]
        
        chatsCollection.document(id).setData(chatData, completion: { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(Chat(id: id, with: user)))
            }
        })
    }
    
    // the current user chats
    func getUserChats(completion: @escaping ([Chat]) -> Void) {
        chatsCollection
            .whereField("users", arrayContains: Persist.uid)
            .order(by: "timestamp", descending: true)
            .getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                var chats = [Chat]()
                for document in snapshot.documents {
                    chats.append(Chat(from: document))
                }
                completion(chats)
        }
    }
    
    func getChat(with user: User, completion: @escaping (Result<Chat, Error>) -> Void) {
        // Unique chat id between 2 users
        let chatId = Persist.uid < user.uid ? Persist.uid + user.uid : user.uid + Persist.uid
        
        chatsCollection.document(chatId).getDocument { (document, error) in
            if let document = document, document.exists {
                completion(.success(Chat(from: document)))
            } else {
                createChat(id: chatId, with: user, completion: { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let chat):
                        completion(.success(chat))
                    }
                })
            }
        }
    }
    
    var chatListener: ListenerRegistration!
    
    func getMessages(in chat: Chat, completion: @escaping ([Message]) -> Void) {
        chatListener = chatsCollection.document(chat.id).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                var messages = [Message]()
                for document in snapshot.documents {
                    messages.append(Message(from: document))
                }
                completion(messages)
        }
    }
    
    func leaveChat() {
        chatListener.remove()
    }
    
    func sendMessage(in chat: Chat, content: String, system: Bool, completion: @escaping (Error?) -> Void) {
        let document = chatsCollection.document(chat.id)
        let message = ["content": content,
                       "sender": system ? "system" : Persist.uid,
                       "timestamp": FieldValue.serverTimestamp() as Any]
        let batch = db.batch()
        batch.setData(message, forDocument: document.collection("messages").document())
        
        // mark the chat as unread for the receiver
        batch.updateData(["\(chat.uid).unread": true], forDocument: document)
        
        // send notification
        let sender = PushNotificationSender()
        let notificationTitle = system ? "Nouveau troc !" : "Message de \(Persist.name)"
        sender.sendPushNotification(to: chat.fcmToken, title: notificationTitle, body: content)
        
        // if it's an automatic message, mark the chat as unread for the current user
        if system {
            batch.updateData(["\(Persist.uid).unread": true], forDocument: document)
        }
        
        // update the timestamp in the chat
        batch.updateData(["timestamp": FieldValue.serverTimestamp()], forDocument: document)
        
        batch.commit { error in
            completion(error)
        }
    }
    
    func markChatAsRead(id: String) {
        chatsCollection.document(id).updateData(["\(Persist.uid).unread": false])
    }
}
