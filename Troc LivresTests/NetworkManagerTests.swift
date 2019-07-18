//
//  NetworkManagerTests.swift
//  Troc LivresTests
//
//  Created by Guillaume Ramey on 09/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import XCTest
@testable import Troc_Livres

class NetworkManagerTests: XCTestCase {

    private let session = URLSessionMock()
    private var manager: NetworkManager!
    
    override func setUp() {
        manager = NetworkManager(session: session)
    }
    
    func testGetBooksSuccess() {
        // Given
        session.response = FakeResponseData.responseOK
        session.data = FakeResponseData.bookCorrectData
        
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        manager.getBooks { result in
            switch result {
            // Then
            case .success(let books):
                XCTAssertEqual(books[0].title, "Au revoir là-haut")
            default:
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetBooksNoResponse() {
        // Given
        session.response = FakeResponseData.responseKO
        
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        manager.getBooks { result in
            switch result {
            // Then
            case .failure(let error):
                XCTAssertEqual(error, NetworkError.noResponse)
            default:
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetBooksBadData() {
        // Given
        session.response = FakeResponseData.responseOK
        session.data = FakeResponseData.bookIncorrectData
        
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        manager.getBooks { result in
            switch result {
            // Then
            case .failure(let error):
                XCTAssertEqual(error, NetworkError.noResult)
            default:
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetBooksNoData() {
        // Given
        session.response = FakeResponseData.responseOK
        
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        manager.getBooks { result in
            switch result {
            // Then
            case .failure(let error):
                XCTAssertEqual(error, NetworkError.noData)
            default:
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetBooksError() {
        // Given
        session.response = FakeResponseData.responseOK
        session.error = FakeResponseData.error
        
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        manager.getBooks { result in
            switch result {
            // Then
            case .failure(let error):
                XCTAssertEqual(error, NetworkError.error)
            default:
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
