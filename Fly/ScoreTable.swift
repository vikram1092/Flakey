//
//  scoreTable.swift
//  Fly
//
//  Created by Vikram Ramkumar on 9/29/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit

class ScoreTable: UITableViewController {
    
    
    let userDefaults = UserDefaults.standard
    var scores = Array<NSDictionary>()
    var username = ""
    let orange = UIColor(red: 211.0/255.0, green: 84.0/255.0, blue: 63.0/255.0, alpha: 1)
    let gray = UIColor.lightGray
    var currentScore = 0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        initializeParameters()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        print("viewDidAppear table")
        tableView.reloadData()
        print(tableView.numberOfRows(inSection: 0))
    }
    
    
    internal func initializeParameters() {
        
        
        if userDefaults.object(forKey: Constants.username) != nil {
            
            username = userDefaults.object(forKey: Constants.username) as! String
        }
    }
    
    
    internal override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        print("cellForRowAt")
        //Get necessary variables
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let rankLabel = cell.viewWithTag(1) as! UILabel
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let scoreLabel = cell.viewWithTag(3) as! UILabel
        let scoreIndex = scores.count - indexPath.row - 1
        
        
        //Set label values
        rankLabel.text = String(indexPath.row + 1)
        nameLabel.text = String(describing: scores[scoreIndex][Constants.username]!)
        scoreLabel.text = String(describing: scores[scoreIndex][Constants.score]!)
        
        
        //Change color depending on current score
        if Int(scoreLabel.text!)! == currentScore && nameLabel.text! == username {
            
            rankLabel.textColor = orange
            nameLabel.textColor = orange
            scoreLabel.textColor = orange
        }
        else {
            
            rankLabel.textColor = gray
            nameLabel.textColor = gray
            scoreLabel.textColor = gray
        }
        
        return cell
    }
    
    
    internal override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return scores.count
    }
    
    
    internal func refresh() {
        
        tableView.reloadData()
    }
    
    
    internal func updateCurrentScore(score: Int) {
        
        currentScore = score
    }
}
