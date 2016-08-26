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
    
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        initializeViews()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        initializeViews()
    }

    internal func initializeViews() {
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: self.bounds.width/2, y: 0))
        path.addLineToPoint(CGPoint(x: 0, y: self.bounds.height))
        path.addLineToPoint(CGPoint(x: self.bounds.width/2, y: self.bounds.height*0.8))
        path.addLineToPoint(CGPoint(x: self.bounds.width, y: self.bounds.height))
        path.addLineToPoint(CGPoint(x: self.bounds.width/2, y: 0))
        
        planeLayer.path = path.CGPath
        planeLayer.fillColor = UIColor.clearColor().CGColor
        planeLayer.strokeColor = planeColor.CGColor
        planeLayer.lineWidth = 4
        planeLayer.lineCap = kCALineCapRound
        
        self.layer.addSublayer(planeLayer)
    }
    
    
    internal func setPositionInSuperView(position: CGPoint) {
        
        superViewPosition = position
    }
    
}