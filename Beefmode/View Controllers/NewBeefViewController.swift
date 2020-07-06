//
//  NewBeefViewController.swift
//  Beefmode
//
//  Created by Jake Loresch on 4/21/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class NewBeefViewController: UIViewController {
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextField: UITextField!
    @IBOutlet weak var charactersRemaining: UILabel!
    
    //    weak var delegate: NewBeefViewControllerDelegate?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(transitionToBeefListVC))
        titleTextField.delegate = self
        charactersRemaining.text = String(64) //ensure that value matches 'length' at end of textField function in extention.
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        
//        let db = Firestore.firestore()
        //
        //            db.collection("posts").addDocument(data: [
        //            "uid": Auth.auth().currentUser!.uid,
        //            "title": titleTextField.text!,
        //            "body": bodyTextField.text!,
        //            "upVotes": 0,
        //            "downVotes": 0,
        //            "postDate": Timestamp()
        //        ])
        
//        let uid = Auth.auth().currentUser!.uid,
//        let title = titleTextField.text,
//        let body = bodyTextField.text,
//        let upVotes: 0,
//        let downVotes: 0,
//        let postDate = Timestamp()
//
        let newPost = Post(uid: Auth.auth().currentUser!.uid, title: titleTextField.text!, body: bodyTextField.text!, upVotes: 0, downVotes: 0, postDate: Timestamp())
        
            var ref:DocumentReference? = nil
            ref = self.db.collection("posts").addDocument(data: newPost.dictionary) {
                error in
                
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                }else{
                    print("Document added with ID: \(ref!.documentID)")
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

//protocol NewBeefViewControllerDelegate: NSObjectProtocol {
//    func postController(_ controller: NewBeefViewController, didSubmitFormWithPost post: Post)
//}
