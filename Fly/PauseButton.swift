//
//  PauseButton.swift
//  Fly
//
//  Created by Vikram Ramkumar on 10/12/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit


class PauseButton: UIButton {
    
    
    var initialized = false
    let layer1 = CAShapeLayer()
    let layer2 = CAShapeLayer()
    let buttonColor = Constants.highlightColor
    var hiding = true
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    internal func initializeViews() {
    
        
        if !initialized {
            
            //Set variables
            print("initializeViews")
            initialized = true
            let range = CGFloat(5)
            let height = CGFloat(15)
            let position1 = self.bounds.width/2 - range
            let position2 = self.bounds.width/2 + range
            let startY = self.bounds.height/2 - height/2
            
            //Create paths
            let path1 = UIBezierPath()
            path1.move(to: CGPoint(x: position1, y: startY))
            path1.addLine(to: CGPoint(x: position1, y: startY + height))
            
            let path2 = UIBezierPath()
            path2.move(to: CGPoint(x: position2, y: startY))
            path2.addLine(to: CGPoint(x: position2, y: startY + height))
            
            //Create pause shape layers
            layer1.path = path1.cgPath
            layer1.strokeColor = buttonColor.cgColor
            layer1.strokeStart = 0.0
            layer1.strokeEnd = 0.0
            layer1.lineWidth = 6
            layer1.lineCap = kCALineCapRound
            
            layer2.path = path2.cgPath
            layer2.strokeColor = buttonColor.cgColor
            layer2.strokeStart = 1.0
            layer2.strokeEnd = 1.0
            layer2.lineWidth = 6
            layer2.lineCap = kCALineCapRound

            self.layer.addSublayer(layer1)
            self.layer.addSublayer(layer2)
        }
    }
    
    
    internal func show() {
        
        if hiding {
            
            //Animate to show button, then allow user interaction
            print("pause button show")
            hiding = false
            self.alpha = 1
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                
                self.isUserInteractionEnabled = true
            }
            
            let animation1 = CABasicAnimation(keyPath: "strokeEnd")
            animation1.duration = 0.3
            animation1.fromValue = 0.0
            animation1.toValue = 1.0
            animation1.isRemovedOnCompletion = false
            animation1.fillMode = kCAFillModeForwards
            
            let animation2 = CABasicAnimation(keyPath: "strokeStart")
            animation2.duration = 0.3
            animation2.fromValue = 1.0
            animation2.toValue = 0.0
            animation2.isRemovedOnCompletion = false
            animation2.fillMode = kCAFillModeForwards
            
            layer1.add(animation1, forKey: nil)
            layer2.add(animation2, forKey: nil)
            
            CATransaction.commit()
        }
    }
    
    
    internal func hide() {
        
        if !hiding {
            
            //Animate to hide button and disallow user interaction
            print("pause button hide")
            hiding = true
            self.isUserInteractionEnabled = false
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                
                self.alpha = 0
            }
            
            let animation1 = CABasicAnimation(keyPath: "strokeEnd")
            animation1.duration = 0.3
            animation1.fromValue = 1.0
            animation1.toValue = 0.0
            animation1.isRemovedOnCompletion = false
            animation1.fillMode = kCAFillModeForwards
            
            let animation2 = CABasicAnimation(keyPath: "strokeStart")
            animation2.duration = 0.3
            animation2.fromValue = 0.0
            animation2.toValue = 1.0
            animation2.isRemovedOnCompletion = false
            animation2.fillMode = kCAFillModeForwards
            
            layer1.add(animation1, forKey: nil)
            layer2.add(animation2, forKey: nil)
            
            CATransaction.commit()
        }
    }
}
