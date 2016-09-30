//
//  Border.swift
//  Fly
//
//  Created by Vikram Ramkumar on 9/15/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit


class Border: UIView {
    
    
    let borderLine = CAShapeLayer()
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        drawLine()
    }
    
    
    internal func drawLine() {
        
        
        //Set border line
        let path = UIBezierPath()
        let width = self.bounds.width
        let height = self.bounds.height/2
        
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width, y: height))
        borderLine.path = path.cgPath
        borderLine.fillColor = UIColor.clear.cgColor
        borderLine.strokeColor = UIColor.lightGray.cgColor
        
        self.layer.addSublayer(borderLine)
    }
    
    
}
