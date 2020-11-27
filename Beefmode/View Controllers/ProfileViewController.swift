//
//  ProfileViewController.swift
//  Beefmode
//
//  Created by Jake Loresch on 6/5/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userIDLabel: UILabel!
    
    @IBOutlet weak var userPostsTableView: UITableView!
    
    @IBAction func signOutButton(_ sender: Any) {
        signOutButtonTapped()
    }
    
    @IBAction func deleteAccountButton(_ sender: Any) {
//        deleteAccountButtonTapped()
    }
    
    var userPostArray = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        print(user!)
        
        getUserName()
        loadUserPosts()
        
        userPostsTableView.delegate = self
        userPostsTableView.dataSource = self
    }
    
    func getUserName() {
        let db = Firestore.firestore()
        guard let currentUser = Auth.auth().currentUser else { return } //verifies current user with Firebase Auth
        
        db.collection("users").document(currentUser.uid) //sets UID given by Firebase Auth and equates it to UID found in Firestore
            .getDocument { (snapshot, error ) in
                
                if let document = snapshot {
                    
                    guard let data = document.data(),
                        let usernameString = data["username"] as? String else {
                            return
                    }
                    
                    self.userIDLabel.text = ("Hi, \(usernameString)")
                    
                } else {
                    print("error reaching database")
                }
        }
    }
    
    func signOutButtonTapped() {
        
        do {
            try Auth.auth().signOut()
            transitionToHomeVC()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
//    func deleteAccountButtonTapped() {
//        let alert = UIAlertController(title: "Are you sure?", message: "This will delete your user info, posts, and comments. This is permanent and cannot be undone.", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Yes, delete it all", style: .destructive, handler: { action in
//
//
//            guard let currentUser = Auth.auth().currentUser else { return }
//
//            var db: Firestore!
//            db = Firestore.firestore()
//            let batch = db.batch()
//
//
//            db.collection("posts").whereField("uid", isEqualTo: currentUser.uid).getDocuments() {
//                querySnapshot, error in
//                if let error = error {
//                    print("\(error.localizedDescription)")
//                }else{
//                    querySnapshot
//                }
//
//            }
//            //db.collection("posts").whereField("uid", isEqualTo: currentUser.uid).delete
//
//
//            db.collection("users").document(currentUser.uid).delete() { err in
//                if let err = err {
//                    print("Error removing document: \(err)")
//                } else {
//                    print("Document successfully removed!")
//                }
//            }
//
//            currentUser.delete { error in
//                if error != nil {
//                    // An error happened.
//                    print("Error deleting user")
//                } else {
//                    print("User deleted")
//                    // Account deleted.
//                }
//            }
//
//            self.signOutButtonTapped()
//        }))
//        alert.addAction(UIAlertAction(title: "No, take me back", style: .cancel, handler: nil))
//
//        self.present(alert, animated: true)
//    }
    
    func transitionToHomeVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "homeVC") as! HomeTableViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func loadUserPosts() {
        print("Loading user posts...")
        
        var db: Firestore!
        db = Firestore.firestore()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        db.collection("posts").whereField("uid", isEqualTo: currentUser.uid).getDocuments() {
            
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                self.userPostArray = querySnapshot!.documents.compactMap({Post(dictionary: $0.data())})
                
                print("User posts userPostArray count is \(self.userPostArray.count)")
                DispatchQueue.main.async {
                    self.userPostsTableView.reloadData()
                    self.removeSpinner()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPostArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return "Your Posts:"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userPostCell")!
        let post = self.userPostArray[indexPath.row] as Post
                
        cell.textLabel?.text = post.title
        //cell.detailTextLabel?.text = ("\(hoursLeft) hours left")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      let controller = PostViewController.fromStoryboard()
        
        controller.docID = userPostArray[indexPath.row].docIDString
        controller.titleFromHomeVC = userPostArray[indexPath.row].title
        controller.bodyFromHomeVC = userPostArray[indexPath.row].body
        controller.userFromHomeVC = userPostArray[indexPath.row].uid
        controller.upVotesFromHomeVC = Double(userPostArray[indexPath.row].upVotes)
        controller.downVotesFromHomeVC = Double(userPostArray[indexPath.row].downVotes)
        
      self.navigationController?.pushViewController(controller, animated: true)
    }
}

