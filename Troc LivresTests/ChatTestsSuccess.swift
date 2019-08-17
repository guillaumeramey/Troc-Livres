//
//  ChatTestsSuccess.swift
//  Troc LivresTests
//
//  Created by Guillaume Ramey on 06/08/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import XCTest
@testable import Troc_Livres

class ChatTestsSuccess: XCTestCase {
    
    override func setUp() {
        DependencyInjection.shared.dataManager = DataManagerMock()
    }

    func testGetUserSuccess() {
        // Given
        let chat = Chat(with: User(uid: "", name: "", fcmToken: ""))
        XCTAssertEqual(chat.user.uid, "")
        // When
        chat.getUser()
        // Then
        XCTAssertEqual(chat.user.uid, "uid1")
    }
    
    func testGetMessagesSuccess() {
        // Given
        let chat = Chat(with: User(uid: "", name: "", fcmToken: ""))
        XCTAssertEqual(chat.messages.count, 0)
        // When
        chat.getMessages { success in
            XCTAssertTrue(success)
        }
        // Then
        XCTAssertEqual(chat.messages.count, 2)
    }
    
    func testMarkAsReadSuccess() {
        // Given
        let chat = Chat(with: User(uid: "", name: "", fcmToken: ""))
        XCTAssertTrue(chat.unread)
        // When
        chat.markAsRead()
        // Then
        XCTAssertFalse(chat.unread)
    }
}
