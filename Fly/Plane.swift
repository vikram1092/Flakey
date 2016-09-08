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
        
        
        //Intialize plane view
        let path = PocketSVG.pathFromSVGFileNamed("plane").takeUnretainedValue()
        
        planeLayer.path = path
        planeLayer.fillColor = UIColor.clearColor().CGColor
        planeLayer.strokeColor = planeColor.CGColor
        planeLayer.lineWidth = 2
        planeLayer.lineCap = kCALineCapRound
        
        self.layer.addSublayer(planeLayer)
    }
    
    
}