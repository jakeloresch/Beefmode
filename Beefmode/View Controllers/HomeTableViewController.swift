//
//  HomeTableViewController.swift
//  Beefmode
//
//  Created by Jake Loresch on 6/4/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class HomeTableViewController: UITableViewController {
    
    var db: Firestore!
    
    var postArray = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        loadData()
        checkForUserStateForProfileButton()
    }
    
    // MARK: Data handlers
    
    func loadData() {
        
        db.collection("posts").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                self.postArray = querySnapshot!.documents.compactMap({Post(dictionary: $0.data())})
                print("postArray count is  \(self.postArray.count)")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } 
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell")!
        let post = self.postArray[indexPath.row] as Post
        cell.textLabel?.text = post.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      let controller = PostViewController.fromStoryboard()
        
        controller.docID = postArray[indexPath.row].docIDString
        controller.titleFromHomeVC = postArray[indexPath.row].title
        controller.bodyFromHomeVC = postArray[indexPath.row].body
        controller.userFromHomeVC = postArray[indexPath.row].uid
        controller.upVotesFromHomeVC = Double(postArray[indexPath.row].upVotes)
        controller.downVotesFromHomeVC = Double(postArray[indexPath.row].downVotes)
        
      self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    // MARK: Bar Button functionality
    
    func checkForUserStateForProfileButton() {
        if Auth.auth().currentUser != nil {
            //if User is signed in, show "Profile" in left bar button
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(profileButtonTapped))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Beef", style: .plain, target: self, action: #selector(postButtonTapped))
            
        } else {
            //if user is not signed in: display "Sign in"
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log In", style: .plain, target: self, action: #selector(logInButtonTapped))
            self.navigationItem.rightBarButtonItem = nil
            
        }
    }
    
    @objc func postButtonTapped() {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "newBeefVC") as! NewBeefViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
        
    }
    
    @objc func profileButtonTapped() {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
        
    }
    
    @objc func logInButtonTapped() {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "logInVC") as! LoginViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}
