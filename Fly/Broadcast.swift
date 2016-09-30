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
    //var scoreboard = Scoreboard()
    let scoreColor = UIColor(red: 211.0/255.0, green: 84.0/255.0, blue: 63.0/255.0, alpha: 1)
    let headerColor = UIColor.lightGray
    var initialized = false
    
    var scores = [String]()
    var activityIndicator = UIActivityIndicatorView()
    var activityIndicatorColor = UIColor.gray
    var scoreTable = UIView()
    
    
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
        
        //Initialize score header view
        let scoreHeaderWidth = self.bounds.width
        scoreHeader = UILabel(frame: CGRect(x: 0, y: 0, width: scoreHeaderWidth, height: 20))
        scoreHeader.font = UIFont.systemFont(ofSize: 15)
        scoreHeader.textAlignment = NSTextAlignment.center
        scoreHeader.textColor = headerColor
        scoreHeader.text = "SCORE"
        self.addSubview(scoreHeader)
        
        
        //Initialize score view
        score = UILabel(frame: CGRect(x: 0, y:scoreHeader.frame.maxY + 10, width: self.bounds.width, height: 80))
        score.font = UIFont.systemFont(ofSize: 90, weight: UIFontWeightUltraLight)
        score.textAlignment = NSTextAlignment.center
        score.textColor = scoreColor
        self.addSubview(score)
        
        
        //Initialize best score border
        let bestScoreBorderWidth = self.bounds.width
        let bestScoreBorder = Border(frame: CGRect(x: 0, y: score.frame.maxY + 10, width: bestScoreBorderWidth, height: 10))
        self.addSubview(bestScoreBorder)
        
        
        //Initialize best score header view
        let bestScoreHeaderWidth = self.bounds.width
        bestScoreHeader = UILabel(frame: CGRect(x: 0, y: bestScoreBorder.frame.maxY + 10, width: bestScoreHeaderWidth, height: 20))
        bestScoreHeader.font = UIFont.systemFont(ofSize: 15)
        bestScoreHeader.textAlignment = NSTextAlignment.center
        bestScoreHeader.textColor = headerColor
        bestScoreHeader.text = "BEST"
        self.addSubview(bestScoreHeader)
        
        
        //Initialize best score view
        bestScore = UILabel(frame: CGRect(x: 0, y: bestScoreHeader.frame.maxY + 10, width: self.bounds.width, height: 40))
        bestScore.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightUltraLight)
        bestScore.textAlignment = NSTextAlignment.center
        bestScore.textColor = scoreColor
        self.addSubview(bestScore)
        
        
        //Initialize top scores border
        let scoreboardBorderWidth = self.bounds.width
        let scoreboardBorder = Border(frame: CGRect(x: 0, y: bestScore.frame.maxY + 10, width: scoreboardBorderWidth, height: 10))
        self.addSubview(scoreboardBorder)
        
        
        //Initialize best score header view
        let scoreboardHeaderWidth = self.bounds.width
        scoreboardHeader = UILabel(frame: CGRect(x: 0, y: scoreboardBorder.frame.maxY + 10, width: scoreboardHeaderWidth, height: 20))
        scoreboardHeader.font = UIFont.systemFont(ofSize: 15)
        scoreboardHeader.textAlignment = NSTextAlignment.center
        scoreboardHeader.textColor = headerColor
        scoreboardHeader.text = "SCOREBOARD"
        self.addSubview(scoreboardHeader)
        
        
        //Add table container to it
        scoreTable = self.viewWithTag(1)!
        
        
        //Initialize and add activity indicator
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: self.bounds.width/2, y: scoreTable.center.y)
        
        activityIndicator.startAnimating()
        
        
        //Set best score
        setBestScoreLabel()
    }
    
    
    internal func showScoreboard() {
        
        
        //Update UI
        activityIndicator.stopAnimating()
        
        UIView.animate(withDuration: 0.3) {
            
            self.scoreTable.alpha = 1
        }
    }
    
    
    internal func setScoreLabel(_ newScore: Int) {
        
        score.text = String(newScore)
    }
    
    
    internal func setBestScoreLabel() {
        
        let best = userDefaults.integer(forKey: "bestScore")
        bestScore.text = String(best)
    }
}
