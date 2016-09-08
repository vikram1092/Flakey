//
//  ViewController.swift
//  Fly
//
//  Created by Vikram Ramkumar on 8/4/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    
    
    @IBOutlet var startButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var score: Score!
    
    var cloudTimer = NSTimer()
    var plane: Plane!
    var planeStartingPoint = CGPoint()
    var touchStartingPoint = CGPoint()
    var hideStatusBar = false
    
    var speed = CGFloat(1)
    var dynamicAnimator: UIDynamicAnimator!
    var cloudCollision: UICollisionBehavior!
    var boundaryCollision: UICollisionBehavior!
    var planeResistance: UIDynamicItemBehavior!
    var cloudResistance: UIDynamicItemBehavior!
    var planeElasticity: UIDynamicItemBehavior!
    var planeAttachment: UIAttachmentBehavior!
    var cloudPush: UIPushBehavior!
    var planePush: UIPushBehavior!
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialize views
        initializeViewsAfterLoad()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        super.viewDidAppear(animated)
        
        //Initialize views
        initializeViewsAfterAppear()
    }
    
    
    internal func initializeViewsAfterLoad() {
        
        
        //Initialize plane
        let planeSize = CGFloat(30)
        plane = Plane(frame: CGRect(x: 0, y: 0, width: planeSize, height: planeSize))
        self.view.addSubview(plane)
        
        plane.center = CGPoint(x: self.view.bounds.width/2 - plane.bounds.width, y: self.view.bounds.height - plane.bounds.height - 30)
        plane.alpha = 0
        
        initializeDynamicAnimator()
        
        //Cut start button corners
        startButton.layer.cornerRadius = startButton.bounds.height/2
        startButton.clipsToBounds = true
        
    }
    
    
    internal func initializeViewsAfterAppear() {
        
    }
    
    
    internal func initializeDynamicAnimator() {
        
        
        //Initialize animator and add plane behaviors
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        
        cloudCollision = UICollisionBehavior(items: [plane])
        cloudCollision.collisionMode = UICollisionBehaviorMode.Items
        cloudCollision.collisionDelegate = self
        dynamicAnimator.addBehavior(cloudCollision)
        
        boundaryCollision = UICollisionBehavior(items: [plane])
        boundaryCollision.collisionMode = UICollisionBehaviorMode.Boundaries
        boundaryCollision.translatesReferenceBoundsIntoBoundary = true
        dynamicAnimator.addBehavior(self.boundaryCollision)
        
        planeElasticity = UIDynamicItemBehavior(items: [plane])
        planeElasticity.elasticity = 1.0
        dynamicAnimator.addBehavior(self.planeElasticity)
        
        
        cloudResistance = UIDynamicItemBehavior(items: [])
        cloudResistance.resistance = 0
        
        dynamicAnimator.addBehavior(cloudResistance)
        
    }
    
    
    internal func resetView() {
        
        
        self.titleLabel.hidden = false
        self.startButton.hidden = false
        hideStatusBar = false
        cloudTimer.invalidate()
        
        //Animate button fade and start game
        UIView.animateWithDuration(0.3, animations: {
            
            self.titleLabel.alpha = 1
            self.startButton.alpha = 1
            
            self.score.alpha = 0
            self.plane.alpha = 0
            
            for subview in self.view.subviews {
                
                if subview is Cloud {
                    
                    subview.removeFromSuperview()
                }
            }
            
        }) { (Bool) in
            
            self.setNeedsStatusBarAppearanceUpdate()
            self.startButton.userInteractionEnabled = true
            self.score.resetLabels()
            
            self.dynamicAnimator.removeAllBehaviors()
            self.plane.center = CGPoint(x: self.view.bounds.width/2 - self.plane.bounds.width, y: self.view.bounds.height - self.plane.bounds.height - 30)
            
            self.initializeDynamicAnimator()
        }
    }
    
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        
        
        //Disable button
        startButton.userInteractionEnabled = false
        hideStatusBar = true
        
        //Animate button fade and start game
        UIView.animateWithDuration(0.3, animations: { 
            
            self.titleLabel.alpha = 0
            self.startButton.alpha = 0
            
            self.score.alpha = 1
            self.plane.alpha = 1
            
            }) { (Bool) in
                
                self.setNeedsStatusBarAppearanceUpdate()
                self.titleLabel.hidden = true
                self.startButton.hidden = true
                self.fly()
                
        }
    }
    
    
    internal func fly() {
        
        
        //Animate clouds with timer
        cloudTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(sendCloud), userInfo: nil, repeats: true)
        cloudTimer.fire()
    }
    
    
    internal func sendCloud() {
        
        
        //Create new cloud of varying length
        let width = CGFloat(randomCloudWidth())
        let height = CGFloat(50)
        let horizontalLocation = max(CGFloat(arc4random_uniform(UInt32(self.view.bounds.width - width - 20))), 20)
        let cloud = Cloud(frame: CGRect(x: horizontalLocation, y: -height, width: width, height: height))
        
        self.view.addSubview(cloud)
        
        
        //Increment score
        self.score.increment()
        
        cloudCollision.addItem(cloud)
        
        //Push cloud
        cloudPush = UIPushBehavior(items: [cloud], mode: UIPushBehaviorMode.Instantaneous)
        cloudPush.pushDirection = CGVector(dx: 0, dy: 1)
        cloudPush.magnitude = speed * cloud.bounds.width * 0.01
        
        
        cloudResistance.addItem(cloud)
        dynamicAnimator.addBehavior(cloudPush)
        
        
        
        /*
        CATransaction.begin()
        CATransaction.setCompletionBlock { 
            
            self.collision.removeItem(cloud)
            cloud.removeFromSuperview()
        }
        
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.duration = speed
        animation.fromValue = NSNumber(float: Float(cloud.center.y))
        animation.toValue = NSNumber(float: Float(self.view.bounds.height + cloud.bounds.height/2))
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        
        cloud.layer.addAnimation(animation, forKey: nil)
        CATransaction.commit()
        */
        
        
        //Animate new cloud across screen and remove it
        /*
        UIView.animateWithDuration(speed, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { 
            
            cloud.center = CGPoint(x: cloud.center.x, y: self.view.bounds.height + cloud.bounds.height/2)
            
            }) { (Bool) in
                
                self.collision.removeItem(cloud)
                cloud.removeFromSuperview()
        }*/
    }

    
    internal func randomCloudWidth() -> CGFloat {
        
        
        //Return random number divisible by current arc length to use while generating cloud
        let divisor = CGFloat(25)
        let upperLimit = UInt32((self.view.bounds.width - plane.bounds.width)/divisor) - 1
        let randomNumber = max(arc4random_uniform(upperLimit) * UInt32(divisor), UInt32(divisor) * 3)
        
        return CGFloat(randomNumber)
    }
    
    
    @IBAction func planeFlown(sender: UIPanGestureRecognizer) {
        
        
        switch sender.state {
            
            /*
        case .Changed:
            
            
            if plane.alpha == 1 {
                
                
                //Cancel any previous plane push behavior
                if planePush != nil {
                    
                    dynamicAnimator.removeBehavior(planePush)
                }
                
                //Set translation difference and sensitivity
                let translation = sender.translationInView(self.view)
                
                //Set plane's push behavior
                planePush = UIPushBehavior(items: [plane], mode: UIPushBehaviorMode.Continuous)
                planePush.magnitude = 0
                planePush.pushDirection = CGVector(dx: translation.x, dy: 0)
                planePush.magnitude = sqrt(translation.x * translation.x + translation.y * translation.y)/20
                
                dynamicAnimator.addBehavior(planePush)
            }
            
        case .Cancelled, .Ended:
            
            
            //Cancel any ongoing plane push behavior
            dynamicAnimator.removeBehavior(planePush)
            
            
            /*
            //Set movement according to difference accounting for view bounds as limitations
            let horizontalMovement = min(max(planeStartingPoint.x + horizontalDifference,  plane.bounds.width/2), self.view.bounds.width - plane.bounds.width/2)
            let verticalMovement = min(max(planeStartingPoint.y + verticalDifference, plane.bounds.height/2), self.view.bounds.height - plane.bounds.height/2)
            
            UIView.animateWithDuration(0.1, animations: {
                
                self.plane.center = CGPoint(x: horizontalMovement, y: verticalMovement)
            })*/
            
        default: ()
            */
            
            /*
        case .Began:
            
            //Record starting point for frame of reference
            planeStartingPoint = plane.center
            touchStartingPoint = sender.translationInView(self.view)
            
        case .Changed:
            
            //Set translation difference and sensitivity
            let sensitivity = CGFloat(3)
            let translation = sender.translationInView(self.view)
            let horizontalDifference = (touchStartingPoint.x - translation.x) * sensitivity
            let verticalDifference = (touchStartingPoint.y - translation.y) * sensitivity
            
            //Set movement according to difference accounting for view bounds as limitations
            let horizontalMovement = min(max(planeStartingPoint.x + horizontalDifference,  plane.bounds.width/2), self.view.bounds.width - plane.bounds.width/2)
            let verticalMovement = min(max(planeStartingPoint.y + verticalDifference, plane.bounds.height/2), self.view.bounds.height - plane.bounds.height/2)
            
            self.plane.center = CGPoint(x: horizontalMovement, y: verticalMovement)
 */
            
        case .Began:
            
            //Create a blank view and attach the plane to it
            //Place blank view at user's touch
            let translation = sender.translationInView(self.view)
            /*
            let viewSize = CGFloat(6)
            let blankView = UIView(frame: CGRect(x: translation.x - viewSize/2, y: translation.y - viewSize/2, width: viewSize, height: viewSize))
            self.view.addSubview(blankView)
            */
            
            //Create to attach plane
            planeAttachment = UIAttachmentBehavior(item: plane, attachedToAnchor: translation)
            dynamicAnimator.addBehavior(planeAttachment)
            
            
        case .Changed:
            
            planeAttachment.anchorPoint = sender.translationInView(self.view)
            
        case .Ended:
            
            dynamicAnimator.removeBehavior(planeAttachment)
            
        default: ()
            
        }
    }
    
    
    internal func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        
        print("Collision!")
        //dynamicAnimator.removeAllBehaviors()
        self.resetView()
        
        planeResistance = UIDynamicItemBehavior(items: [plane])
        planeResistance.resistance = 1.0
        dynamicAnimator.addBehavior(planeResistance)
        
    }
    
    
    internal func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem) {
        
        print("Collision!")
        //dynamicAnimator.removeAllBehaviors()
        //self.resetView()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        
        if hideStatusBar {
            
            return true
        }
        
        return false
    }
    
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        
        return UIStatusBarAnimation.Slide
    }
}

