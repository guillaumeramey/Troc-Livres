//
//  ChatTestsFail.swift
//  Troc LivresTests
//
//  Created by Guillaume Ramey on 06/08/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import XCTest
@testable import Troc_Livres

class ChatTestsFail: XCTestCase {
    
    override func setUp() {
        DependencyInjection.shared.dataManager = DataManagerMock(shouldSucceed: false)
    }
    
    func testGetUserFail() {
        // Given
        let chat = Chat(with: User(uid: "", name: "", fcmToken: ""))
        XCTAssertEqual(chat.user.uid, "")
        // When
        chat.getUser()
        // Then
        XCTAssertEqual(chat.user.uid, "")
    }
    
    func testGetMessagesFail() {
        // Given
        let chat = Chat(with: User(uid: "", name: "", fcmToken: ""))
        XCTAssertEqual(chat.messages.count, 0)
        // When
        chat.getMessages { success in
            XCTAssertTrue(success)
        }
        // Then
        XCTAssertEqual(chat.messages.count, 0)
    }
}
