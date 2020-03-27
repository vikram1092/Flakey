//
//  Backdrop.swift
//  Flakey
//
//  Created by Vikram Ramkumar on 10/27/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit

class Backdrop: UIView {
    
    
    var initialized = false
    var filterView: UIView!
    var flakeTimer: Timer!
    let themeColor = Constants.secondaryColor
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    internal func initializeViews() {
    
        if !initialized {
            
            //Create filter view
            filterView = self.viewWithTag(20)!
            filterView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
            self.addSubview(filterView)
            
            //Send flakes
            sendFlakes()
        }
    }
    
    
    internal func sendFlakes() {
        
        //Nullify and then (re)schedule timer
        if flakeTimer != nil {
            
            flakeTimer.invalidate()
            flakeTimer = nil
        }
        
        flakeTimer = Timer.scheduledTimer(timeInterval: 1.6, target: self, selector: #selector(sendFlake), userInfo: nil, repeats: true)
        flakeTimer.fire()
    }
    
    
    @objc internal func sendFlake() {
        
        //Create flakes
        let number = Int(self.bounds.width/150)
        var flakes = Array<UIImageView>()
        
        for i in 0...number {
            
            let flake = UIImageView(image: UIImage(named: "backdropSmall"))
            let horizontalMultiplier = flake.bounds.width/2 + CGFloat(i * 150) + CGFloat(arc4random_uniform(100)) - 50
            let horizontalPosition = min(horizontalMultiplier, self.bounds.width - flake.bounds.width/2)
            let verticalPosition = max(flake.bounds.height, CGFloat(arc4random_uniform(100)))
            
            self.insertSubview(flake, belowSubview: filterView)
            flake.center = CGPoint(x: horizontalPosition, y: -verticalPosition)
            flakes.append(flake)
        }
        
        //Animate flakes
        UIView.animate(withDuration: 10, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            for flake in flakes {
                
                flake.center.y = flake.center.y + self.bounds.height + 100
            }
            }) { (Bool) in
                
                //Remove flakes from view
                for flake in flakes {
                    
                    flake.removeFromSuperview()
                }
        }
    }
}
