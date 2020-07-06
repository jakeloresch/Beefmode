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

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userIDLabel: UILabel!
    @IBAction func signOutButton(_ sender: Any) {
        signOutButtonTapped()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserName()
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
    
    func transitionToHomeVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "homeVC") as! HomeTableViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}

