//
//  CommentViewController.swift
//  Beefmode
//
//  Created by Jake Loresch on 7/26/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class CommentViewController: UIViewController {

    var db: Firestore!
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var docIDfromPostVC: String?
    var commentBodyfromPostVC: String?
    var commentIDFromPostVC: String?
    var timestampfromPostVC: Timestamp?
    var uidFromPostVC: String?
    var usernameFromPostVC: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()

        commentLabel.text = commentBodyfromPostVC
        usernameLabel.text = ("🥩\(usernameFromPostVC ?? "poster")")
        
        checkIfCurrentUserIsPoster()
    }
    
    func checkIfCurrentUserIsPoster() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserAsString = currentUser.uid
        
        //if User is the poster, hide report button but show delete button
        if currentUserAsString == uidFromPostVC {
            reportButton.isHidden = true
        } else {
            deleteButton.isHidden = true
        }
    }
    
    @IBAction func reportButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Report Comment?", message: "Our team will review this comment for inappropriate content.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete comment", style: .destructive, handler: { action in
            self.deleteComment()
        }))

        self.present(alert, animated: true)
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Comment?", message: "This is permanent and cannot be undone.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete comment", style: .destructive, handler: { action in
            self.deleteComment()
        }))

        self.present(alert, animated: true)
    }
    
    func deleteComment(){
        db.collection("comments").document(docIDfromPostVC!).collection("comments").document(commentIDFromPostVC!).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    func reportComment(){
        let newReport: [String: Any] = [
        "Reporter": Auth.auth().currentUser!.uid,
        "type": "comment",
        "docID": docIDfromPostVC!,
        "reportDate": Timestamp()
        ]

        db.collection("reports").addDocument(data: newReport) {
        error in

            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            }else{
                print("Report added with ID: \(newReport)")
            }

        }
        reportCommentPopAlert()
    }
    
    func reportCommentPopAlert() {
        let alert = UIAlertController(title: "Reported.", message: "Thank you for reporting, this will be reviewed shortly.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> CommentViewController {
        let controller = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        return controller
    }

}
