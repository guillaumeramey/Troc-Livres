//
//  FireBasManagerTests.swift
//  Troc LivresTests
//
//  Created by Guillaume Ramey on 11/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import XCTest
@testable import Troc_Livres

class FirebaseManagerTests: XCTestCase {

    var dataManagerMock: DataManager = FirebaseManagerMock()
    
    override func setUp() {
    }

    func testGetUserSuccess() {
        // Given
        let uid = "uid1"
        let username = "username1"
        // When
        dataManagerMock.getUser(uid: uid) { user in
            // Then
            XCTAssertEqual(user?.uid ?? "", uid)
            XCTAssertEqual(user?.name ?? "", username)
        }
    }
    
    func testGetUsersSuccess() {
        // Given
        let numberOfUsers = 2
        // When
        dataManagerMock.getUsers { users in
            // Then
            XCTAssertEqual(users.count, numberOfUsers)
        }
    }
    
//    func testGetChatSuccess() {
//        // Given
//        let user = User(uid: "uid", name: "username")
//        // When
//        FirebaseManagerMock.getChat(with: user) { result in
//            // Then
//            switch result {
//            case .success(let chat):
//                XCTAssertEqual(chat.id, "chatId")
//                XCTAssertEqual(chat.uid, "uid")
//            default:
//                XCTAssert(false)
//            }
//        }
//    }
    

}
