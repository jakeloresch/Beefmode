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

class PostViewController: UIViewController {
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    var docID: String?
    var db: Firestore!
    
    var titleFromHomeVC: String?
    var bodyFromHomeVC: String?
    var userFromHomeVC: String?
    var upVotesFromHomeVC: Double?
    var downVotesFromHomeVC: Double?
    
    var upVotes = PieChartDataEntry(value: 0)
    var downVotes = PieChartDataEntry(value: 0)
    var totalNumberOfVotes = [PieChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        self.titleLabel.text = titleFromHomeVC
        self.bodyLabel.text = bodyFromHomeVC
        
        loadData()
    }
    
    func loadData() {
        
        self.db.collection("users").document(userFromHomeVC!)
            .getDocument { (snapshot, error ) in
                
                if let document = snapshot {
                    
                    guard let data = document.data(),
                        let usernameString = data["username"] as? String else {
                            return
                    }
                    print("**Username is \(usernameString)")
                    self.usernameLabel.text = ("🥩\(usernameString)")
                    
                } else {
                    
                    print("error reaching database")
                }
        }
        
        self.pieChart.chartDescription?.text = ""
        
        upVotes.value = upVotesFromHomeVC!
        upVotes.label = "Legit Beef"
        
        downVotes.value = downVotesFromHomeVC!
        downVotes.label = "Wack Beef"
        
        totalNumberOfVotes = [upVotes, downVotes]
        
        updateChartData()
        
        
    }// end func
    
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
