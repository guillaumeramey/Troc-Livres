//
//  UserTestsFail.swift
//  Troc LivresTests
//
//  Created by Guillaume Ramey on 11/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import XCTest
@testable import Troc_Livres

class UserTestsFail: XCTestCase {
    
    override func setUp() {
        DependencyInjection.shared.dataManager = DataManagerMock(shouldSucceed: false)
        
        user1 = User(uid: "uid1", name: "username1", fcmToken: "token1")
        user2 = User(uid: "uid2", name: "username2", fcmToken: "token2")
    }
    
    func testGetUserFail() {
        DependencyInjection.shared.dataManager.getUser(uid: "") { userResult in
            XCTAssertNil(userResult)
        }
    }
    
    func testGetUsersFail() {
        // Given
        var users = [User]()
        // When
        DependencyInjection.shared.dataManager.getUsers { usersResult in
            users = usersResult
        }
        // Then
        XCTAssertTrue(users.isEmpty)
    }
    
    // MARK: - Books
    
    func testGetBooksFail() {
        // Given
        XCTAssertTrue(user2.books.isEmpty)
        // When
        user2.getBooks { }
        // Then
        XCTAssertTrue(user2.books.isEmpty)
    }
    
    func testAddBookFail() {
        // Given
        XCTAssertFalse(user1.books.contains(book1))
        // When
        user1.addBook(book1) { error in
            XCTAssertNotNil(error)
        }
        // Then
        XCTAssertFalse(user1.books.contains(book1))
    }
    
    func testRemoveBookFail() {
        // Given
        user1.books.append(book1)
        // When
        user1.removeBook(book1) { error in
            XCTAssertNotNil(error)
        }
        // Then
        XCTAssertTrue(user1.books.contains(book1))
    }
    
    // MARK: - Wishes
    
    func testGetWishesFail() {
        // Given
        XCTAssertTrue(user1.wishes.isEmpty)
        // When
        user1.getWishes()
        // Then
        XCTAssertTrue(user1.wishes.isEmpty)
    }
    
    func testAddWishFail() {
        // Given
        XCTAssertFalse(user1.wishes.contains(wish1))
        // When
        user1.addWish(wish1) { error in
            XCTAssertNotNil(error)
        }
        // Then
        XCTAssertFalse(user1.wishes.contains(wish1))
    }
    
    func testRemoveWishFail() {
        // Given
        user1.wishes.append(wish1)
        // When
        user1.removeWish(wish1) { error in
            XCTAssertNotNil(error)
        }
        // Then
        XCTAssertTrue(user1.wishes.contains(wish1))
    }
    
    // MARK: - Chats
    
    func testGetChatsFail() {
        // Given
        XCTAssertTrue(currentUser.chats.isEmpty)
        // When
        currentUser.getChats {}
        // Then
        XCTAssertTrue(currentUser.chats.isEmpty)
    }
    
    func testNewChatFail() {
        // Given
        XCTAssertTrue(user1.chats.isEmpty)
        // When
        user1.newChat(with: user2) { error in
            XCTAssertNotNil(error)
        }
        // Then
        XCTAssertTrue(user1.chats.isEmpty)
    }
}
