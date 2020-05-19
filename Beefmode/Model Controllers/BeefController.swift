//
//  BeefController.swift
//  Beefmode
//
//  Created by Jake Loresch on 4/23/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import Foundation

//https://beefmode-d88d2.firebaseio.com/

class BeefController {
    
    static let baseURL = URL(string: "https://beefmode-d88d2.firebaseio.com")


// MARK:
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : beefs.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        
        let queryItems = urlParameters.flatMap( { URLQueryItem(name: $0.key, value: $0.value)})
        
        var urlComponents = URLComponents(url: PostController.baseURL!, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { completion(); return }
        
        let getterEndpoint = url.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
            
            if let error = error {
                NSLog("There was an error retrieving data in \(#function). Error: \(error)")
                completion()
                return
            }
            
            guard let data = data else { NSLog("No data returned from data task."); completion(); return }
            
            do {
                let decoder = JSONDecoder()
                let postsDictionary = try decoder.decode([String:Post].self, from: data)
                let posts: [Post] = postsDictionary.flatMap( { $0.value })
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
            } catch let error {
                NSLog("Error decoding: \(error.localizedDescription)")
                completion()
            }
    })
    dataTask.resume()
    }
        
        func addPost(username: String, text: String, completion: @escaping() -> Void) {
            
            let post = Post(username: username, text: text)
            
            var postData: Data

            
            do {
                let encoder = JSONEncoder()
                postData = try encoder.encode(post)
            } catch let error {
                NSLog("Error encoding the post to be saved: \(error.localizedDescription)")
                completion()
                return
            }
            
            let postEndPoint = PostController.baseURL?.appendingPathExtension("json")
            
            var request = URLRequest(url: postEndPoint!)
            
            request.httpMethod = "POST"
            
            request.httpBody = postData
            
            let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
                
                if let error = error { completion(); NSLog(error.localizedDescription) }
                
                guard let data = data,
                    let responseDataString = String(data: data, encoding: .utf8)
                    else { NSLog("Data is nil. Unable to verify if data was able to be pot to endpoint.");
                        completion()
                        return }
                
                self.fetchPosts {
                    completion()
                }
            }
            dataTask.resume()
        }

    //Done
var beefs: [Beef] = []
}

