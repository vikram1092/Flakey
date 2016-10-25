//
//  Flake.swift
//  Fly
//
//  Created by Vikram Ramkumar on 8/5/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit

class Flake: UIView {
    
    var flakeView = UIView()
    let flakeLayer = CAShapeLayer()
    let flakeColor = UIColor.gray
    let trailColor = UIColor.gray
    var superViewPosition = CGPoint(x: 0, y: 0)
    var animating = false
    let trail1 = CAShapeLayer()
    let trail2 = CAShapeLayer()
    let trail3 = CAShapeLayer()
    let rotate = CABasicAnimation(keyPath: "transform.rotation")
    let reverseRotate = CABasicAnimation(keyPath: "transform.rotation")
    var direction = 1.0
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        initializeViews()
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        initializeViews()
    }

    
    internal func initializeViews() {
        
        
        //Intialize flake view
        //self.backgroundColor = UIColor.green
        let path = PocketSVG.path(fromSVGFileNamed: "snowflake").takeUnretainedValue()
        
        flakeLayer.path = path
        flakeLayer.fillColor = UIColor.white.cgColor
        flakeLayer.strokeColor = flakeColor.cgColor
        flakeLayer.lineWidth = 1.5
        flakeLayer.lineCap = kCALineCapRound
        
        
        //Set variables
        let domain = CGFloat(9)
        let range = CGFloat(3)
        let position1 = self.bounds.width/2 - domain
        let position2 = self.bounds.width/2
        let position3 = self.bounds.width/2 + domain
        let startingPoint = CGFloat(-20)
        let height = startingPoint - 15
        
        //Create paths
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x: position1, y: startingPoint + range))
        path1.addLine(to: CGPoint(x: position1, y: height))
        
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: position2, y: startingPoint))
        path2.addLine(to: CGPoint(x: position2, y: height))
        
        let path3 = UIBezierPath()
        path3.move(to: CGPoint(x: position3, y: startingPoint + range))
        path3.addLine(to: CGPoint(x: position3, y: height))
        
        //Create trail layers
        trail1.path = path1.cgPath
        trail1.strokeColor = trailColor.cgColor
        trail1.strokeStart = 0.0
        trail1.strokeEnd = 0.0
        trail1.lineWidth = 1.5
        
        trail2.path = path2.cgPath
        trail2.strokeColor = trailColor.cgColor
        trail2.strokeStart = 0.0
        trail2.strokeEnd = 0.0
        trail2.lineWidth = 1.5
        
        trail3.path = path3.cgPath
        trail3.strokeColor = trailColor.cgColor
        trail3.strokeStart = 0.0
        trail3.strokeEnd = 0.0
        trail3.lineWidth = 1.5
        
        //Add all layers
        let size = CGFloat(40)
        flakeView = UIView(frame: CGRect(x: self.center.x - size/2, y: self.center.y - size/2, width: size, height: size))
        //flakeView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        flakeView.layer.addSublayer(flakeLayer)
        self.addSubview(flakeView)
        self.layer.addSublayer(trail1)
        self.layer.addSublayer(trail2)
        self.layer.addSublayer(trail3)
    }
    
    
    internal func startAnimating() {
        
        //Start the animation loop
        if !animating {
            
            //Set animation flag
            animating = true
            animateTrails()
            rotateSnowflake(initialAngle: 0)
        }
    }
    
    
    internal func animateTrails() {
        
        
        //Create self referential looping block for trails
        CATransaction.setCompletionBlock {
            
            self.animateTrails()
        }
        
        CATransaction.begin()
        
        let animation1 = trailAnimation(0.2)
        let animation2 = trailAnimation(0.4)
        let animation3 = trailAnimation(0.2)
        
        trail1.add(animation1, forKey: nil)
        trail2.add(animation2, forKey: nil)
        trail3.add(animation3, forKey: nil)
        
        CATransaction.commit()
        
        self.layer.removeAllAnimations()
    }
    
    
    internal func trailAnimation(_ startValue: CGFloat) -> CABasicAnimation {
        
        
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
    
    
    internal func rotateSnowflake(initialAngle: Double) {
        

        if animating {
            
            //Rotate from current angle to a random angle, then repeat
            let rotateAngle = direction * Double(arc4random())/Double(UINT32_MAX) * M_PI * 2
            CATransaction.setCompletionBlock {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                    
                    self.rotateSnowflake(initialAngle: rotateAngle)
                })
            }
            CATransaction.begin()
            
            //Rotate subview
            let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
            rotate.duration = 2.5
            rotate.fromValue = initialAngle
            rotate.toValue = rotateAngle
            rotate.fillMode = kCAFillModeForwards
            rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            rotate.isRemovedOnCompletion = false
            flakeView.layer.add(rotate, forKey: "rotate")
            
            //Reverse direction for next rotation
            direction = -direction
            
            CATransaction.commit()
        }
    }
}
