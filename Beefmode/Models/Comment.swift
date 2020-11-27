//
//  Comment.swift
//  Beefmode
//
//  Created by Jake Loresch on 7/10/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

protocol CommentDocumentSerializable  {
    init?(dictionary:[String:Any])
}

struct Comment {
    var commentBody: String
    var username: String
    var commentID: String
    var uid: String
    var timestamp: Timestamp
    
    var dictionary:[String:Any] {
        return [
            "commentBody": commentBody,
            "username": username,
            "commentID": commentID,
            "uid": uid,
            "timestamp": timestamp
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case commentBody = "commentBody"
        case username = "username"
        case commentID = "commentID"
        case uid = "uid"
        case timestamp = "timestamp"
    }
}

extension Comment: CommentDocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let commentBody = dictionary["commentBody"] as? String,
            let username = dictionary["username"] as? String,
            let commentID = dictionary["commentID"] as? String,
            let uid = dictionary["uid"] as? String,
            let timestamp = dictionary["timestamp"] as? Timestamp
            else {return nil}
        
        self.init(commentBody: commentBody, username: username, commentID: commentID, uid: uid, timestamp: timestamp)
    }
}


