//
//  SignupViewController.swift
//  Beefmode
//
//  Created by Jake Loresch on 5/19/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignupViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailaddressTextField: UITextField!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        
    }
    
    
    func setUpElements() {
        
        //hide feedback label
        feedbackLabel.alpha = 0
        
        //style elements
        Utilities.styleTextField(usernameTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(emailaddressTextField)
        Utilities.styleFilledButton(signupButton)
        
    }
    
    //checks the fields for correct data. Will return nil if correct, else will return error message as a string
    func validateFields() -> String? {
        
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailaddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields"
        }
        
        //next it will check if password entered in passwordTextField is secured
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) //I force unwrapped because it already checks for entry in if statement above
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
        //password isn't secure enough
            return "Password does not meet requirements."
        }
        
        
        return nil
    }
    
    @IBAction func signupTapped(_ sender: Any) {
    
        //Validate the fields
        let error = validateFields()
        
        if error != nil {
             //error message will show if there's something wrong with the fields
            showError(error!)
        }
        else {
            
            //create cleaned versions of the data
            //force unwrapped because it's already been sanitized to heck
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailaddressTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if err != nil {
                    
                    //there was an error creating the user
                    self.showError("Error creating user")
                }
                    
                else {
                    //user was created successfully, now store the username
                    
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["username":username, "uid": result!.user.uid]) { (error) in
                        
                        if error != nil {
                            //show error message
                            self.showError("Error saving user data")//failure state for username not being saved but email and pw are OK
                        }
                    }
                    //transitions to home screen
                    self.transitionToBeefListVC()
                }
            }
        }
    
    }
 
    
    func showError(_ message:String) {
        
        feedbackLabel.text = message
        feedbackLabel.alpha = 1
    }
    
    func transitionToBeefListVC() {

        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeTableViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
        
    }
}
