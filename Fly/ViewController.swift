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
    @IBOutlet var flyGesture: UIPanGestureRecognizer!
    
    var cloudTimer = NSTimer()
    var speedTimer = NSTimer()
    var plane: Plane!
    var planeStartingPoint = CGPoint()
    var touchStartingPoint = CGPoint()
    var hideStatusBar = false
    var broadcast = Broadcast()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var speed = CGFloat(1)
    var dynamicAnimator: UIDynamicAnimator!
    var cloudCollision: UICollisionBehavior!
    var boundaryCollision: UICollisionBehavior!
    var planeResistance: UIDynamicItemBehavior!
    var cloudResistance: UIDynamicItemBehavior!
    var planeElasticity: UIDynamicItemBehavior!
    var rotationRestriction: UIDynamicItemBehavior!
    var planeSnap: UISnapBehavior!
    var cloudPush: UIPushBehavior!
    
    
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
        
        plane.center = self.view.center
        plane.alpha = 0
        plane.startAnimating()
        
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
        
        rotationRestriction = UIDynamicItemBehavior(items: [plane])
        rotationRestriction.allowsRotation = false
        dynamicAnimator.addBehavior(rotationRestriction)
        
        
        cloudResistance = UIDynamicItemBehavior(items: [])
        cloudResistance.resistance = 0
        
        
        dynamicAnimator.addBehavior(cloudResistance)
        
    }
    
    
    internal func resetView(finalScore: Int?) {
        
        
        flyGesture.enabled = false
        titleLabel.hidden = false
        startButton.hidden = false
        
        plane.hidden = true
        hideStatusBar = false
        cloudTimer.invalidate()
        speedTimer.invalidate()
        speed = CGFloat(1)
        
        if finalScore != nil {
            
            let maxY = startButton.frame.minY - 20
            let width = self.view.bounds.width - 100
            let depth = CGFloat(100)
            
            checkIfBestScore(finalScore!)
            if !broadcast.initialized {
                
                broadcast = Broadcast(frame: CGRect(x: self.view.center.x - width/2, y: depth, width: width, height: maxY - depth))
            }
            
            broadcast.setScoreLabel(finalScore!)
            broadcast.setBestScoreLabel()
            self.view.addSubview(broadcast)
            
        }
        
        //Animate buttons fading and start game
        UIView.animateWithDuration(0.3, animations: {
            
            
            if finalScore != nil {
                
                self.broadcast.alpha = 1
            }
            else {
                
                self.titleLabel.alpha = 1
            }
            
            self.startButton.alpha = 1
            
            self.score.alpha = 0
            self.plane.alpha = 0
            
            for subview in self.view.subviews {
                
                if subview is Cloud {
                    
                    subview.removeFromSuperview()
                }
            }
            
        }) { (Bool) in
            
            self.startButton.userInteractionEnabled = true
            self.score.resetLabels()
            self.flyGesture.enabled = true
            
            self.dynamicAnimator.removeAllBehaviors()
            self.plane.center = self.view.center
            
            self.initializeDynamicAnimator()
        }
    }
    
    
    
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        
        
        //Disable button
        startButton.userInteractionEnabled = false
        hideStatusBar = true
        plane.hidden = false
        
        //Animate button fade and start game
        UIView.animateWithDuration(0.3, animations: { 
            
            self.titleLabel.alpha = 0
            self.startButton.alpha = 0
            self.broadcast.alpha = 0
            
            
            self.score.alpha = 1
            self.plane.alpha = 1
            
            }) { (Bool) in
                
                self.titleLabel.hidden = true
                self.startButton.hidden = true
                self.broadcast.removeFromSuperview()
                self.fly()
                
        }
    }
    
    
    internal func fly() {
        
        
        //Animate clouds with timer
        cloudTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1/speed), target: self, selector: #selector(sendCloud), userInfo: nil, repeats: true)
        cloudTimer.fire()
        
    }
    
    
    internal func sendCloud() {
        
        
        //Increase speed every few seconds
        if score.getScore() % 10 == 0 && score.getScore() != 0 {
            
            print("speed up!")
            speedUp()
        }
        
        
        //Create new cloud of varying length
        let width = CGFloat(randomCloudWidth())
        let height = CGFloat(20)
        let horizontalLocation = max(CGFloat(arc4random_uniform(UInt32(self.view.bounds.width - width - 20))), 20)
        let cloud = Cloud(frame: CGRect(x: horizontalLocation, y: -height, width: width, height: height))
        
        self.view.addSubview(cloud)
        
        
        //Add cloud behaviors
        cloudCollision.addItem(cloud)
        rotationRestriction.addItem(cloud)
        cloudResistance.addItem(cloud)
        
        
        //Push cloud
        cloudPush = UIPushBehavior(items: [cloud], mode: UIPushBehaviorMode.Instantaneous)
        cloudPush.pushDirection = CGVector(dx: 0, dy: 1)
        cloudPush.magnitude = speed * cloud.bounds.width * 0.005
        dynamicAnimator.addBehavior(cloudPush)
        
        
        //Add action to delete cloud once it's past screen
        let cloudRemove = UIDynamicItemBehavior(items: [cloud])
        cloudRemove.action = { (Bool) in
            
            if cloud.frame.minY > self.view.bounds.height {
                
                print("deleting cloud!")
                self.cloudCollision.removeItem(cloud)
                self.rotationRestriction.removeItem(cloud)
                self.cloudResistance.removeItem(cloud)
                self.dynamicAnimator.removeBehavior(cloudRemove)
                self.dynamicAnimator.removeBehavior(self.cloudPush)
                cloud.removeFromSuperview()
            }
        }
        
        dynamicAnimator.addBehavior(cloudRemove)
        
        //Increment score
        self.score.increment()
        
    }

    
    internal func randomCloudWidth() -> CGFloat {
        
        
        //Return random number divisible by current arc length to use while generating cloud
        let divisor = CGFloat(25)
        let upperLimit = UInt32((self.view.bounds.width - plane.bounds.width)/divisor) - 1
        let randomNumber = max(arc4random_uniform(upperLimit) * UInt32(divisor), UInt32(divisor) * 3)
        
        return CGFloat(randomNumber)
    }
    
    
    internal func speedUp() {
        
        //Stop clouds
        cloudTimer.invalidate()
        
        // Delay execution of my block for 10 seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
            
            if self.plane.alpha == 1 {
                
                self.speed += 0.3
                self.fly()
            }
        }
        
    }
    
    
    @IBAction func planeFlown(sender: UIPanGestureRecognizer) {
        
        
        if plane.alpha == 1 {
           
            switch sender.state {
            
            case .Began:
                
                //Create a blank view and attach the plane to it
                //Place blank view at user's touch
                touchStartingPoint = sender.translationInView(self.view)
                planeStartingPoint = plane.center
                
                //Create to attach plane
                planeSnap = UISnapBehavior(item: plane, snapToPoint: planeStartingPoint)
                dynamicAnimator.addBehavior(planeSnap)
                
                
            case .Changed:
                
                
                //Set translation difference and sensitivity
                let sensitivity = CGFloat(3)
                let translation = sender.translationInView(self.view)
                let horizontalDifference = (touchStartingPoint.x - translation.x) * sensitivity
                let verticalDifference = (touchStartingPoint.y - translation.y) * sensitivity
                
                //Set movement according to difference accounting for view bounds as limitations
                let horizontalMovement = min(max(planeStartingPoint.x + horizontalDifference,  plane.bounds.width/2), self.view.bounds.width - plane.bounds.width/2)
                let verticalMovement = min(max(planeStartingPoint.y + verticalDifference, plane.bounds.height/2), self.view.bounds.height - plane.bounds.height/2)
                1
                
                //Change snap point to movement variables
                planeSnap.snapPoint = CGPoint(x: horizontalMovement, y: verticalMovement)
                
                
            case .Cancelled, .Ended:
                
                
                //Remove behavior
                dynamicAnimator.removeBehavior(planeSnap)
                
                //Cancel movement of plane
                let velocity = sender.velocityInView(self.view)
                
                let stopPlane = UIDynamicItemBehavior(items: [plane])
                stopPlane.addLinearVelocity(CGPoint(x: -velocity.x, y: -velocity.y), forItem: plane)
                dynamicAnimator.addBehavior(stopPlane)
                
                
            default: ()
                
            }
        }
    }
    
    
    internal func checkIfBestScore(finalScore: Int) {
        
        
        let best = userDefaults.integerForKey("bestScore")
        if best < finalScore {
            
            userDefaults.setInteger(finalScore, forKey: "bestScore")
        }
    }
    
    
    
    
    internal func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        
        print("Collision!")
        self.resetView(score.getScore())
    }
    
    
    internal func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem) {
        
        print("Collision!")
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

