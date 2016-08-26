//
//  ViewController.swift
//  Fly
//
//  Created by Vikram Ramkumar on 8/4/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var timer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        fly()
        
    }
    
    
    internal func fly() {
        
        //Animate clouds with timer
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(sendCloud), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    
    internal func sendCloud() {
        
        //Create new cloud
        let width = CGFloat(150)
        let height = CGFloat(100)
        let horizontalLocation = max(CGFloat(arc4random_uniform(UInt32(self.view.bounds.width - width - 20))), 20)
        let cloud = CloudView(frame: CGRect(x: horizontalLocation, y: -height, width: width, height: height))
        
        self.view.addSubview(cloud)
        
        //Animate new cloud across screen
        UIView.animateWithDuration(5, animations: {
            
            cloud.center = CGPoint(x: cloud.center.x, y: cloud.center.y + 1000)
            }) { (Bool) in
                
                cloud.removeFromSuperview()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func planeFlown(sender: UIPanGestureRecognizer) {
        
        let plane = sender.view as! Plane
        
        switch sender.state {
            
        case .Began:
            
            plane.setPositionInSuperView(plane.center)
            
        case .Changed:
            
            let translation = sender.translationInView(plane.superview)
            plane.center = CGPoint(x: plane.superViewPosition.x + translation.x, y: plane.superViewPosition.y + translation.y)
            
        default: ()
        }
    }
}

