//
//  SignupViewController.swift
//  Beefmode
//
//  Created by Jake Loresch on 5/19/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import UIKit

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
        
        //create the user
        
        //transition to BeefListViewController
    
    }
    
}
