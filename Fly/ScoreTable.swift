//
//  scoreTable.swift
//  Fly
//
//  Created by Vikram Ramkumar on 9/29/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ScoreTable: UITableViewController {
    
    
    let userDefaults = UserDefaults.standard
    var username = "---"
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        initializeParameters()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        tableView.delegate = self
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
        return cell
    }
    
    
    internal func numberOfRows(inSection section: Int) -> Int {
        
        return 4
    }
    
    
    internal func configureDatabase() {
        
        ref = FIRDatabase.database().reference()
    }
    
    
    internal func sendScore(data: [String: String]) {
        
        
        //Send score
        var mdata = data
        mdata["username"] = username
        
        //Push data to Firebase Database
        self.ref.child("score").childByAutoId().setValue(mdata)
    }
}
