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
    @IBOutlet var pauseView: UIView!
    @IBOutlet var resumeButton: UIButton!
    @IBOutlet var pauseButton: PauseButton!
    @IBOutlet var adButton: UIButton!
    @IBOutlet var banner: GADBannerView!
    
    var cloudTimer: Timer?
    var flake: Flake!
    var flakeStartingPoint = CGPoint()
    var touchStartingPoint = CGPoint()
    var hideStatusBar = false
    var startButtonInitialized = false
    var resumeButtonInitialized = false
    let userDefaults = UserDefaults.standard
    var scoreTable = ScoreTable()
    let themeColor = UIColor.lightGray //UIColor(red: 211.0/225.0, green: 84.0/225.0, blue: 63.0/225.0, alpha: 1)
    
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    var username = "VIK"
    var paused = false
    
    var speed = CGFloat(1)
    var dynamicAnimator: UIDynamicAnimator!
    var cloudCollision: UICollisionBehavior!
    var boundaryCollision: UICollisionBehavior!
    var cloudResistance: UIDynamicItemBehavior!
    var flakeBehaviors: UIDynamicItemBehavior!
    var flakeAttachment: UIAttachmentBehavior!
    var rotationRestriction: UIDynamicItemBehavior!
    var flakeSnap: UISnapBehavior!
    var cloudPush: UIPushBehavior!
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        //Initialize stuff
        initializeParameters()
        initializeViewsAfterLoad()
        configureDatabase()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.pauseGame), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        super.viewWillAppear(animated)
        
        //Initialize views before view will appear
        initializeViewsBeforeAppear()
        
        if paused {
            
            UIView.animate(withDuration: 0.5, animations: { 
                
                self.pauseView.alpha = 1
                
                }, completion: { (Bool) in
                    
                    self.pauseView.isUserInteractionEnabled = true
            })
        }
        
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
        
        
        print("initializeParameters")
        if userDefaults.object(forKey: Constants.username) != nil {
            
            username = userDefaults.object(forKey: Constants.username) as! String
        }
    }
    
    
    internal func initializeViewsAfterLoad() {
        
        
        //Initialize flake
        print("initializeViewsAfterLoad")
        let flakeHeight = CGFloat(20)
        let flakeWidth = CGFloat(20)
        flake = Flake(frame: CGRect(x: 0, y: 0, width: flakeWidth, height: flakeHeight))
        self.view.addSubview(flake)
        
        flake.center = CGPoint(x: self.view.center.x, y: self.view.bounds.height/3)
        flake.alpha = 0
        flake.startAnimating()
        
        initializeDynamicAnimator()
    }
    
    
    internal func initializeViewsBeforeAppear() {
        
        
        //Initialize buttons
        print("initializeViewsBeforeAppear")
        if !startButtonInitialized {
            
            startButtonInitialized = true
            
            //Cut start button corners
            startButton.layer.cornerRadius = 45.0/2.0
            startButton.clipsToBounds = true
        }
        
        if !resumeButtonInitialized {
            
            resumeButtonInitialized = true
            
            //Cut start button corners
            resumeButton.layer.cornerRadius = 45.0/2.0
            resumeButton.clipsToBounds = true
        }
    }
    
    
    internal func initializeViewsAfterAppear() {
        
        
        print("initializeViewsAfterAppear")
        //Initialize broadcast view
        if !broadcast.initialized {
            broadcast.initializeViews()
        }
        
        //Initialize score view
        if !score.initialized {
            score.initializeViews()
        }
        
        pauseButton.initializeViews()
        
        //Initialize ad button
        if !adButton.clipsToBounds {
            
            adButton.layer.cornerRadius = adButton.bounds.height/2
            adButton.clipsToBounds = true
        }
    }
    
    
    internal func initializeDynamicAnimator() {
        
        
        print("initializeDynamicAnimator")
        //Initialize animator, add cloud and flake behaviors
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        
        cloudCollision = UICollisionBehavior(items: [flake])
        cloudCollision.collisionMode = UICollisionBehaviorMode.items
        cloudCollision.collisionDelegate = self
        dynamicAnimator.addBehavior(cloudCollision)
        
        boundaryCollision = UICollisionBehavior(items: [flake.flakeView])
        boundaryCollision.collisionMode = UICollisionBehaviorMode.boundaries
        boundaryCollision.translatesReferenceBoundsIntoBoundary = true
        dynamicAnimator.addBehavior(self.boundaryCollision)
        
        flakeBehaviors = UIDynamicItemBehavior(items: [flake, flake.flakeView])
        flakeBehaviors.elasticity = 1.0
        flakeBehaviors.resistance = 10
        dynamicAnimator.addBehavior(self.flakeBehaviors)
        
        flakeAttachment = UIAttachmentBehavior(item: flake.flakeView, attachedTo: flake)
        flakeAttachment.anchorPoint = flake.center
        flakeAttachment.length = 0
        flakeAttachment.damping = 0
        flakeAttachment.frequency = 30
        dynamicAnimator.addBehavior(flakeAttachment)
        
        rotationRestriction = UIDynamicItemBehavior(items: [flake])
        rotationRestriction.allowsRotation = false
        dynamicAnimator.addBehavior(rotationRestriction)
        
        
        cloudResistance = UIDynamicItemBehavior(items: [])
        cloudResistance.resistance = 0
        
        dynamicAnimator.delegate = self
        dynamicAnimator.addBehavior(cloudResistance)
        
    }
    
    
    
    internal func resetView(finalScore: Int?) {
        
        
        print("resetView")
        //Reset view to start screen, show score broadcast if necessary
        flyGesture.isEnabled = false
        titleLabel.isHidden = false
        startButton.isHidden = false
        broadcast.isUserInteractionEnabled = false
        pauseButton.hide()
        
        flake.isHidden = true
        hideStatusBar = false
        speed = CGFloat(1)
        
        invalidateTimer()
        
        if finalScore != nil {
            
            //Check if current score is the best, set labels on broadcast view & pass score to table
            let _ = checkIfBestScore(finalScore!)
            broadcast.setScoreLabel(finalScore!)
            broadcast.setBestScoreLabel()
            scoreTable.updateCurrentScore(score: finalScore!)
            
            //Change start button text
            startButton.setTitle("AGAIN!", for: .normal)
        
            //Send current score to database and request more scores
            sendScore()
            requestScores()
        }
        
        //Animate buttons fading and start game
        UIView.animate(withDuration: 1, animations: {
            
            
            if finalScore != nil {
                
                self.broadcast.alpha = 1
                self.broadcast.isUserInteractionEnabled = true
            }
            else {
                
                self.titleLabel.alpha = 1
            }
            self.startButton.alpha = 1
            
            self.score.alpha = 0
            self.flake.alpha = 0
            
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
            self.flake.center = CGPoint(x: self.view.center.x, y: self.view.bounds.height/3)
            
            //Initialize banner
            self.banner.rootViewController = self
            let request = GADRequest()
            request.testDevices = ["692e86106fd4b538b1824b62d6138614"]
            self.banner.load(request)
            
            self.initializeDynamicAnimator()
        }) 
    }
    
    
    @IBAction func pauseButtonPressed(_ sender: AnyObject) {
        
        print("pauseButtonPressed")
        pauseGame()
        pauseButton.hide()
    }
    
    
    internal func pauseGame() {
        
        
        //Pause game and show the pause view
        print("pauseGame")
        if flake.alpha == 1 {
            
            paused = true
            invalidateTimer()
            dynamicAnimator.removeAllBehaviors()
            self.view.bringSubview(toFront: pauseView)
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.pauseView.alpha = 1
                
            }) { (Bool) in
                
                self.pauseView.isUserInteractionEnabled = true
            }
        }
    }
    
    
    @IBAction func resumeButtonPressed(_ sender: AnyObject) {
        
        
        print("resumeButtonPressed")
        //Resume game and graphics
        paused = false
        pauseView.isUserInteractionEnabled = false
        pauseButton.show()
        initializeDynamicAnimator()
        
        UIView.animate(withDuration: 0.5, animations: { 
            
            //Hide pause view
            self.pauseView.alpha = 0
            
            }) { (Bool) in
                
                var verticalPosition = CGFloat(-5000000)
                var width = CGFloat(-5000000)
                
                //Add cloud behavior to all existing clouds
                for view in self.view.subviews {
                    
                    if view is Cloud {
                        
                        //If top-most cloud, record distance it has traveled
                        if view.center.y > verticalPosition {
                            
                            verticalPosition = view.center.y
                            width = view.bounds.width
                        }
                        
                        //Add behaviors and push
                        self.addCloudBehaviors(cloud: view as! Cloud)
                        self.pushCloud(cloud: view as! Cloud)
                    }
                }
                
                
                //Calculate time at which to resume game
                //If distance and width have been retreived from a view,
                //get time from the physics equation v = d/t
                var time = CGFloat(0)
                
                if verticalPosition != -5000000 && width != -5000000 && self.score.getScore() % 10 != 0 {
                    
                    let velocity = self.cloudSpeed(width: width) * 500
                    let distance = self.view.bounds.height - verticalPosition + 30
                    time = distance/velocity
                }
                else if self.score.getScore() % 10 != 0 {
                    
                    //If the app is transitioning, give it two extra seconds
                    time = -2
                }
                
                
                //Resume game
                let timeInterval = TimeInterval(max(0, 1.0/self.speed - time))
                DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: {
                    
                    self.fall()
                })
        }
    }
    
    
    @IBAction func startButtonPressed(_ sender: AnyObject) {
        
        
        print("startButtonPressed")
        //Disable button and broadcast
        startButton.isUserInteractionEnabled = false
        broadcast.isUserInteractionEnabled = false
        hideStatusBar = true
        flake.isHidden = false
        pauseButton.show()
        
        //Animate button fade and start game
        UIView.animate(withDuration: 0.3, animations: { 
            
            self.titleLabel.alpha = 0
            self.startButton.alpha = 0
            self.broadcast.alpha = 0
            
            self.score.alpha = 1
            self.flake.alpha = 1
            
            
            }, completion: { (Bool) in
                
                self.titleLabel.isHidden = true
                self.startButton.isHidden = true
                self.fall()
                
        }) 
    }
    
    
    internal func invalidateTimer() {
        
        if cloudTimer != nil {
            cloudTimer?.invalidate()
        }
        cloudTimer = nil
    }
    
    
    
    internal func fall() {
        
        
        print("fall")
        //Animate clouds with timer
        invalidateTimer()
        cloudTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1/speed), target: self, selector: #selector(sendCloud), userInfo: nil, repeats: true)
        cloudTimer!.fire()
    }
    
    
    internal func sendCloud() {
        
        
        print("sendCloud")
        if flake.alpha == 1 && !paused {
            
            //Increase speed every few seconds
            if (score.getScore() + 1) % 10 == 0 && score.getScore() != 0 {
                
                print("speed up!")
                speedUp()
            }
            
            //Else, create new cloud of varying length
            let width = CGFloat(randomCloudWidth())
            let height = CGFloat(20)
            let horizontalLocation = max(CGFloat(arc4random_uniform(UInt32(self.view.bounds.width - width - 20))), 20)
            let cloud = Cloud(frame: CGRect(x: horizontalLocation, y: self.view.bounds.height + height, width: width, height: height))
            self.view.insertSubview(cloud, belowSubview: score)
            
            //Add cloud behaviors and push cloud
            addCloudBehaviors(cloud: cloud)
            pushCloud(cloud: cloud)
            
            
            //Increment score
            self.score.increment()
        }
        else {
            
            //Stop timer
            invalidateTimer()
        }
    }
    
    
    internal func addCloudBehaviors(cloud: Cloud) {
        
        
        //Add clouds to the following behaviors
        cloudCollision.addItem(cloud)
        rotationRestriction.addItem(cloud)
        cloudResistance.addItem(cloud)
        
        //Add action to delete cloud once it's past screen
        let cloudRemove = UIDynamicItemBehavior(items: [cloud])
        cloudRemove.action = { (Bool) in
            
            if cloud.frame.maxY < 0 {
                
                self.cloudCollision.removeItem(cloud)
                self.rotationRestriction.removeItem(cloud)
                self.cloudResistance.removeItem(cloud)
                self.dynamicAnimator.removeBehavior(cloudRemove)
                self.dynamicAnimator.removeBehavior(self.cloudPush)
                cloud.removeFromSuperview()
            }
        }
        
        dynamicAnimator.addBehavior(cloudRemove)
    }
    
    
    internal func pushCloud(cloud: Cloud) {
        
        //Add push behavior to cloud
        cloudPush = UIPushBehavior(items: [cloud], mode: UIPushBehaviorMode.instantaneous)
        cloudPush.pushDirection = CGVector(dx: 0, dy: -1)
        cloudPush.magnitude = cloudSpeed(width: cloud.bounds.width)
        dynamicAnimator.addBehavior(cloudPush)
    }
    
    
    internal func cloudSpeed(width: CGFloat) -> CGFloat {
        
        return speed * width * 0.005
    }
    
    
    internal func randomCloudWidth() -> CGFloat {
        
        
        //Return random number divisible by current arc length to use while generating cloud
        let divisor = CGFloat(25)
        let upperLimit = UInt32((self.view.bounds.width - flake.flakeView.bounds.width)/divisor) - 1
        let randomNumber = max(arc4random_uniform(upperLimit) * UInt32(divisor), UInt32(divisor) * 3)
        
        return CGFloat(randomNumber)
    }
    
    
    internal func speedUp() {
        
        
        print("speedUp")
        //Stop clouds
        invalidateTimer()
        
        // Delay execution of my block for 10 seconds.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(2 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            
            if self.flake.alpha == 1 {
                
                self.speed += 0.15
                self.fall()
            }
        }
        
    }
    
    
    @IBAction func flakeFlown(_ sender: UIPanGestureRecognizer) {
        
        
        if flake.alpha == 1 && !paused {
           
            switch sender.state {
            
            case .began:
                
                //Create a blank view and attach the flake to it
                //Place blank view at user's touch
                print("began")
                touchStartingPoint = sender.translation(in: self.view)
                flakeStartingPoint = flake.center
                
                //Create to attach flake
                flakeSnap = UISnapBehavior(item: flake, snapTo: flakeStartingPoint)
                dynamicAnimator.addBehavior(flakeSnap)
                
                
            case .changed:
                
                
                print("changed")
                //Set translation difference and sensitivity
                let sensitivity = CGFloat(7)
                let translation = sender.translation(in: self.view)
                let horizontalDifference = (touchStartingPoint.x - translation.x) * sensitivity
                let verticalDifference = CGFloat(0)//(touchStartingPoint.y - translation.y) * sensitivity
                
                //Set movement according to difference accounting for view bounds as limitations
                let horizontalMovement = min(max(flakeStartingPoint.x + horizontalDifference,  flake.bounds.width/2), self.view.bounds.width - flake.bounds.width/2)
                let verticalMovement = min(max(flakeStartingPoint.y + verticalDifference, flake.bounds.height/2), self.view.bounds.height - flake.bounds.height/2)
                
                
                //Change snap point to movement variables
                flakeSnap.snapPoint = CGPoint(x: horizontalMovement, y: verticalMovement)
                
                
            case .cancelled, .ended:
                
                
                print("ended")
                //Remove behavior
                dynamicAnimator.removeBehavior(flakeSnap)
                
                //Cancel movement of flake
                let velocity = sender.velocity(in: self.view)
                
                let stopflake = UIDynamicItemBehavior(items: [flake])
                stopflake.addLinearVelocity(CGPoint(x: -velocity.x, y: -velocity.y), for: flake)
                dynamicAnimator.addBehavior(stopflake)
                
                
            default: ()
                
            }
        }
    }
    
    
    
    internal func checkIfBestScore(_ finalScore: Int) -> Bool {
        
        
        print("checkIfBestScore")
        let best = userDefaults.integer(forKey: "bestScore")
        if best < finalScore {
            
            userDefaults.set(finalScore, forKey: "bestScore")
            return true
        }
        
        return false
    }
    
    
    internal func configureDatabase() {
        
        print("configureDatabase")
        ref = FIRDatabase.database().reference()
    }
    
    
    internal func requestScores() {
        
        //Hide score table and show refreshing logo
        broadcast.hideScoreBoard()
        
        //Query database for results
        let scoresList = ref.child(Constants.baseChild)
        scoresList.queryOrderedByPriority().queryLimited(toLast: 5).observe(.value, with: { (snapshot) in
            
            let connection = snapshot.value
            if connection != nil {
                
                //Get top 5 score list
                let scoreList = self.convertSnapshotToDictionary(snapshot: snapshot)
                let scoreInTopFive = self.checkIfScoreInTopFive(scoreList: scoreList)
                
                
                if scoreInTopFive {
                    
                    //If score is in top 5, show results in order
                    self.scoreTable.resetRank()
                    self.scoreTable.scores = scoreList
                    self.scoreTable.refresh()
                    self.broadcast.showScoreboard()
                }
                else {
                    
                    //If score is not in top 5, query the rank of the score and pass it to the table, where it will be handled
                    let rankList = self.ref.child(Constants.baseChild)
                    rankList.queryOrderedByPriority().queryStarting(atValue: self.broadcast.getScore(), childKey: Constants.score).observeSingleEvent(of: .value, with: { (rankSnapshot) in
                        
                        if rankSnapshot.value != nil {
                            
                            self.scoreTable.updateCurrentRank(rank: Int(rankSnapshot.childrenCount) + 1)
                            self.scoreTable.scores = scoreList
                            self.scoreTable.refresh()
                            self.broadcast.showScoreboard()
                        }
                        else {
                            
                            self.showDefaultScoreBoard()
                        }
                        
                        }, withCancel: { (error) in
                            
                            self.showDefaultScoreBoard()
                    })
                }
            }
            else {
                
                self.showDefaultScoreBoard()
            }
            
            }) { (error) in
                
                self.showDefaultScoreBoard()
        }
    }
    
    
    internal func showDefaultScoreBoard() {
        
        
        //Show default scoreboard
        self.scoreTable.resetRank()
        self.scoreTable.resetArray()
        self.scoreTable.refresh()
        self.broadcast.showScoreboard()
    }
    
    
    internal func convertSnapshotToDictionary(snapshot: FIRDataSnapshot) -> Array<NSDictionary> {
        
        var scoreList = Array<NSDictionary>()
        for child in snapshot.children {
            
            scoreList.append((child as! FIRDataSnapshot).value as! NSDictionary)
        }
        
        return scoreList
    }
    
    
    internal func checkIfScoreInTopFive(scoreList: Array<NSDictionary>) -> Bool {
        
        
        for element in scoreList {
            
            if element[Constants.username] as! String == username && element[Constants.score] as! Int == broadcast.getScore() {
                
                return true
            }
        }
        
        return false
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
    
    
    
    
    @IBAction func adButtonPressed(_ sender: AnyObject) {
    }
    
    
    internal func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        
        print("Collision!")
        if flake.alpha == 1  {
            
            flake.alpha = 0
            invalidateTimer()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                
                self.resetView(finalScore: self.score.getScore())
            })
        }
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

