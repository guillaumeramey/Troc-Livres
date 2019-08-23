//
//  URLSessionMock.swift
//  Troc LivresTests
//
//  Created by Guillaume Ramey on 09/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var data: Data?
    var error: Error?
    var response: URLResponse?
    
    override func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        let response = self.response
        
        return URLSessionDataTaskMock {
            completionHandler(data, response, error)
        }
    }
}
