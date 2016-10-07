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
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        print("viewDidAppear table")
        tableView.reloadData()
        print(tableView.numberOfRows(inSection: 0))
    }
    
    
    internal func initializeParameters() {
        
        
        if userDefaults.object(forKey: "username") != nil {
            
            username = userDefaults.object(forKey: "username") as! String
        }
    }
    
    
    internal override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        print("cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let rankLabel = cell.viewWithTag(1) as! UILabel
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let scoreLabel = cell.viewWithTag(3) as! UILabel
        let scoreIndex = scores.count - indexPath.row - 1
        
        
        rankLabel.text = String(indexPath.row)
        
        nameLabel.text = String(describing: scores[scoreIndex][Constants.username]!)
        
        scoreLabel.text = String(describing: scores[scoreIndex][Constants.score]!)
        
        
        return cell
    }
    
    
    internal override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return scores.count
    }
    
    
    internal func refresh() {
        
        tableView.reloadData()
    }
}
