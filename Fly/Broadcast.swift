//
//  Broadcast.swift
//  Fly
//
//  Created by Vikram Ramkumar on 9/15/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit


class Broadcast: UIView {
    
    
    let userDefaults = UserDefaults.standard
    var score = UILabel()
    var bestScore = UILabel()
    var scoreHeader = UILabel()
    var bestScoreHeader = UILabel()
    var scoreboardHeader = UILabel()
    let scoreColor = UIColor(red: 211.0/255.0, green: 84.0/255.0, blue: 63.0/255.0, alpha: 1)
    let headerColor = UIColor.lightGray
    var initialized = false
    
    var activityIndicator = UIActivityIndicatorView()
    var activityIndicatorColor = UIColor.gray
    var scoreTableView = UIView()
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    
    internal func initializeViews() {
        
        
        print("initializeViews for  broadcast")
        //Fix flag for initialized
        initialized = true
        
        //Turn invisible first
        self.alpha = 0
        
        
        //Initialize all views
        scoreHeader = self.viewWithTag(1)! as! UILabel
        score = self.viewWithTag(2)! as! UILabel
        let bestScoreBorder = self.viewWithTag(3)! as! Border
        bestScoreBorder.drawLine()
        bestScoreHeader = self.viewWithTag(4)! as! UILabel
        bestScore = self.viewWithTag(5)! as! UILabel
        let scoreboardBorder = self.viewWithTag(6)! as! Border
        scoreboardBorder.drawLine()
        scoreboardHeader = self.viewWithTag(7)! as! UILabel
        scoreTableView = self.viewWithTag(8)!
        
        
        //Initialize and add activity indicator
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: self.bounds.width/2, y: scoreTableView.center.y)
        
        
        //Set best score
        setBestScoreLabel()
    }
    
    
    internal func showScoreboard() {
        
        
        //Start animating activity indicator and show the score table
        print("showScoreboard")
        activityIndicator.stopAnimating()
        
        UIView.animate(withDuration: 0.3) {
            
            self.scoreTableView.alpha = 1
        }
    }
    
    
    internal func hideScoreBoard() {
        
        //Hide the score table and start animating activity indicator
        print("hideScoreboard")
        self.scoreTableView.alpha = 0
        activityIndicator.startAnimating()
    }
    
    
    internal func setScoreLabel(_ newScore: Int) {
        
        //Set score label
        score.text = String(newScore)
    }
    
    
    internal func getScore() -> Int {
        
        
        //Get score from score label
        if score.text != "" {
            
            return Int(score.text!)!
        }
        
        return 0
    }
    
    
    internal func setBestScoreLabel() {
        
        let best = userDefaults.integer(forKey: "bestScore")
        bestScore.text = String(best)
    }
}
