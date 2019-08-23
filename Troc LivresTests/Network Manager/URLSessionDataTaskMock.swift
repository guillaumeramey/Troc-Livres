//
//  URLSessionDataTaskMock.swift
//  Troc LivresTests
//
//  Created by Guillaume Ramey on 09/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation

// We create a partial mock by subclassing the original class
class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    // We override the 'resume' method and simply call our closure
    // instead of actually resuming any task.
    override func resume() {
        closure()
    }
}
