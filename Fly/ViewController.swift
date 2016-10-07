//
//  ViewController.swift
//  Fly
//
//  Created by Vikram Ramkumar on 8/4/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate {
    
    
    @IBOutlet var startButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var score: Score!
    @IBOutlet var flyGesture: UIPanGestureRecognizer!
    @IBOutlet var broadcast: Broadcast!
    
    var cloudTimer: Timer?
    var plane: Plane!
    var planeStartingPoint = CGPoint()
    var touchStartingPoint = CGPoint()
    var hideStatusBar = false
    var startButtonInitialized = false
    let userDefaults = UserDefaults.standard
    var scoreTable = ScoreTable()
    
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    var username = "VIK"
    
    var speed = CGFloat(1)
    var dynamicAnimator: UIDynamicAnimator!
    var cloudCollision: UICollisionBehavior!
    var boundaryCollision: UICollisionBehavior!
    var planeResistance: UIDynamicItemBehavior!
    var cloudResistance: UIDynamicItemBehavior!
    var planeBehaviors: UIDynamicItemBehavior!
    var rotationRestriction: UIDynamicItemBehavior!
    var planeSnap: UISnapBehavior!
    var cloudPush: UIPushBehavior!
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        //Initialize stuff
        initializeParameters()
        initializeViewsAfterLoad()
        configureDatabase()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.pauseView), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        super.viewWillAppear(animated)
        
        //Initialize views before view will appear
        initializeViewsBeforeAppear()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        super.viewDidAppear(animated)
        
        
        initializeViewsAfterAppear()
        
        for child in self.childViewControllers {
            
            if child is ScoreTable {
                
                scoreTable = child as! ScoreTable
            }
        }
    }
    
    
    internal func initializeParameters() {
        
        
        if userDefaults.object(forKey: "username") != nil {
            
            username = userDefaults.object(forKey: "username") as! String
        }
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
    }
    
    
    internal func initializeViewsBeforeAppear() {
        
        
        if !startButtonInitialized {
            
            startButtonInitialized = true
            
            //Cut start button corners
            startButton.layer.cornerRadius = 45.0/2.0
            startButton.clipsToBounds = true
        }
    }
    
    
    internal func initializeViewsAfterAppear() {
        
        
        //Initialize broadcast view
        if !broadcast.initialized {
            broadcast.initializeViews()
        }
        
        //Initialize score view
        if !score.initialized {
            score.initializeViews()
        }
    }
    
    
    internal func initializeDynamicAnimator() {
        
        
        //Initialize animator and add plane behaviors
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        
        cloudCollision = UICollisionBehavior(items: [plane])
        cloudCollision.collisionMode = UICollisionBehaviorMode.items
        cloudCollision.collisionDelegate = self
        dynamicAnimator.addBehavior(cloudCollision)
        
        boundaryCollision = UICollisionBehavior(items: [plane])
        boundaryCollision.collisionMode = UICollisionBehaviorMode.boundaries
        boundaryCollision.translatesReferenceBoundsIntoBoundary = true
        dynamicAnimator.addBehavior(self.boundaryCollision)
        
        planeBehaviors = UIDynamicItemBehavior(items: [plane])
        planeBehaviors.elasticity = 1.0
        planeBehaviors.resistance = 30
        dynamicAnimator.addBehavior(self.planeBehaviors)
        
        
        rotationRestriction = UIDynamicItemBehavior(items: [plane])
        rotationRestriction.allowsRotation = false
        dynamicAnimator.addBehavior(rotationRestriction)
        
        
        cloudResistance = UIDynamicItemBehavior(items: [])
        cloudResistance.resistance = 0
        
        dynamicAnimator.delegate = self
        dynamicAnimator.addBehavior(cloudResistance)
        
    }
    
    
    
    internal func resetView(finalScore: Int?) {
        
        
        //Reset view to start screen, show score broadcast if necessary
        flyGesture.isEnabled = false
        titleLabel.isHidden = false
        startButton.isHidden = false
        
        plane.isHidden = true
        hideStatusBar = false
        speed = CGFloat(1)
        
        if cloudTimer != nil {
            
            cloudTimer!.invalidate()
            cloudTimer = nil
        }
        
        if finalScore != nil {
            
            //Check if current score is the best & set labels on broadcast view
            let _ = checkIfBestScore(finalScore!)
            
            broadcast.setScoreLabel(finalScore!)
            broadcast.setBestScoreLabel()
        
            //Send current score to database and request more scores
            sendScore()
            requestScores()
        }
        
        //Animate buttons fading and start game
        UIView.animate(withDuration: 0.3, animations: {
            
            
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
            
        }, completion: { (Bool) in
            
            //Start game
            self.startButton.isUserInteractionEnabled = true
            self.score.resetLabels()
            self.flyGesture.isEnabled = true
            
            self.dynamicAnimator.removeAllBehaviors()
            self.plane.center = self.view.center
            
            self.initializeDynamicAnimator()
        }) 
    }
    
    
    internal func pauseView() {
        
        
        print("pauseView")
        cloudTimer?.invalidate()
        cloudTimer = nil
    }
    
    
    
    @IBAction func startButtonPressed(_ sender: AnyObject) {
        
        
        //Disable button
        startButton.isUserInteractionEnabled = false
        hideStatusBar = true
        plane.isHidden = false
        
        //Animate button fade and start game
        UIView.animate(withDuration: 0.3, animations: { 
            
            self.titleLabel.alpha = 0
            self.startButton.alpha = 0
            self.broadcast.alpha = 0
            
            
            self.score.alpha = 1
            self.plane.alpha = 1
            
            
            }, completion: { (Bool) in
                
                self.titleLabel.isHidden = true
                self.startButton.isHidden = true
                self.fly()
                
        }) 
    }
    
    
    internal func fly() {
        
        //Animate clouds with timer
        cloudTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1/speed), target: self, selector: #selector(sendCloud), userInfo: nil, repeats: true)
        cloudTimer!.fire()
    }
    
    
    internal func sendCloud() {
        
        
        if plane.alpha == 1 {
            
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
            pushCloud(cloud: cloud)
            
            
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
    }

    
    internal func pushCloud(cloud: UIView) {
        
        
        cloudPush = UIPushBehavior(items: [cloud], mode: UIPushBehaviorMode.instantaneous)
        cloudPush.pushDirection = CGVector(dx: 0, dy: 1)
        cloudPush.magnitude = speed * cloud.bounds.width * 0.005
        dynamicAnimator.addBehavior(cloudPush)
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
        if cloudTimer != nil {
            
            cloudTimer!.invalidate()
            cloudTimer = nil
        }
        
        // Delay execution of my block for 10 seconds.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(2 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            
            if self.plane.alpha == 1 {
                
                self.speed += 0.3
                self.fly()
            }
        }
        
    }
    
    
    @IBAction func planeFlown(_ sender: UIPanGestureRecognizer) {
        
        
        if plane.alpha == 1 {
           
            switch sender.state {
            
            case .began:
                
                //Create a blank view and attach the plane to it
                //Place blank view at user's touch
                touchStartingPoint = sender.translation(in: self.view)
                planeStartingPoint = plane.center
                
                //Create to attach plane
                planeSnap = UISnapBehavior(item: plane, snapTo: planeStartingPoint)
                dynamicAnimator.addBehavior(planeSnap)
                
                
            case .changed:
                
                
                //Set translation difference and sensitivity
                let sensitivity = CGFloat(5)
                let translation = sender.translation(in: self.view)
                let horizontalDifference = (touchStartingPoint.x - translation.x) * sensitivity
                let verticalDifference = (touchStartingPoint.y - translation.y) * sensitivity
                
                //Set movement according to difference accounting for view bounds as limitations
                let horizontalMovement = min(max(planeStartingPoint.x + horizontalDifference,  plane.bounds.width/2), self.view.bounds.width - plane.bounds.width/2)
                let verticalMovement = min(max(planeStartingPoint.y + verticalDifference, plane.bounds.height/2), self.view.bounds.height - plane.bounds.height/2)
                
                
                //Change snap point to movement variables
                planeSnap.snapPoint = CGPoint(x: horizontalMovement, y: verticalMovement)
                
                
            case .cancelled, .ended:
                
                
                //Remove behavior
                dynamicAnimator.removeBehavior(planeSnap)
                
                //Cancel movement of plane
                let velocity = sender.velocity(in: self.view)
                
                let stopPlane = UIDynamicItemBehavior(items: [plane])
                stopPlane.addLinearVelocity(CGPoint(x: -velocity.x, y: -velocity.y), for: plane)
                dynamicAnimator.addBehavior(stopPlane)
                
                
            default: ()
                
            }
        }
    }
    
    
    
    internal func checkIfBestScore(_ finalScore: Int) -> Bool {
        
        
        let best = userDefaults.integer(forKey: "bestScore")
        if best < finalScore {
            
            userDefaults.set(finalScore, forKey: "bestScore")
            return true
        }
        
        return false
    }
    
    
    internal func configureDatabase() {
        
        ref = FIRDatabase.database().reference()
    }
    
    
    internal func requestScores() {
        
        //Hide score table and show refreshing logo
        broadcast.hideScoreBoard()
        
        //Query database for results
        let scoresList = ref.child(Constants.baseChild)
        scoresList.queryOrderedByPriority().queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value != nil {
                
                
                let scoreList = self.convertSnapshotToDictionary(snapshot: snapshot)
                
                self.scoreTable.scores = scoreList
                self.scoreTable.refresh()
                self.broadcast.showScoreboard()
            }
        })
    }
    
    
    internal func convertSnapshotToDictionary(snapshot: FIRDataSnapshot) -> Array<NSDictionary> {
    
        
        var scoreList = Array<NSDictionary>()
        for child in snapshot.children {
            
            scoreList.append((child as! FIRDataSnapshot).value as! NSDictionary)
        }
        
        return scoreList
    
    }
    
    internal func sendScore() {
        
        //Send score
        let score = broadcast.getScore()
        var mdata = [String: Any]()
        mdata[Constants.username] = username
        mdata[Constants.score] = score
        
        
        //Push data to Firebase Database
        self.ref.child(Constants.baseChild).child(String(score)).setValue(mdata)
        self.ref.child(Constants.baseChild).child(String(score)).setPriority(score)
    }
    
    
    
    internal func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        
        print("Collision!")
        self.resetView(finalScore: score.getScore())
    }
    
    
    internal func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
        
    }
    
    
    override var prefersStatusBarHidden : Bool {
        
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

