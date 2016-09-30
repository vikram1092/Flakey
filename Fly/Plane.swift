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
    let planeColor = UIColor.gray
    let trailColor = UIColor.gray
    var superViewPosition = CGPoint(x: 0, y: 0)
    var animating = false
    let trail1 = CAShapeLayer()
    let trail2 = CAShapeLayer()
    let trail3 = CAShapeLayer()
    
    
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
        let path = PocketSVG.path(fromSVGFileNamed: "plane").takeUnretainedValue()
        
        planeLayer.path = path
        planeLayer.fillColor = UIColor.clear.cgColor
        planeLayer.strokeColor = planeColor.cgColor
        planeLayer.lineWidth = 2
        planeLayer.lineCap = kCALineCapRound
        
        
        
        //Set variables
        let range = CGFloat(5)
        let position1 = self.bounds.width/2 - range
        let position2 = self.bounds.width/2
        let position3 = self.bounds.width/2 + range
        let height = self.bounds.height + 15
        
        //Create paths
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x: position1, y: self.bounds.height + 3))
        path1.addLine(to: CGPoint(x: position1, y: height))
        
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: position2, y: self.bounds.height + 3))
        path2.addLine(to: CGPoint(x: position2, y: height))
        
        let path3 = UIBezierPath()
        path3.move(to: CGPoint(x: position3, y: self.bounds.height + 3))
        path3.addLine(to: CGPoint(x: position3, y: height))
        
        //Create trail layers
        trail1.path = path1.cgPath
        //trail1.fillColor = UIColor.clear.cgColor
        trail1.strokeColor = trailColor.cgColor
        trail1.strokeStart = 0.0
        trail1.strokeEnd = 0.0
        trail1.lineWidth = 1.5
        
        trail2.path = path2.cgPath
        //trail2.fillColor = UIColor.clear.cgColor
        trail2.strokeColor = trailColor.cgColor
        trail2.strokeStart = 0.0
        trail2.strokeEnd = 0.0
        trail2.lineWidth = 1.5
        
        trail3.path = path3.cgPath
        //trail3.fillColor = UIColor.clear.cgColor
        trail3.strokeColor = trailColor.cgColor
        trail3.strokeStart = 0.0
        trail3.strokeEnd = 0.0
        trail3.lineWidth = 1.5
        
        //Add all layers
        self.layer.addSublayer(planeLayer)
        self.layer.addSublayer(trail1)
        self.layer.addSublayer(trail2)
        self.layer.addSublayer(trail3)
    }
    
    
    internal func startAnimating() {
        
        
        //Start the animation loop
        if !animating {
            
            //Set animation flag
            animating = true
            
            animate()
        }
    }
    
    
    internal func animate() {
        
        
        //Create self referential looping block for trails
        CATransaction.setCompletionBlock {
            
            self.animate()
        }
        
        CATransaction.begin()
        
        let animation1 = animation(0.2)
        let animation2 = animation(0.4)
        let animation3 = animation(0.2)
        
        trail1.add(animation1, forKey: nil)
        trail2.add(animation2, forKey: nil)
        trail3.add(animation3, forKey: nil)
        
        CATransaction.commit()
    }
    
    
    internal func animation(_ startValue: CGFloat) -> CABasicAnimation {
        
        
        //Configure animation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = startValue
        animation.toValue = max(CGFloat(arc4random_uniform(100))/100.0, 0.4)
        animation.duration = 0.2
        animation.autoreverses = true
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        return animation
    }
}
