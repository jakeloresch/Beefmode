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
        
    }
    
    func signOutButtonTapped() {
        
    }
    
}
