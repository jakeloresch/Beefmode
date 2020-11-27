//
//  Post.swift
//  Beefmode
//
//  Created by Jake Loresch on 6/30/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

protocol PostDocumentSerializable  {
    init?(dictionary:[String:Any])
}

struct Post {
    var uid:String
    var title: String
    var body: String
    var docIDString: String
    var upVotes: Int
    var downVotes: Int
    var postDate: Timestamp
    
    var dictionary:[String:Any] {
        return [
            "uid": uid,
            "title": title,
            "body": body,
            "docIDString": docIDString,
            "upVotes": upVotes,
            "downVotes": downVotes,
            "postDate": postDate
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case title = "title"
        case body = "body"
        case docIDString = "docIDString"
        case upVotes = "upVotes"
        case downVotes = "downVotes"
        case postDate = "postDate"
    }
}

extension Post: PostDocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let uid = dictionary["uid"] as? String,
            let title = dictionary["title"] as? String,
            let body = dictionary["body"] as? String,
            let docIDString = dictionary["docIDString"] as? String,
            let upVotes = dictionary["upVotes"] as? Int,
            let downVotes = dictionary["downVotes"] as? Int,
            let postDate = dictionary ["postDate"] as? Timestamp
            
            else {return nil}
        
        self.init(uid: uid, title: title, body: body, docIDString: docIDString, upVotes: upVotes, downVotes: downVotes, postDate: postDate)
    }
}

