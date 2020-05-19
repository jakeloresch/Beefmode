//
//  Beef.swift
//  Beefmode
//
//  Created by Jake Loresch on 4/23/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import Foundation

struct Beef: Codable {
    
    init(username: String, title: String, body: String, timestamp: TimeInterval = Date().timeIntervalSince1970, votes: Int, reports: [String]?, comments: [String]?) {
        
        self.username = username
        self.title = title
        self.body = body
        self.timestamp = timestamp
        self.votes = votes
        self.reports = reports
        self.comments = comments
    }
    
    let username: String
    let title: String
    let body: String
    let timestamp: TimeInterval
    let votes: Int
    let reports: [String]?
    let comments: [String]?
    
    var queryTimestamp: TimeInterval {
        return timestamp - 0.00001
    }

}
