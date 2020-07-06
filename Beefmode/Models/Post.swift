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

//struct Post {
//    var uid: String
//    var title: String
//    var body: String
//    var upVotes: Int
//    var downVotes: Int
//    var postDate: Timestamp
//
//    init(uid: String, title: String, body: String, upVotes: Int, downVotes: Int, postDate: Timestamp) {
//        self.uid = uid
//        self.title = title
//        self.body = body
//        self.upVotes = upVotes
//        self.downVotes = downVotes
//        self.postDate = postDate
//    }
//}

protocol DocumentSerializable  {
    init?(dictionary:[String:Any])
}

struct Post {
    var uid:String
    var title: String
    var body: String
    var upVotes: Int
    var downVotes: Int
    var postDate: Timestamp
    
    var dictionary:[String:Any] {
        return [
            "uid": uid,
            "title": title,
            "body": body,
            "upVotes": upVotes,
            "downVotes": downVotes,
            "postDate": postDate,
        ]
    }
}

extension Post: DocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let uid = dictionary["uid"] as? String,
            let title = dictionary["title"] as? String,
            let body = dictionary["body"] as? String,
            let upVotes = dictionary["upVotes"] as? Int,
            let downVotes = dictionary["downVotes"] as? Int,
            let postDate = dictionary ["postDate"] as? Timestamp
            else {return nil}
        
        self.init(uid: uid, title: title, body: body, upVotes: upVotes, downVotes: downVotes, postDate: postDate)
    }
}

