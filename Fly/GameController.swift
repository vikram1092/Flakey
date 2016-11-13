//
//  ViewController.swift
//  Fly
//
//  Created by Vikram Ramkumar on 8/4/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import UIKit
import Firebase

class GameController: UIViewController, UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate, UITextFieldDelegate {
    
    
    @IBOutlet var backdrop: Backdrop!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var titleView: UIImageView!
    @IBOutlet var score: Score!
    @IBOutlet var flyGesture: UIPanGestureRecognizer!
    @IBOutlet var broadcast: Broadcast!
    @IBOutlet var pauseView: UIView!
    @IBOutlet var resumeButton: UIButton!
    @IBOutlet var pauseButton: PauseButton!
    @IBOutlet var adButton: UIButton!
    @IBOutlet var banner: GADBannerView!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var usernameChangeHeader: UILabel!
    @IBOutlet var usernameChangeField: UITextField!
    @IBOutlet var scoreTableTapGesture: UITapGestureRecognizer!
    @IBOutlet var aboutLabel: UITextView!
    @IBOutlet var aboutButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    var cloudTimer: Timer?
    var flake: Flake!
    var flakeStartingPoint = CGPoint()
    var touchStartingPoint = CGPoint()
    var hideStatusBar = false
    var startButtonInitialized = false
    var resumeButtonInitialized = false
    var buttonsExpanded = false
    var constraintsRemoved = false
    var origAboutConstraint: NSLayoutConstraint!
    var origShareConstraint: NSLayoutConstraint!
    let userDefaults = UserDefaults.standard
    var scoreTable = ScoreTable()
    let themeGray = Constants.secondaryColor
    let themeHighlight = Constants.highlightColor
    
    var ref: FIRDatabaseReference!
    private var _refHandle: FIRDatabaseHandle!
    var interstitial: GADInterstitial!
    var username = "FLAKEY"
    var paused = false
    var collided = false
    
    var speed = CGFloat(1)
    var dynamicAnimator: UIDynamicAnimator!
    var cloudCollision: UICollisionBehavior!
    var boundaryCollision: UICollisionBehavior!
    var cloudBehaviors: UIDynamicItemBehavior!
    var flakeBehaviors: UIDynamicItemBehavior!
    var flakeAttachment: UIAttachmentBehavior!
    var rotationRestriction: UIDynamicItemBehavior!
    var flakeSnap: UISnapBehavior!
    var cloudPush: UIPushBehavior!
    
    var flakeMoveTutorial: UIView?
    var avoidCloudTutorial: UIView?
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        //Initialize stuff
        initializeParameters()
        initializeViewsAfterLoad()
        configureDatabase()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.pauseGame), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        //DEMO CODE -- Remove tutorial keys
        self.userDefaults.set(false, forKey: Constants.moveFlakeTutorialKey)
        self.userDefaults.set(false, forKey: Constants.avoidCloudTutorialKey)
        //self.userDefaults.set(false, forKey: Constants.scoreTutorialKey)
        //self.userDefaults.set(false, forKey: Constants.scoreboardTutorialKey)
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
        
        //Initialize backdrop
        backdrop.initializeViews()
        
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
            
            username = NSKeyedUnarchiver.unarchiveObject(with: userDefaults.object(forKey: Constants.username) as! Data) as! String
        }
    }
    
    
    internal func initializeViewsAfterLoad() {
        
        
        //Initialize flake
        print("initializeViewsAfterLoad")
        let flakeHeight = CGFloat(20)
        let flakeWidth = CGFloat(20)
        flake = Flake(frame: CGRect(x: 0, y: 0, width: flakeWidth, height: flakeHeight))
        self.view.addSubview(flake)
        
        flake.alpha = 0
        flake.center = CGPoint(x: self.view.center.x, y: self.view.bounds.height/3)
        
        initializeDynamicAnimator()
    }
    
    
    internal func initializeViewsBeforeAppear() {
        
        
        //Initialize views and buttons
        print("initializeViewsBeforeAppear")
        if !startButton.clipsToBounds {
            //Cut start button corners
            startButton.layer.cornerRadius = 45.0/2.0
            startButton.clipsToBounds = true
        }
        
        if !resumeButton.clipsToBounds {
            
            //Cut start button corners
            resumeButton.layer.cornerRadius = 45.0/2.0
            resumeButton.clipsToBounds = true
        }
        
        if !aboutButton.clipsToBounds {
            
            //Cut about button corners
            aboutButton.layer.cornerRadius = 18
            aboutButton.clipsToBounds = true
        }
        
        if !shareButton.clipsToBounds {
            
            //Cut share button corners
            shareButton.layer.cornerRadius = 18
            shareButton.clipsToBounds = true
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
        
        //Initialize username change view
        if !usernameChangeField.clipsToBounds {
            
            usernameChangeField.layer.cornerRadius = usernameChangeField.bounds.height/2
            usernameChangeField.clipsToBounds = true
            usernameChangeField.layer.borderColor = themeHighlight.cgColor
            usernameChangeField.layer.borderWidth = 2
        }
        
        flake.startAnimating()
        expandButtons()
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
        flakeBehaviors.density = 10
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
        
        
        cloudBehaviors = UIDynamicItemBehavior(items: [])
        cloudBehaviors.resistance = 0
        cloudBehaviors.density = 10000
        
        dynamicAnimator.delegate = self
        dynamicAnimator.addBehavior(cloudBehaviors)
    }
    
    
    
    internal func resetView(finalScore: Int) {
        
        
        print("resetView")
        //Reset view to start screen, show score broadcast if necessary
        flyGesture.isEnabled = false
        titleView.isHidden = false
        broadcast.isUserInteractionEnabled = false
        pauseButton.hide()
        
        flake.isHidden = true
        hideStatusBar = false
        speed = CGFloat(1)
        
        invalidateTimer()
    
        //Check if current score is the best, set labels on broadcast view & pass score to table
        setIfBestScore(finalScore)
        broadcast.setScoreLabel(finalScore)
        broadcast.setBestScoreLabel()
        scoreTable.updateCurrentScore(score: finalScore)
        
        //Change start button text
        startButton.setTitle("AGAIN!", for: .normal)
        
        
        //Load ad for later
        createAndLoadInterstitial()
    
        //Send current score to database and request more scores
        sendScore()
        requestScores(showAdButton: true)
        
        if userDefaults.bool(forKey: Constants.scoreTutorialKey) && userDefaults.bool(forKey: Constants.scoreboardTutorialKey) {
            
            expandButtons()
        }
        
        //Animate buttons fading and start game
        UIView.animate(withDuration: 1, animations: {
            
        
            self.broadcast.alpha = 1
            self.broadcast.isUserInteractionEnabled = true
            
            self.score.alpha = 0
            self.flake.alpha = 0
            
            for subview in self.view.subviews {
                
                if subview is Cloud {
                    
                    subview.removeFromSuperview()
                }
            }
            
        }, completion: { (Bool) in
            
            //Restore user interaction to buttons
            self.flyGesture.isEnabled = true
            
            self.dynamicAnimator.removeAllBehaviors()
            self.flake.center = CGPoint(x: self.view.center.x, y: self.view.bounds.height/3)
            
            //DEMO CODE - REMOVE TEST DEVICES
            //Initialize banner
            self.banner.rootViewController = self
            let request = GADRequest()
            request.testDevices = ["692e86106fd4b538b1824b62d6138614"]
            self.banner.load(request)
            
            self.initializeDynamicAnimator()
        }) 
    }
    
    
    internal func expandButtons() {
        
        
        print("expandButtons")
        //Expand side buttons
        if !buttonsExpanded {
            
            buttonsExpanded = true
            
            //Dispatch after a little bit
            //Use this so that button doesn't freeze during delay
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    //Animate start button first
                    self.startButton.alpha = 1
                    
                    }, completion: { (Bool) in
                        
                        self.aboutButton.alpha = 1
                        self.shareButton.alpha = 1
                        
                        //Store and remove old centering constraints
                        for constraint in self.view.constraints {
                            
                            if constraint.identifier == "horizCenter" {
                                
                                //Store centering constraints as original
                                if constraint.firstItem as! NSObject == self.shareButton || constraint.secondItem as! NSObject == self.shareButton {
                                    
                                    self.origShareConstraint = constraint
                                }
                                else {
                                    
                                    self.origAboutConstraint = constraint
                                }
                                self.view.removeConstraint(constraint)
                            }
                        }
                        
                        //Place new constraints to expand out buttons
                        let constant = CGFloat(-33)
                        let aboutConstraint = NSLayoutConstraint(item: self.startButton, attribute: .trailingMargin, relatedBy: .equal, toItem: self.aboutButton, attribute: .leadingMargin, multiplier: 1, constant: constant)
                        aboutConstraint.identifier = "newConstraint"
                        
                        let shareConstraint = NSLayoutConstraint(item: self.shareButton, attribute: .trailingMargin, relatedBy: .equal, toItem: self.startButton, attribute: .leadingMargin, multiplier: 1, constant: constant)
                        shareConstraint.identifier = "newConstraint"
                        
                        self.view.addConstraint(shareConstraint)
                        self.view.addConstraint(aboutConstraint)
                        
                        
                        //Animate buttons to appear from behind the start button
                        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                            
                            self.view.layoutIfNeeded()
                            
                            }, completion: { (Bool) in
                                
                                //Nothing for now
                                self.startButton.isUserInteractionEnabled = true
                                self.aboutButton.isUserInteractionEnabled = true
                                self.shareButton.isUserInteractionEnabled = true
                        })
                })
            })
        }
    }
    
    
    internal func retractButtons() {
        
        
        print("retractButtons")
        if buttonsExpanded {
            
            //Disable user interactions for all buttons
            buttonsExpanded = false
            startButton.isUserInteractionEnabled = false
            aboutButton.isUserInteractionEnabled = false
            shareButton.isUserInteractionEnabled = false
            
            //Store and remove new constraints
            for constraint in self.view.constraints {
                
                if constraint.identifier == "newConstraint" {
                    
                    self.view.removeConstraint(constraint)
                }
            }
            
            //Place old constraints to retract buttons
            self.view.addConstraint(origAboutConstraint)
            self.view.addConstraint(origShareConstraint)
            
            //Animate buttons to disappear behind the start button
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.curveLinear, animations: {
                
                self.view.layoutIfNeeded()
                
                }, completion: { (Bool) in
                    
                    //Hide buttons to not affect transparency
                    self.aboutButton.alpha = 0
                    self.shareButton.alpha = 0
                    
                    //Animate start button disappearance
                    UIView.animate(withDuration: 0.15, animations: {
                        
                        self.startButton.alpha = 0
                    })
            })
            
        }
    }
    
    
    @IBAction func pauseButtonPressed(_ sender: AnyObject) {
        
        
        print("pauseButtonPressed")
        pauseGame()
        pauseButton.hide()
    }
    
    
    internal func pauseGame() {
        
        
        //Pause game and show the pause view
        print("pauseGame")
        if flake.alpha == 1 && flakeMoveTutorial == nil && avoidCloudTutorial == nil {
            
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
        resumeGame()
    }
    
    
    internal func resumeGame() {
        
        
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
        //Disable and animate all buttons
        retractButtons()
        score.resetLabels()
        broadcast.isUserInteractionEnabled = false
        hideStatusBar = true
        collided = false
        flake.isHidden = false
        pauseButton.show()
        
        //Animate button fade and start game
        UIView.animate(withDuration: 0.3, animations: { 
            
            self.titleView.alpha = 0
            self.broadcast.alpha = 0
            
            self.score.alpha = 1
            self.flake.alpha = 1
            
            
            }, completion: { (Bool) in
                
                self.titleView.isHidden = true
                self.startGame()
                
        }) 
    }
    
    
    internal func invalidateTimer() {
        
        
        //Invalidate and nullify the cloud timer
        if cloudTimer != nil {
            cloudTimer?.invalidate()
        }
        cloudTimer = nil
    }
    
    
    
    internal func startGame() {
        
        
        //If the tutorial hasn't been shown, show tutorial. Else, start the game
        if !userDefaults.bool(forKey: Constants.moveFlakeTutorialKey) {
            showMoveFlakeTutorial()
        }
        else {
            fall()
        }
    }
    
    
    internal func fall() {
        
        
        print("fall")
        //Check if tutorial has been shown
        if userDefaults.bool(forKey: Constants.avoidCloudTutorialKey) {
            
            //Animate clouds with timer
            invalidateTimer()
            cloudTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1/speed), target: self, selector: #selector(sendCloud), userInfo: nil, repeats: true)
            cloudTimer!.fire()
        }
        else {
            
            //Send a cloud and show the tutorial for it
            sendCloud()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.95, execute: {
                
                self.showAvoidCloudTutorial()
            })
        }
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
        cloudBehaviors.addItem(cloud)
        
        //Add action to delete cloud once it's past screen
        let cloudRemove = UIDynamicItemBehavior(items: [cloud])
        cloudRemove.action = { (Bool) in
            
            if cloud.frame.maxY < 0 {
                
                self.cloudCollision.removeItem(cloud)
                self.rotationRestriction.removeItem(cloud)
                self.cloudBehaviors.removeItem(cloud)
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
        
        return speed * width * 60
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
                
                self.speed += 0.2
                self.fall()
            }
        }
        
    }
    
    
    @IBAction func flakeFlown(_ sender: UIPanGestureRecognizer) {
        
        
        if flake.alpha == 1 && !paused && !collided {
           
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
                let sensitivity = CGFloat(0.4)
                let translation = sender.velocity(in: self.view)
                let horizontalDifference = (touchStartingPoint.x - translation.x) * sensitivity
                let verticalDifference = CGFloat(0)
                //Set movement according to difference accounting for view bounds as limitations
                let horizontalMovement = min(max(flake.center.x + horizontalDifference,  flake.bounds.width/2), self.view.bounds.width - flake.bounds.width/2)
                //let horizontalMovement = min(max(flakeStartingPoint.x + horizontalDifference,  flake.bounds.width/2), self.view.bounds.width - flake.bounds.width/2)
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
                
                removeMoveFlakeTutorial()
                
                
            default: ()
                
            }
        }
    }
    
    
    
    internal func showMoveFlakeTutorial() {
        
        
        if !userDefaults.bool(forKey: Constants.moveFlakeTutorialKey) {
            
            //Show move flake tutorial
            let tutorialWidth = self.view.bounds.width - 150
            let tutorialHeight = CGFloat(300)
            let tutorialDepth = self.view.bounds.height * 2/3
            flakeMoveTutorial = UIView(frame: CGRect(x: self.view.center.x - tutorialWidth/2, y: tutorialDepth, width: tutorialWidth, height: tutorialHeight))
            flakeMoveTutorial!.alpha = 0
            flakeMoveTutorial!.isUserInteractionEnabled = false
            
            let border = Border(frame: CGRect(x: 0, y: 0, width: flakeMoveTutorial!.bounds.width, height: 10))
            
            //Create label to show instructions
            let label = UILabel(frame: CGRect(x: 0, y: 10, width: tutorialWidth, height: 70))
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
            label.numberOfLines = 0
            label.textColor = themeGray
            label.text = Constants.moveFlakeTutorialText1
            
            //Add and animate
            flakeMoveTutorial!.addSubview(border)
            flakeMoveTutorial!.addSubview(label)
            self.view.insertSubview(flakeMoveTutorial!, aboveSubview: backdrop)
            
            
            //Hide pause button, show tutorial, temporarily freeze screen
            pauseButton.hide()
            self.view.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.3) {
                
                self.flakeMoveTutorial!.alpha = 1
            }
            
            //Wait a little, show instruction, and give user control
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4, execute: {
                
                label.text = Constants.moveFlakeTutorialText2
                self.view.isUserInteractionEnabled = true
            })
        }
    }
    
    
    internal func removeMoveFlakeTutorial() {
        
        
        //Remove move flake tutorial and start game
        if flakeMoveTutorial != nil {
            if flakeMoveTutorial?.alpha == 1 {
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.flakeMoveTutorial!.alpha = 0
                    }, completion: { (Bool) in
                        
                        self.flakeMoveTutorial!.removeFromSuperview()
                        self.flakeMoveTutorial = nil
                        self.userDefaults.set(true, forKey: Constants.moveFlakeTutorialKey)
                        self.fall()
                        self.pauseButton.show()
                })
            }
        }
    }
    
    
    internal func showAvoidCloudTutorial() {
        
        
        if !userDefaults.bool(forKey: Constants.avoidCloudTutorialKey) {
            
            //Pause game first
            pauseButton.hide()
            paused = true
            invalidateTimer()
            dynamicAnimator.removeAllBehaviors()
            
            //Show move flake tutorial
            let tutorialWidth = self.view.bounds.width - 150
            let tutorialHeight = CGFloat(300)
            let tutorialDepth = self.view.bounds.height * 2/3
            avoidCloudTutorial = UIView(frame: CGRect(x: self.view.center.x - tutorialWidth/2, y: tutorialDepth, width: tutorialWidth, height: tutorialHeight))
            avoidCloudTutorial!.alpha = 0
            
            let border = Border(frame: CGRect(x: 0, y: 0, width: avoidCloudTutorial!.bounds.width, height: 10))
            
            //Create label to show instructions
            let label = UILabel(frame: CGRect(x: 0, y: 10, width: tutorialWidth, height: 70))
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
            label.numberOfLines = 0
            label.textColor = themeGray
            label.text = Constants.avoidCloudTutorialText
            
            //Create button to dismiss
            let button = UIButton(type: .system)
            button.frame = CGRect(x: avoidCloudTutorial!.bounds.width/2 - 50, y: label.frame.maxY, width: 100, height: 45)
            button.setTitle("OK", for: .normal)
            button.titleLabel!.font = startButton.titleLabel!.font
            button.setTitleColor(UIColor.white, for: .normal)
            button.backgroundColor = themeGray
            button.addTarget(self, action: #selector(removeAvoidCloudTutorial), for: .touchUpInside)
            button.layer.cornerRadius = button.bounds.height/2
            button.clipsToBounds = true
            
            //Add and animate
            avoidCloudTutorial!.addSubview(border)
            avoidCloudTutorial!.addSubview(label)
            avoidCloudTutorial!.addSubview(button)
            self.view.insertSubview(avoidCloudTutorial!, aboveSubview: backdrop)
            
            UIView.animate(withDuration: 0.3) {
                
                self.avoidCloudTutorial!.alpha = 1
            }
        }
    }
    
    
    internal func removeAvoidCloudTutorial() {
        
        
        //Remove move flake tutorial and start game
        if avoidCloudTutorial != nil {
            if avoidCloudTutorial?.alpha == 1 {
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.avoidCloudTutorial!.alpha = 0
                    }, completion: { (Bool) in
                        
                        self.avoidCloudTutorial!.removeFromSuperview()
                        self.avoidCloudTutorial = nil
                        self.userDefaults.set(true, forKey: Constants.avoidCloudTutorialKey)
                        self.resumeGame()
                })
            }
        }
    }
    
    
    
    internal func setIfBestScore(_ finalScore: Int) {
        
        
        print("checkIfBestScore")
        let best = userDefaults.integer(forKey: Constants.bestScore)
        if best < finalScore {
            
            userDefaults.set(finalScore, forKey: Constants.bestScore)
        }
    }
    
    
    internal func configureDatabase() {
        
        
        print("configureDatabase")
        ref = FIRDatabase.database().reference()
    }
    
    
    internal func requestScores(showAdButton: Bool) {
        
        
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
                    self.broadcast.showScoreboard(showAdButton: showAdButton)
                }
                else {
                    
                    //If score is not in top 5, query the rank of the score and pass it to the table, where it will be handled
                    let rankList = self.ref.child(Constants.baseChild)
                    rankList.queryOrderedByPriority().queryStarting(atValue: self.broadcast.getScore(), childKey: Constants.score).observeSingleEvent(of: .value, with: { (rankSnapshot) in
                        
                        if rankSnapshot.value != nil {
                            
                            self.scoreTable.updateCurrentRank(rank: Int(rankSnapshot.childrenCount) + 1)
                            self.scoreTable.scores = scoreList
                            self.scoreTable.refresh()
                            self.broadcast.showScoreboard(showAdButton: showAdButton)
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
        self.broadcast.showScoreboard(showAdButton: false)
    }
    
    
    internal func convertSnapshotToDictionary(snapshot: FIRDataSnapshot) -> Array<NSDictionary> {
        
        
        //Convert snapshot of list to a dictionary
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
    
    
    
    @IBAction func scoreTableTapped(_ sender: AnyObject) {
        
        
        if broadcast.scoreTableView.alpha != 0 {
            
            //Show and enable username change view and its elements
            blurView.isUserInteractionEnabled = true
            usernameChangeField.alpha = 1
            usernameChangeHeader.alpha = 1
            aboutLabel.alpha = 0
            usernameChangeField.isUserInteractionEnabled = true
            
            UIView.animate(withDuration: 0.4, animations: {
                
                self.blurView.alpha = 1
                
            }) { (Bool) in
                
                //Enable keyboard and select text field
                self.usernameChangeField.becomeFirstResponder()
                self.usernameChangeField.isSelected = true
            }
        }
    }
    
    
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        //Return whether replacing string is within length restriction
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            
            return false
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 6
    }
    
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        let text = textField.text
        if text != nil && text != "" {
            
            //Set the user default, then re-initialize parameters
            userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: text!), forKey: Constants.username)
            initializeParameters()
            scoreTable.initializeParameters()
            
            //Hide username change view, send score update to database and request more scores
            hideUsernameChangeView()
            sendScore()
            
            if adButton.alpha == 1 {
                
                requestScores(showAdButton: true)
            }
            else {
                
                requestScores(showAdButton: false)
            }
        }
        
        return false
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        //If username change view is displayed, do the following
        if self.blurView.alpha == 1 {
            
            //If user touches the text field, stay. Else, leave.
            let location = touches.first!.location(in: self.view)
            let touchedField = location.x > usernameChangeField.frame.minX && location.x < usernameChangeField.frame.maxX && location.y > usernameChangeField.frame.minY && location.y < usernameChangeField.frame.maxY
            
            if !touchedField || !usernameChangeField.isUserInteractionEnabled {
                
                hideUsernameChangeView()
            }
        }
    }
    
    
    internal func hideUsernameChangeView() {
        
        
        //Remove keyboard and username change view
        self.usernameChangeField.resignFirstResponder()
        self.blurView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.blurView.alpha = 0
            
            }, completion: { (Bool) in
                
                self.usernameChangeField.isSelected = false
                self.usernameChangeField.text = nil
        })
    }
    
    
    
    @IBAction func adButtonPressed(_ sender: AnyObject) {
        
        
        print("adButtonPressed")
        if interstitial.isReady {
            
            //Show interstitial ad
            interstitial.present(fromRootViewController: self)
            
            //Check if current score is the best, set labels on broadcast view & pass score to table
            score.addPointsToScore()
            let newScore = score.getScore()
            setIfBestScore(newScore)
            broadcast.setScoreLabel(newScore)
            broadcast.setBestScoreLabel()
            scoreTable.updateCurrentScore(score: newScore)
            
            //Hide ad button
            adButton.alpha = 0
            adButton.isUserInteractionEnabled = false
            
            //Send current score to database and request more scores
            sendScore()
            requestScores(showAdButton: false)
            
        } else {
            print("Ad wasn't ready")
        }
    }
    
    
    internal func createAndLoadInterstitial() {
        
        
        print("createAndLoadInterstitial")
        interstitial = GADInterstitial(adUnitID: Constants.interstitialID)
        
        //Load request
        let request = GADRequest()
        request.testDevices = ["692e86106fd4b538b1824b62d6138614"]
        interstitial.load(request)
    }
    
    
    @IBAction func aboutButtonPressed(_ sender: AnyObject) {
        
        
        //Show and enable username change view and its elements
        blurView.isUserInteractionEnabled = true
        usernameChangeField.alpha = 0
        usernameChangeHeader.alpha = 0
        aboutLabel.alpha = 1
        usernameChangeField.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.blurView.alpha = 1
            
        }) { (Bool) in
            
            //Nothing for now
        }
    }
    
    
    @IBAction func shareButtonPressed(_ sender: AnyObject) {
        
        let textToShare = "Beat my score in Flakey!"
        
        if let flakeyLink = NSURL(string: "itms://itunes.apple.com/flakey/1168312945?mt=8") {
            let objectsToShare = [textToShare, flakeyLink] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController!.sourceView = sender as? UIView
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    
    internal func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        
        
        print("Collision!")
        if flake.alpha == 1 && !collided {
            
            collided = true
            dynamicAnimator.removeAllBehaviors()
            invalidateTimer()
            removeAvoidCloudTutorial()
            
            if item1 is Flake || item2 is Flake {
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    
                    print("finalScore \(self.score.getScore())")
                    self.resetView(finalScore: self.score.getScore())
                })
            }
            else if item1 is Cloud && item2 is Cloud {
                
                print("finalScore \(self.score.getScore())")
                self.resetView(finalScore: self.score.getScore())
            }
        }
    }
    
    
    
    override var prefersStatusBarHidden : Bool {
        
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

