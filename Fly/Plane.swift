//
//  Plane.swift
//  Fly
//
//  Created by Vikram Ramkumar on 8/5/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit

class Plane: UIView {
    
    
    let planeLayer = CAShapeLayer()
    let planeColor = UIColor.grayColor()
    var superViewPosition = CGPoint(x: 0, y: 0)
    var lastPosition = CGFloat(0)
    var animating = false
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        initializeViews()
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        initializeViews()
    }

    
    internal func initializeViews() {
        
        
        //Intialize plane view
        let path = PocketSVG.pathFromSVGFileNamed("plane").takeUnretainedValue()
        
        planeLayer.path = path
        planeLayer.fillColor = UIColor.clearColor().CGColor
        planeLayer.strokeColor = planeColor.CGColor
        planeLayer.lineWidth = 2
        planeLayer.lineCap = kCALineCapRound
        
        self.layer.addSublayer(planeLayer)
    }
    
    
    internal func startAnimating() {
        
        //Start the animation loop
        if !animating {
            
            animating = true
            animate()
            animate()
            animate()
        }
    }
    
    
    internal func animate() {
        
        let range = UInt32(10)
        var position = self.bounds.width/2 - CGFloat(range) + CGFloat(arc4random_uniform(range))
        let height = self.bounds.height + max(CGFloat(arc4random_uniform(UInt32(self.bounds.height))) * 0.5, 7)
        
        
        while position == lastPosition {
            
            position = CGFloat(arc4random_uniform(UInt32(self.bounds.width)))
        }
        
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: position, y: self.bounds.height + 3))
        path.addLineToPoint(CGPoint(x: position, y: height))
        
        //Create shape layer for trail
        let trail = CAShapeLayer()
        trail.path = path.CGPath
        trail.fillColor = UIColor.clearColor().CGColor
        trail.strokeColor = UIColor.lightGrayColor().CGColor
        trail.strokeStart = 0.0
        trail.strokeEnd = 0.0
        trail.lineWidth = 2
        
        
        //Configure animation
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            
            //Remove trail and start over
            trail.removeFromSuperlayer()
            self.animate()
        }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.5
        animation.removedOnCompletion = true
        
        self.layer.addSublayer(trail)
        trail.addAnimation(animation, forKey: nil)
        
        CATransaction.commit()
        
    }
    
    
}