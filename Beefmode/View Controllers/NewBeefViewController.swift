//
//  NewBeefViewController.swift
//  Beefmode
//
//  Created by Jake Loresch on 4/21/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class NewBeefViewController: UIViewController {
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextField: UITextField!
    @IBOutlet weak var charactersRemaining: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(transitionToBeefListVC))
        titleTextField.delegate = self
        charactersRemaining.text = String(64) //ensure that value matches 'length' at end of textField function in extention.
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        
        
        let newDocumentID = UUID().uuidString
        
        let newPost: [String: Any] = [
        "uid": Auth.auth().currentUser!.uid,
        "title": titleTextField.text!,
        "body": bodyTextField.text!,
        "docIDString": newDocumentID,
        "upVotes": 0,
        "downVotes": 0,
        "postDate": Timestamp()
        ]

        db.collection("posts").document(newDocumentID).setData(newPost) {
        error in

            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            }else{
                print("Document added with ID: \(newDocumentID)")
            }

        }
  
    transitionToBeefListVC()
}
    
@objc func transitionToBeefListVC() {
    
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let newViewController = storyBoard.instantiateViewController(withIdentifier: "homeVC") as! HomeTableViewController
    self.navigationController?.pushViewController(newViewController, animated: true)
}
}

// MARK: Extention for charactersRemaining
extension NewBeefViewController: UITextFieldDelegate {
    
    func textField(_ titleTextField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = titleTextField.text else { return true }
        let length = text.count + string.count - range.length
        
        // create an Integer of 64 - the length of your TextField.text to count down
        let count = 64 - length
        
        // set the .text property of your UILabel to the live created String
        charactersRemaining.text =  String(count)
        
        // if you want to limit to 64 charakters
        // you need to return true and <= 64
        
        return length <= 63 // To just allow up to 64 characters.
    }
    
}
