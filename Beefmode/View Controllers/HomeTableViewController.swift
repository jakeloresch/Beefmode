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
    
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var savedButton: UIButton!

    @IBAction func newButtonPressed(_ sender: Any) {
        newButton.isSelected = true
        savedButton.isSelected = false
        checkUserStateForBlockedPosts()
    }

    @IBAction func savedButtonPressed(_ sender: Any) {
        newButton.isSelected = false
        savedButton.isSelected = true
    }
    
    var currentUserAsString: String = ""
    
    var db: Firestore!
    
//    var blockList = [String]()
    var blockList: [String] = ["Vx78zaAY2tXYQEQ3gL1NAIAvSTS2"]
    var postArray = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newButton.isSelected = true
        
        db = Firestore.firestore()
        
        self.showSpinner(onView: self.view)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Back", style: .plain, target: nil, action: nil)
        
        checkUserStateForBlockedPosts()
        checkForUserStateForProfileButton()
    }
    
    // MARK: Data handler
        
    func checkUserStateForBlockedPosts() {
        if Auth.auth().currentUser?.uid.isEmpty ?? true {
            loadNewPostsIfNotSignedIn()
            print("User not signed in")
        } else {
            currentUserAsString = Auth.auth().currentUser!.uid
            loadNewPostsIfSignedIn()
        }
    }
    
    func loadNewPostsIfSignedIn() {
//            print("Loading block list ...")
//
//        let docRef =  db.collection("users").document(currentUserAsString)
//
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                self.blockList = document.get("blockedUsers") as? [String] ?? []
//                print("Blocked Users: \(self.blockList)")
//            } else {
//                print("Document does not exist")
//            }
//        }

        print("Loading new posts...")
//        db.collection("posts").order(by: "postDate", descending: true).limit(to: 50).getDocuments() {

//            querySnapshot, error in
//            if let error = error {
//                print("\(error.localizedDescription)")
//            }else{
//                self.unfilteredPostArray = querySnapshot!.documents.compactMap({Post(dictionary: $0.data())})
//
//                print("Unfiltered post count is \(self.unfilteredPostArray.count)")
//
//                self.postArray = self.unfilteredPostArray.filter { post in
//                    !self.blockList.contains(post.uid)
//                }
//
//                print("Filtered posts count is \(self.postArray.count)")
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    self.removeSpinner()
//                }
//            }
//        }
//    }
        
        let postsDocRef = db.collection("posts")

        postsDocRef
            .whereField("uid", notIn: blockList)
        postsDocRef
            .order(by: "postDate", descending: true).limit(to: 50)
            .getDocuments() {

            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                self.postArray = querySnapshot!.documents.compactMap({Post(dictionary: $0.data())})

                print("Filtered posts count is \(self.postArray.count)")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.removeSpinner()
                }
            }
        }
    }

    func loadNewPostsIfNotSignedIn() {
        
        db.collection("posts").order(by: "postDate", descending: true).limit(to: 50).getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                self.postArray = querySnapshot!.documents.compactMap({Post(dictionary: $0.data())})
                print("postArray count is  \(self.postArray.count)")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.removeSpinner()
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
        
//        let postDateAsDate = post.postDate.dateValue()
//
//        let fourtyEightHoursFromPostDate = postDateAsDate + 172800
//
//        let date = Date()
//        let format = DateFormatter()
//        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let currentDate = format.date(from: )
//
//        let timeLeft = currentDate - fourtyEightHoursFromPostDate
//
//        let hoursLeft = ""
        
        cell.textLabel?.text = post.title
        //cell.detailTextLabel?.text = post.postDate
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = PostViewController.fromStoryboard()
        
        controller.docID = postArray[indexPath.row].docIDString
        controller.uidFromHomeVC = postArray[indexPath.row].uid
        controller.titleFromHomeVC = postArray[indexPath.row].title
        controller.bodyFromHomeVC = postArray[indexPath.row].body
        controller.userFromHomeVC = postArray[indexPath.row].uid
        controller.upVotesFromHomeVC = Double(postArray[indexPath.row].upVotes)
        controller.downVotesFromHomeVC = Double(postArray[indexPath.row].downVotes)
        //controller.postDateFromHomeVC = Timestamp(date: postArray[indexPath.row].postDate)
        
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

var vSpinner: UIView?

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            UIView.transition(with: self.view, duration: 0.15, options: [.transitionCrossDissolve], animations: {
                vSpinner!.removeFromSuperview()
            }, completion: nil)
        }
    }
}
