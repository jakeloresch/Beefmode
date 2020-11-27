//
//  LoginViewController.swift
//  Beefmode
//
//  Created by Jake Loresch on 5/19/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }
    
    func setUpElements() {
        
        //hide feedback label
        feedbackLabel.alpha = 0
        
        //style elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        Utilities.styleFilledButton(forgotPasswordButton)

    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        self.showSpinner(onView: self.view)
        //Create cleaned versions of the text fields
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                //Failure state for not signing in
                self.feedbackLabel.text = error!.localizedDescription
                self.feedbackLabel.alpha = 1
                self.removeSpinner()
            }
            else {
                //Success logging in
                self.removeSpinner()
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "homeVC") as! HomeTableViewController
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
    }
}
