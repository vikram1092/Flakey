//
//  Score.swift
//  Fly
//
//  Created by Vikram Ramkumar on 9/4/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit

class Score: UIView {
    
    
    var label1 = UILabel()
    var label2 = UILabel()
    let themeColor = Constants.highlightColor
    var score = 0
    var initialized = false

    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    
    internal func initializeViews() {
        
        
        print("Score initializeViews")
        if !initialized {
            
            initialized = true
            //Set shape
            self.backgroundColor = themeColor
            self.layer.cornerRadius = self.bounds.height/2
            self.clipsToBounds = true
            
            
            //Redeclare labels
            let height = CGFloat(20)
            label1 = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: height))
            label2 =  UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: height))
            
            //Initialize variables for labels
            label1.textAlignment = NSTextAlignment.center
            label1.textColor = UIColor.white
            label1.font = UIFont.systemFont(ofSize: 14)
            label2.textAlignment = NSTextAlignment.center
            label2.textColor = UIColor.white
            label2.font = UIFont.systemFont(ofSize: 14)
            
            //Add labels
            self.addSubview(label1)
            self.addSubview(label2)
            
            //Set labels to default values
            resetLabels()
        }
    }
    
    
    internal func resetLabels() {
        
        
        label1.text = nil
        label2.text = "1"
        
        label1.alpha = 1
        label2.alpha = 0
        
        score = 1
        
        //Adjust labels
        label1.center = CGPoint(x: label1.center.x, y: self.bounds.height/2)
        label2.center = CGPoint(x: label1.center.x, y: label1.center.y - (label1.bounds.height/2 + label2.bounds.height/2))
    }
    
    
    internal func increment() {
        
        
        //Prepare labels for pre-animation
        if label1.alpha == 1 && label1.text != nil {
            
            //Increment score on other label and move it above
            let incrementedScore = Int(label1.text!)! + 1
            label2.text = String(incrementedScore)
            score = incrementedScore
            label2.center = CGPoint(x: label1.center.x, y: label1.center.y - (label1.bounds.height/2 + label2.bounds.height/2))
            
        }
        else if label2.alpha == 1 {
            
            //Increment score on other label and move it above
            let incrementedScore = Int(label2.text!)! + 1
            label1.text = String(incrementedScore)
            score = incrementedScore
            label1.center = CGPoint(x: label2.center.x, y: label2.center.y - (label1.bounds.height/2 + label2.bounds.height/2))
        }
        
        
        //Animate transition
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            
            
            let distance = self.label1.bounds.height/2 + self.label2.bounds.height/2
            self.label1.center = CGPoint(x: self.label1.center.x, y: self.label1.center.y + distance)
            self.label2.center = CGPoint(x: self.label2.center.x, y: self.label2.center.y + distance)
            
            
            //Switch view alphas
            if self.label1.alpha == 1 {
                
                self.label1.alpha = 0
                self.label2.alpha = 1
            }
            else if self.label2.alpha == 1 {
                
                self.label1.alpha = 1
                self.label2.alpha = 0
            }
            
            
            }) { (Bool) in
                
                //Placeholder
        }
    }
    
    
    internal func getScore() -> Int {
        
        return score
    }
    
    
    internal func addPointsToScore() {
        
        score += 5
    }
    
    
}
