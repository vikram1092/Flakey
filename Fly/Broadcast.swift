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
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var score = UILabel()
    var bestScore = UILabel()
    var scoreHeader = UILabel()
    var bestScoreHeader = UILabel()
    let scoreColor = UIColor(red: 211.0/255.0, green: 84.0/255.0, blue: 63.0/255.0, alpha: 1)
    let headerColor = UIColor.lightGrayColor()
    var initialized = false
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        initializeViews()
    }
    
    
    internal func initializeViews() {
        
        print("initializeViews for  broadcast")
        //Fix flag for initialized
        if self.bounds.width > 0 {
            
            initialized = true
        }
        
        //Turn invisible first
        self.alpha = 0
        
        
        //Initialize score header view
        let scoreHeaderWidth = self.bounds.width
        scoreHeader = UILabel(frame: CGRect(x: 0, y: 0, width: scoreHeaderWidth, height: 20))
        scoreHeader.font = UIFont.systemFontOfSize(15)
        scoreHeader.textAlignment = NSTextAlignment.Center
        scoreHeader.textColor = headerColor
        scoreHeader.text = "SCORE"
        self.addSubview(scoreHeader)
        
        
        //Initialize score view
        score = UILabel(frame: CGRect(x: 0, y:scoreHeader.frame.maxY + 10, width: self.bounds.width, height: 80))
        score.font = UIFont.systemFontOfSize(90, weight: UIFontWeightUltraLight)
        score.textAlignment = NSTextAlignment.Center
        score.textColor = scoreColor
        self.addSubview(score)
        
        
        //Initialize best score border
        let bestScoreBorderWidth = self.bounds.width
        let bestScoreBorder = Border(frame: CGRect(x: 0, y: score.frame.maxY + 10, width: bestScoreBorderWidth, height: 10))
        self.addSubview(bestScoreBorder)
        
        
        //Initialize best score header view
        let bestScoreHeaderWidth = self.bounds.width
        bestScoreHeader = UILabel(frame: CGRect(x: 0, y: bestScoreBorder.frame.maxY + 10, width: bestScoreHeaderWidth, height: 20))
        bestScoreHeader.font = UIFont.systemFontOfSize(15)
        bestScoreHeader.textAlignment = NSTextAlignment.Center
        bestScoreHeader.textColor = headerColor
        bestScoreHeader.text = "BEST"
        self.addSubview(bestScoreHeader)
        
        
        //Initialize best score view
        bestScore = UILabel(frame: CGRect(x: 0, y: bestScoreHeader.frame.maxY + 10, width: self.bounds.width, height: 40))
        bestScore.font = UIFont.systemFontOfSize(40, weight: UIFontWeightUltraLight)
        bestScore.textAlignment = NSTextAlignment.Center
        bestScore.textColor = scoreColor
        self.addSubview(bestScore)
        
        
        //Set best score
        setBestScoreLabel()
    }
    
    
    internal func setScoreLabel(newScore: Int) {
        
        score.text = String(newScore)
    }
    
    
    internal func setBestScoreLabel() {
        
        let best = userDefaults.integerForKey("bestScore")
        bestScore.text = String(best)
    }
}