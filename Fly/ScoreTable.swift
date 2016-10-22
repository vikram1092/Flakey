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
    var currentRank = -1
    
    
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
        
        
        //Get necessary variables
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let rankLabel = cell.viewWithTag(1) as! UILabel
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let scoreLabel = cell.viewWithTag(3) as! UILabel
        let scoreIndex = scores.count - indexPath.row - 1
        
        
        if scores.count > 0 {
            
            //Set label values
            rankLabel.text = String(indexPath.row + 1)
            nameLabel.text = String(describing: scores[scoreIndex][Constants.username]!)
            scoreLabel.text = String(describing: scores[scoreIndex][Constants.score]!)
            
            
            //If user score is below top 5, show user score at the bottom instead of the fifth row
            if indexPath.row == 4 && currentRank > 5 {
                
                rankLabel.text = String(currentRank)
                nameLabel.text = username
                scoreLabel.text = String(currentScore)
            }
            
            
            //Change color if row is user's current score
            if Int(scoreLabel.text!)! == currentScore && nameLabel.text! == username {
                
                rankLabel.textColor = orange
                nameLabel.textColor = orange
                scoreLabel.textColor = orange
                
                rankLabel.font = UIFont.systemFont(ofSize: rankLabel.font.pointSize, weight: UIFontWeightMedium)
                nameLabel.font = UIFont.systemFont(ofSize: nameLabel.font.pointSize, weight: UIFontWeightMedium)
                scoreLabel.font = UIFont.systemFont(ofSize: scoreLabel.font.pointSize, weight: UIFontWeightMedium)
            }
            else {
                
                rankLabel.textColor = gray
                nameLabel.textColor = gray
                scoreLabel.textColor = gray
            }
        }
        else {
            
            //Set label values
            rankLabel.text = "-"
            nameLabel.text = "-"
            scoreLabel.text = "-"
        }
        
        return cell
    }
    
    
    internal override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        //If scores list isn't empty, return score list. Else return 5.
        if scores.count > 0 {
            
            return scores.count
        }
        
        return 5
    }
    
    
    internal func refresh() {
        
        tableView.reloadData()
    }
    
    
    internal func updateCurrentScore(score: Int) {
        
        currentScore = score
    }
    
    
    internal func updateCurrentRank(rank: Int) {
        
        currentRank = rank
    }
    
    
    internal func resetRank() {
        
        currentRank = -1
    }
    
    
    internal func resetArray() {
        
        scores.removeAll()
    }
}
