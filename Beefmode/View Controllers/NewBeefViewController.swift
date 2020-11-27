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

class NewBeefViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextView!
    @IBOutlet weak var bodyTextField: UITextView!
    @IBOutlet weak var charactersRemaining: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        
        if titleTextField.text.count > 128 && bodyTextField.text.count > 1028 {
            
            let alert = UIAlertController(title: "Oh no", message: "Your title exceeded the maximum of 128 characters, it was \(titleTextField.text.count) characters.\nYour post text exceeded the maximum of 1028 characters, it was \(bodyTextField.text.count) characters.\nRemember: \"Brevity is the sould of wit\" - Polonius", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        
        else if titleTextField.text.count > 128 {
            
            let alert = UIAlertController(title: "Oh no", message: "Your title exceeded the maximum of 128 characters, it was a total of \(titleTextField.text.count). Save some for the post 😉", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
            
        else if bodyTextField.text.count > 1028 {
            let alert = UIAlertController(title: "Oh no", message: "Your post text exceeded the maximum of 1028 characters, it was a total of \(bodyTextField.text.count).", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        } else {
            if notificationSwitch.isOn {
                setVotingPeriodEndNotification()
            }
            postToFirestore()
        }
    }
    
    func setVotingPeriodEndNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time's up!"
        content.body = "The votes are in and your judgement is ready."
        content.sound = UNNotificationSound.default
        
        //for 48 hours: 172800 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 172800, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Identifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (_) in
            print("User asked to get a local notification")
        }
    }
    
    func postToFirestore() {
                
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
            
            let easterEgg: [String: Any] = ["Easter Egg": "Found it!"]
            
            db.collection("comments").document(newDocumentID).setData(easterEgg) {
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

