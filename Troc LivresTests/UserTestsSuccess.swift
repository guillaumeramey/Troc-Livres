//
//  UserTestsSuccess.swift
//  Troc LivresTests
//
//  Created by Guillaume Ramey on 11/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import XCTest
@testable import Troc_Livres

class UserTestsSuccess: XCTestCase {

    override func setUp() {
        DependencyInjection.shared.dataManager = DataManagerMock()
        
        user1 = User(uid: "uid1", name: "username1", fcmToken: "token1")
        user2 = User(uid: "uid2", name: "username2", fcmToken: "token2")
    }

    func testGetUserSuccess() {
        // Given
        var user = User(uid: "", name: "", fcmToken: "")
        // When
        DependencyInjection.shared.dataManager.getUser(uid: "") { userResult in
            XCTAssertNotNil(userResult)
            user = userResult!
        }
        // Then
        XCTAssertEqual(user.uid, "uid1")
        XCTAssertEqual(user.name, "username1")
    }
    
    func testGetUsersSuccess() {
        // Given
        var users = [User]()
        // When
        DependencyInjection.shared.dataManager.getUsers { usersResult in
            users = usersResult
        }
        // Then
        XCTAssertEqual(users.count, 2)
    }
    
    // MARK: - Books
    
    func testGetBooksSuccess() {
        // Given
        XCTAssertTrue(user2.books.isEmpty)
        // When
        user2.getBooks { }
        // Then
        XCTAssertEqual(user2.books.count, 2)
    }
    
    func testAddBookSuccess() {
        // Given
        XCTAssertFalse(user1.books.contains(book1))
        // When
        user1.addBook(book1) { error in
            XCTAssertNil(error)
        }
        // Then
        XCTAssertTrue(user1.books.contains(book1))
    }
    
    func testRemoveBookSuccess() {
        // Given
        user1.books.append(book1)
        // When
        user1.removeBook(book1) { error in
            XCTAssertNil(error)
        }
        // Then
        XCTAssertFalse(user1.books.contains(book1))
    }
    
    // MARK: - Wishes
    
    func testGetWishesSuccess() {
        // Given
        let user = User(uid: "uid", name: "username", fcmToken: "token")
        XCTAssertTrue(user.wishes.isEmpty)
        // When
        user.getWishes()
        // Then
        XCTAssertEqual(user.wishes.count, 2)
    }
    
    func testAddWishSuccess() {
        // Given
        XCTAssertTrue(user1.wishes.isEmpty)
        // When
        user1.addWish(wish1) { error in
            XCTAssertNil(error)
        }
        // Then
        XCTAssertEqual(user1.wishes.count, 1)
        XCTAssertTrue(user1.wishes.contains(wish1))
    }
    
    func testRemoveWishSuccess() {
        // Given
        user1.wishes.append(wish1)
        // When
        user1.removeWish(wish1) { error in
            XCTAssertNil(error)
        }
        // Then
        XCTAssertEqual(user1.wishes.count, 0)
        XCTAssertFalse(user1.wishes.contains(wish1))
    }
    
    // MARK: - Chats
    
    func testGetChatsSuccess() {
        // Given
        XCTAssertTrue(currentUser.chats.isEmpty)
        // When
        currentUser.getChats {}
        // Then
        XCTAssertEqual(currentUser.chats.count, 2)
    }
    
    func testNewChatSuccess() {
        // Given
        XCTAssertTrue(user1.chats.isEmpty)
        // When
        user1.newChat(with: user2) { error in
            XCTAssertNil(error)
        }
        // Then
        XCTAssertEqual(user1.chats.count, 1)
    }
}
