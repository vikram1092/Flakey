//
//  CloudView.swift
//  Fly
//
//  Created by Vikram Ramkumar on 8/4/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit


class CloudView: UIView {
    
    
    
    required init?(coder aDecoder: NSCoder) {
        
        
        super.init(coder: aDecoder)
        initializeViews()
        
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        initializeViews()
    }
    
    
    internal func initializeViews() {
        
        
        let bounds = self.bounds
        let arcSize = CGFloat(25)
        var horizontalPosition = CGFloat(0)
        let verticalPosition = CGFloat(self.bounds.height/2)
        let maxVerticalDeviation = arcSize - 10
        let incrementBy = arcSize
        
        
        while horizontalPosition < bounds.width {
            
            if horizontalPosition == 0 {
                
                //Create first arc
                let arc = Arc(frame: CGRect(x: horizontalPosition, y: verticalPosition - arcSize * 0.4, width: arcSize, height: arcSize * 1.5))
                arc.transform = CGAffineTransformMakeRotation(CGFloat(M_PI)/2)
                
                self.addSubview(arc)
                
                //Increment
                horizontalPosition += arcSize/2
            }
            else if horizontalPosition + incrementBy >= self.bounds.width {
                
                //Create last arc
                let arc = Arc(frame: CGRect(x: horizontalPosition - arcSize/2, y: verticalPosition - arcSize * 0.4, width: arcSize, height: arcSize * 1.5))
                arc.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI)/2)
                
                self.addSubview(arc)
                
                //Increment
                horizontalPosition += incrementBy
            }
            else {
                
                //Create all arcs in the middle
                let distanceToCenter = abs(self.bounds.width/2 - (horizontalPosition + arcSize/2))
                let verticalOffset = maxVerticalDeviation * (1.0 - (distanceToCenter/self.bounds.width))
                
                
                let arc1 = Arc(frame: CGRect(x: horizontalPosition, y: verticalPosition - verticalOffset, width: arcSize, height: arcSize/1.5))
                arc1.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI))
                
                let arc2 = Arc(frame: CGRect(x: horizontalPosition, y: verticalPosition + verticalOffset, width: arcSize, height: arcSize/1.5))
                
                self.addSubview(arc1)
                self.addSubview(arc2)
                
                //Increment
                horizontalPosition += incrementBy
            }
            
        }
    }
    
    
    internal func randomNumber() -> CGFloat {
        
        return max(0.5, CGFloat(arc4random_uniform(UInt32(10)))/10)
    }
}