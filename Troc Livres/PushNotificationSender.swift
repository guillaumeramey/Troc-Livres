//
//  PushNotificationSender.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 16/07/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit

class PushNotificationSender {
    
    func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA8TOxNeI:APA91bF3yijB0uC4yn5WMtn8xwO9bdoeTf-GtFJRcH7lzE50kidIjKFmIfexUhv1kddxQ73rrSeFJPPJ8WtgHciv_f9tPYQAiANo4scLv8rL9BPhcVN8Ym2rBkVrQR5kEimdyAFl1x5c", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
