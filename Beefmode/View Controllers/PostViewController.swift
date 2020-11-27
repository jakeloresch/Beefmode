//
//  PostViewController.swift
//  Beefmode
//
//  Created by Jake Loresch on 7/5/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import UIKit
import Charts
import Firebase
import FirebaseFirestoreSwift

class PostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var infoButton: UIButton!
    
    var db: Firestore!
    
    //passed from home VC
    
    var docID: String?
    var uidFromHomeVC: String?
    var titleFromHomeVC: String?
    var bodyFromHomeVC: String?
    var userFromHomeVC: String?
    var upVotesFromHomeVC: Double?
    var downVotesFromHomeVC: Double?
    var postDateFromHomeVC: Timestamp?
    
    //for charts
    
    var up = PieChartDataEntry(value: 0)
    var down = PieChartDataEntry(value: 0)
    var totalNumberOfVotes = [PieChartDataEntry]()
    
    //for functions
    
    var commentArray = [Comment]()
    
    var usernameForComment: String = ""
    
    let currentUserUIDString = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        self.titleLabel.text = titleFromHomeVC
        self.bodyLabel.text = bodyFromHomeVC

        showCommentsTableView()
        checkForLoginStatusForCommentButton()
        loadUserAndChart()
    }
    
    func loadUserAndChart() {
        
        self.db.collection("users").document(userFromHomeVC!)
            .getDocument { (snapshot, error ) in
                
                if let document = snapshot {
                    
                    guard let data = document.data(),
                        let usernameString = data["username"] as? String else {
                            return
                    }
                    self.usernameLabel.text = ("🥩\(usernameString)")
                    
                } else {
                    
                    print("error reaching database")
                }
        }
        
        self.pieChart.chartDescription?.text = ""
        
        up.value = upVotesFromHomeVC!
        up.label = "👍"
        
        down.value = downVotesFromHomeVC!
        down.label = "👎"
        
        totalNumberOfVotes = [up, down]
        
        updateChartData()
        
    }
    
    func checkForLoginStatusForCommentButton() {
        if Auth.auth().currentUser != nil {
            //if User is signed in, show "Comment" in left bar button
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Comment", style: .plain, target: self, action: #selector(commentButtonTapped))
            
        } else { //hides "Comment" button and voting buttons if user is logged out
            self.navigationItem.rightBarButtonItem = nil
            upVoteButton.isHidden = true
            downVoteButton.isHidden = true
        }
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserAsString = currentUser.uid
        
        //if User is the poster, hide report button but show delete button
        if currentUserAsString == uidFromHomeVC {
            deletePostButtonPressed()
        } else {
            reportPostButtonPressed()
        }
    }
    
    func deletePostButtonPressed() {
        let alert = UIAlertController(title: "Post Options", message: "You can delete the post here if you'd like.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { action in
            self.deletePost()
        }))

        self.present(alert, animated: true)
    }
    
    func deletePost() {
        
        db.collection("posts").document(docID!).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    func reportPostButtonPressed() {
        let alert = UIAlertController(title: "Just checking.", message: "Are you sure you want to report this post?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes, Report", style: .destructive, handler: { action in
            self.reportPost()
        }))
        
        self.present(alert, animated: true)
    }
    
    func reportPost() {
        
        let newReport: [String: Any] = [
        "Reporter": Auth.auth().currentUser!.uid,
        "type": "post",
        "docID": docID!,
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
        showReportedCommentAlert()
    }
    
    func showReportedCommentAlert() {
        let alert = UIAlertController(title: "Reported.", message: "Thank you for reporting, our team will review this shortly.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    @objc func commentButtonTapped() {
        guard let currentUser = Auth.auth().currentUser else { return }
        db.collection("users").document(currentUser.uid) //sets UID given by Firebase Auth and equates it to UID found in Firestore
            .getDocument { (snapshot, error ) in
                
                if let document = snapshot {
                    
                    guard let data = document.data(),
                        let username = data["username"] as? String else {
                            return
                    }
                    self.usernameForComment = username
                } else {
                    
                    print("error reaching database")
                    
                }
                
                let composeAlert = UIAlertController(title: "New Comment", message: "", preferredStyle: .alert)
                
                composeAlert.addTextField { (textField:UITextField) in
                    textField.placeholder = "Your comment"
                }
                
                composeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                composeAlert.addAction(UIAlertAction(title: "Post", style: .default, handler: { (action:UIAlertAction) in
                    
                    if let commentBody = composeAlert.textFields?.first?.text {
                        
                        guard let currentUser = Auth.auth().currentUser else { return }
                        let uidString = currentUser.uid
                        let commentID = UUID().uuidString
                        
                        let newComment : [String: Any] = [
                            "username": self.usernameForComment,
                            "commentID": commentID,
                            "uid": uidString,
                            "commentBody": commentBody,
                            "timestamp": Timestamp()
                        ]
                        
                        self.db.collection("comments").document(self.docID!).collection("comments").document(commentID).setData(newComment)
                        
                        self.showCommentsTableView()
                        
                    }
                    
                }))
                
                self.present(composeAlert, animated: true, completion: nil)
                
                
        }
    }
    
    @objc func showCommentsTableView() {
        showSpinner(onView: commentsTableView)
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.isHidden = false
        
        db.collection("comments").document(docID!).collection("comments").getDocuments {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                self.commentArray = querySnapshot!.documents.compactMap({Comment(dictionary: $0.data())})
                print("Comment count for \(self.docID!) count is \(self.commentArray.count)")
                DispatchQueue.main.async {
                    self.commentsTableView.reloadData()
                    self.removeSpinner()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if commentArray.count == 0 {
            return "No comments yet. Start the conversation."
        } else {
            
            return "Comments"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell")!
        let comment = self.commentArray[indexPath.row] as Comment
        cell.textLabel?.text = "\(comment.commentBody)"
        cell.detailTextLabel?.text = "\(comment.username)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = CommentViewController.fromStoryboard()
        
        controller.docIDfromPostVC = docID
        controller.commentBodyfromPostVC = commentArray[indexPath.row].commentBody
        controller.commentIDFromPostVC = commentArray[indexPath.row].commentID
        controller.timestampfromPostVC = commentArray[indexPath.row].timestamp
        controller.uidFromPostVC = commentArray[indexPath.row].uid
        controller.usernameFromPostVC = commentArray[indexPath.row].username
        
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func increment(_ sender: Any) {
        db = Firestore.firestore()
        let dbRef = db.collection("posts").document(docID!)
        dbRef.updateData([
            "upVotes": FieldValue.increment(Int64(1))
        ])
        refreshChart()
        voteLockout()
    }
    
    @IBAction func decrement(_ sender: Any) {
        db = Firestore.firestore()
        let dbRef = db.collection("posts").document(docID!)
        dbRef.updateData([
            "downVotes": FieldValue.increment(Int64(1))
        ])
        refreshChart()
        voteLockout()
    }
    
    func voteLockout() {
        let voter: [String: Any] =
            ["voters": userFromHomeVC!]
        let docRef = db.collection("posts").document(docID!)
        docRef.updateData(voter) {
            error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            }else{
                print("\(voter) has voted and is locked out of voting.")
            }
        }
        hideVotingOptions()
    }
    
    //    func checkForVote() {
    //
    //        let documentRef = db.collection("posts").document(docID!)
    //
    //        documentRef.whereField("voters", isEqualTo: userFromHomeVC).getDocuments { (snapshot, err) in
    //            if let err = err {
    //                print("Error getting document: \(err)")
    //            } else if (snapshot?.isEmpty)! {
    //                completion(false)
    //                print("Option 1")
    //            } else {
    //                for document in (snapshot?.documents)! {
    //                    if document.data()["voters"] != nil {
    //                        print("Option 2")
    //                        completion(true)
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    func hideVotingOptions() {
        downVoteButton.isHidden = true
        upVoteButton.isHidden = true
    }
    
    func refreshChart() {
        
        self.db.collection("posts").document(docID!)
            .getDocument { (snapshot, error ) in
                
                if let document = snapshot {
                    
                    guard let data = document.data(),
                        let refreshedUpVotes = data["upVotes"] as? Double,
                        let refreshedDownVotes = data["downVotes"] as? Double
                        else {
                            return
                    }
                    
                    self.upVotesFromHomeVC = refreshedUpVotes
                    self.downVotesFromHomeVC = refreshedDownVotes
                    
                    self.pieChart.chartDescription?.text = ""
                    
                    self.up.value = self.upVotesFromHomeVC!
                    self.up.label = "👍"
                    
                    self.down.value = self.downVotesFromHomeVC!
                    self.down.label = "👎"
                    
                    self.totalNumberOfVotes = [self.up, self.down]
                    
                    self.updateChartData()
                } else {
                    
                    print("error reaching database")
                }
        }
        
    }
    
    func updateChartData() {
        
        let chartDataSet = PieChartDataSet(entries: totalNumberOfVotes, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [UIColor.red, UIColor.darkGray]
        chartDataSet.colors = colors as [NSUIColor]
        pieChart.data = chartData
    }
    
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> PostViewController {
        let controller = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        return controller
    }
}
