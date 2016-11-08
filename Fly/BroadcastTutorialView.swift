//
//  BroadcastTutorialView.swift
//  Flakey
//
//  Created by Vikram Ramkumar on 11/7/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit

class BroadcastTutorialView: UIView {
    
    
    let headingLabel = UILabel()
    let textLabel = UILabel()
    let borderLine = CAShapeLayer()
    let backgroundRect = CAShapeLayer()
    var trianglePath = CGMutablePath()
    var button = UIButton()
    var key: String?
    
    let triangleSideLength = CGFloat(30)
    let offset = CGFloat(0)
    let rectColor = Constants.secondaryColor
    let textColor = UIColor.white
    let borderColor = UIColor.white
    let userDefaults = UserDefaults.standard
    
    
    override init(frame: CGRect) {
        
        
        super.init(frame: frame)
        
        self.alpha = 0
        
        //Initialize background
        backgroundRect.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), cornerRadius: 25).cgPath
        backgroundRect.fillColor = rectColor.cgColor
        
        //Add all layers
        self.layer.addSublayer(backgroundRect)
    }
    
    
    internal func showText(_ heading: String, text: String) {
        
        
        //Set heading label
        headingLabel.frame = CGRect(x: 10, y: 10, width: self.bounds.width - 20, height: 30)
        headingLabel.text = heading
        headingLabel.font = UIFont.boldSystemFont(ofSize: 17)
        headingLabel.numberOfLines = 1
        headingLabel.textColor = textColor
        headingLabel.textAlignment = NSTextAlignment.center
        
        
        //Set border line
        let path = UIBezierPath()
        let height = CGFloat(43)
        path.move(to: CGPoint(x: 50, y: height))
        path.addLine(to: CGPoint(x: self.bounds.width - 50, y: height))
        borderLine.path = path.cgPath
        borderLine.fillColor = UIColor.clear.cgColor
        borderLine.strokeColor = textColor.cgColor
        
        
        //Set text label
        textLabel.frame = CGRect(x: 10, y: 50, width: self.bounds.width - 20, height: 40)
        textLabel.text = text
        textLabel.font = UIFont.boldSystemFont(ofSize: 12)
        textLabel.numberOfLines = 0
        textLabel.textColor = textColor
        textLabel.textAlignment = NSTextAlignment.center
        
        
        //Set button
        let buttonMargin = CGFloat(100)
        button = UIButton(type: .system)
        button.frame = CGRect(x: buttonMargin/2, y: textLabel.frame.maxY + 5, width: self.bounds.width - buttonMargin, height: 35)
        button.setTitle("OK", for: .normal)
        button.titleLabel!.font = UIFont(name: Constants.buttonFont, size: Constants.buttonFontSize)
        button.backgroundColor = textColor
        button.setTitleColor(rectColor, for: .normal)
        button.addTarget(self, action: #selector(removeView), for: .touchUpInside)
        button.layer.cornerRadius = button.bounds.height/2
        button.clipsToBounds = true
        
        
        //Add views
        self.addSubview(headingLabel)
        self.addSubview(textLabel)
        self.addSubview(button)
        self.layer.addSublayer(borderLine)
        
        //Show view
        UIView.animate(withDuration: 0.3, animations: { 
            
            self.alpha = 1
        }) 
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    internal func pointTriangleUp() {
        
        
        //Configure the triangle to be on top
        let frame = self.frame
        trianglePath = CGMutablePath()
        trianglePath.move(to: CGPoint(x: frame.width/2 - triangleSideLength/2, y: -offset))
        trianglePath.addLine(to: CGPoint(x: frame.width/2 + triangleSideLength/2, y: -offset))
        trianglePath.addLine(to: CGPoint(x: frame.width/2, y: -triangleSideLength/2 - offset))
        trianglePath.addLine(to: CGPoint(x: frame.width/2 - triangleSideLength/2 - 1, y: -offset))
        trianglePath.addLine(to: CGPoint(x: frame.width/2 - triangleSideLength/2, y: -offset))
        
        //Merge paths
        let path = CGMutablePath()
        path.addPath(trianglePath)
        path.addPath(backgroundRect.path!)
        backgroundRect.path = path
    }
    
    
    internal func pointTriangleDown() {
        
        
        //Configure the triangle to be at the bottom
        let frame = self.frame
        trianglePath = CGMutablePath()
        trianglePath.move(to: CGPoint(x: frame.width/2 - triangleSideLength/2, y: frame.height + offset))
        trianglePath.addLine(to: CGPoint(x: frame.width/2 + triangleSideLength/2, y: frame.height + offset))
        trianglePath.addLine(to: CGPoint(x: frame.width/2, y: frame.height + triangleSideLength/2 + offset))
        trianglePath.addLine(to: CGPoint(x: frame.width/2 - triangleSideLength/2 - 1, y: frame.height + offset))
        trianglePath.addLine(to: CGPoint(x: frame.width/2 - triangleSideLength/2, y: frame.height + offset))
        
        let path = CGMutablePath()
        path.addPath(trianglePath)
        path.addPath(backgroundRect.path!)
        backgroundRect.path = path
    }
    
    
    internal func setKey(newKey: String) {
        
        //Set new key
        key = newKey
    }
    
    
    internal func removeView() {
        
        
        //Disappear view upon touch
        UIView.animate(withDuration: 0.3, animations: {
            
            self.alpha = 0
            
        }, completion: { (Bool) in
            
            //Set key if not nil and remove view
            if self.key != nil {
                
                self.userDefaults.set(true, forKey: self.key!)
            }
            
            self.removeFromSuperview()
        }) 
    }
}
