//
//  Broadcast.swift
//  Flakey
//
//  Created by Vikram Ramkumar on 9/15/16.
//  Copyright © 2016 Vikram Ramkumar. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


class Broadcast: UIView {
    
    
    let userDefaults = UserDefaults.standard
    var score = UILabel()
    var bestScore = UILabel()
    var scoreHeader = UILabel()
    var bestScoreHeader = UILabel()
    var scoreboardHeader = UILabel()
    var bestScoreBorder: Border!
    var scoreboardBorder: Border!
    var initialized = false
    var muted = false
    var audioPlayer = AVAudioPlayer()
    
    var activityIndicator = UIActivityIndicatorView()
    var activityIndicatorColor = UIColor.gray
    var themeGray = Constants.secondaryColor
    var tutorialColor = UIColor.gray
    var scoreTableView = UIView()
    var adButton = UIButton()
    var scoreTutorial: UIView?
    var scoreboardTutorial: UIView?
    var scoreboardTutorialLabel: UILabel!
    var scoreboardTutorialButton: UIButton!
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    
    internal func initializeViews() {
        
        
        print("initializeViews for  broadcast")
        //Fix flag for initialized
        initialized = true
        
        //Turn invisible first
        self.alpha = 0
        
        
        //Initialize all views
        scoreHeader = self.viewWithTag(1)! as! UILabel
        score = self.viewWithTag(2)! as! UILabel
        bestScoreBorder = self.viewWithTag(3)! as! Border
        bestScoreBorder.drawLine()
        bestScoreHeader = self.viewWithTag(4)! as! UILabel
        bestScore = self.viewWithTag(5)! as! UILabel
        scoreboardBorder = self.viewWithTag(6)! as! Border
        scoreboardBorder.drawLine()
        scoreboardHeader = self.viewWithTag(7)! as! UILabel
        scoreTableView = self.viewWithTag(8)!
        adButton = self.viewWithTag(9) as! UIButton
        
        
        //Initialize and add activity indicator
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: self.bounds.width/2, y: scoreTableView.center.y)
        
        
        //Set best score and show tutorials
        setBestScoreLabel()
        self.showScoreTutorial()
    }
    
    
    internal func showScoreboard(showAdButton: Bool) {
        
        if userDefaults.bool(forKey: Constants.scoreTutorialKey)  {
            
            //Stop animating activity indicator, then show the score table and ad button
            print("showScoreboard")
            activityIndicator.stopAnimating()
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.scoreTableView.alpha = 1
                self.scoreboardHeader.alpha = 1
                
                //Only show ad button if the tutorial has been completed
                if self.userDefaults.bool(forKey: Constants.scoreboardTutorialKey) && showAdButton {
                    
                    self.adButton.alpha = 1
                }
                
            }) { (Bool) in
                
                //Enable ad button at the end if it's been shown
                if self.adButton.alpha == 1 {
                    
                    self.adButton.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    
    internal func hideScoreBoard() {
        
        
        if userDefaults.bool(forKey: Constants.scoreTutorialKey)  {
            
            //Hide the score table, disable ad button, and start animating activity indicator
            print("hideScoreboard")
            self.scoreTableView.alpha = 0
            self.adButton.alpha = 0
            self.scoreboardHeader.alpha = 0
            self.adButton.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
        }
    }
    
    
    internal func setScoreLabel(_ newScore: Int) {
        
        //Set score label
        score.text = String(newScore)
    }
    
    
    internal func getScore() -> Int {
        
        //Get score from score label
        if score.text != "" {
            
            return Int(score.text!)!
        }
        
        return 0
    }
    
    
    internal func setBestScoreLabel() {
        
        let best = userDefaults.integer(forKey: "bestScore")
        bestScore.text = String(best)
    }
    
    
    
    internal func showScoreTutorial() {
        
        
        //Show score tutorial
        if !userDefaults.bool(forKey: Constants.scoreTutorialKey) && scoreTutorial == nil {
            
            //Hide score table
            scoreTableView.alpha = 0
            
            //Create score tutorial
            scoreTutorial = UIView(frame: scoreTableView.frame)
            
            //Create label to show instructions
            let label = UILabel(frame: CGRect(x: 0, y: 10, width: scoreTutorial!.bounds.width, height: 70))
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
            label.numberOfLines = 0
            label.textColor = tutorialColor
            label.text = Constants.scoreTutorialText
            
            
            //Create button to dismiss
            let button = UIButton(type: .system)
            button.frame = CGRect(x: scoreTutorial!.bounds.width/2 - 50, y: label.frame.maxY, width: 100, height: 45)
            button.setTitle("OK", for: .normal)
            button.titleLabel!.font = UIFont(name: Constants.buttonFont, size: Constants.buttonFontSize)
            button.setTitleColor(UIColor.white, for: .normal)
            button.backgroundColor = tutorialColor
            button.addTarget(self, action: #selector(removeScoreTutorial), for: .touchUpInside)
            button.layer.cornerRadius = button.bounds.height/2
            button.clipsToBounds = true
            
            //Add tutorial view
            scoreTutorial!.addSubview(label)
            scoreTutorial!.addSubview(button)
            self.addSubview(scoreTutorial!)
        }
    }
    
    
    internal func removeScoreTutorial() {
        
        
        //Remove score tutorial if it's shown
        if scoreTutorial != nil {
            
            //Play sound as feedback
            let sound = NSURL(fileURLWithPath: Bundle.main.path(forResource: Constants.tutorialSoundFile, ofType: "wav")!)
            playSound(soundURL: sound)
            
            //Set tutorial key
            userDefaults.set(true, forKey: Constants.scoreTutorialKey)
            
            //Do animations and removal
            UIView.animate(withDuration: 0.3, animations: { 
                
                self.scoreTutorial!.alpha = 0
                
            }, completion: { (Bool) in
                
                self.scoreTutorial!.removeFromSuperview()
                self.scoreTutorial = nil
                
                //Show scoreboard and its tutorial
                self.showScoreboard(showAdButton: true)
                self.showScoreboardTutorial()
            })
        }
    }
    
    
    internal func showScoreboardTutorial() {
        
        
        //Show score tutorial
        if !userDefaults.bool(forKey: Constants.scoreboardTutorialKey) && scoreboardTutorial == nil {
            
            
            //Create score tutorial
            let tutorialWidth = CGFloat(275)
            let tutorialHeight = bestScore.frame.maxY - score.frame.minY
            scoreboardTutorial = UIView(frame: CGRect(x: self.bounds.width/2 - tutorialWidth/2, y: score.frame.minY, width: tutorialWidth, height: tutorialHeight))
            
            //Create label to show instructions
            scoreboardTutorialLabel = UILabel(frame: CGRect(x: 0, y: 10, width: scoreboardTutorial!.bounds.width, height: 100))
            scoreboardTutorialLabel.textAlignment = .center
            scoreboardTutorialLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
            scoreboardTutorialLabel.numberOfLines = 0
            scoreboardTutorialLabel.textColor = tutorialColor
            scoreboardTutorialLabel.text = Constants.scoreboardTutorialText1
            
            
            //Create button to dismiss
            scoreboardTutorialButton = UIButton(type: .system)
            scoreboardTutorialButton.frame = CGRect(x: scoreboardTutorial!.bounds.width/2 - 50, y: scoreboardTutorialLabel.frame.maxY, width: 100, height: 45)
            scoreboardTutorialButton.setTitle("GOT IT", for: .normal)
            scoreboardTutorialButton.titleLabel!.font = UIFont(name: Constants.buttonFont, size: Constants.buttonFontSize)
            scoreboardTutorialButton.setTitleColor(UIColor.white, for: .normal)
            scoreboardTutorialButton.backgroundColor = tutorialColor
            scoreboardTutorialButton.addTarget(self, action: #selector(removeScoreboardTutorial), for: .touchUpInside)
            scoreboardTutorialButton.layer.cornerRadius = scoreboardTutorialButton.bounds.height/2
            scoreboardTutorialButton.clipsToBounds = true
            
            
            //Add tutorial
            scoreboardTutorial!.alpha = 0
            scoreboardTutorial!.addSubview(scoreboardTutorialLabel)
            scoreboardTutorial!.addSubview(scoreboardTutorialButton)
            self.addSubview(scoreboardTutorial!)
            
            
            //Animate
            UIView.animate(withDuration: 0.3, animations: {
                
                //Hide score and best score labels
                self.scoreHeader.alpha = 0
                self.score.alpha = 0
                self.bestScoreHeader.alpha = 0
                self.bestScore.alpha = 0
                self.bestScoreBorder.alpha = 0
                
            }, completion: { (Bool) in
                
                //Show tutorial
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.scoreboardTutorial!.alpha = 1
                })
            })
        }
    }
    
    
    internal func removeScoreboardTutorial() {
        
        
        //Remove score tutorial if it's shown
        if scoreboardTutorial != nil {
            
            //Play sound as feedback
            let sound = NSURL(fileURLWithPath: Bundle.main.path(forResource: Constants.tutorialSoundFile, ofType: "wav")!)
            playSound(soundURL: sound)
            
            if scoreboardTutorialLabel.text! == Constants.scoreboardTutorialText1 {
                
                //Change the text of the tutorial
                scoreboardTutorialLabel.text = Constants.scoreboardTutorialText2
                
                
                //If the score board has been displayed, remove button so the user is forced
                //to change their username. If it hasn't been displayed (because it's loading),
                //give the user the ability to move forward and not get stuck.
                if scoreTableView.alpha == 1 {
                    
                    scoreboardTutorialButton.removeFromSuperview()
                }
                else {
                    
                    scoreboardTutorialButton.setTitle("DONE", for: .normal)
                }
            }
            else {
                
                //Set tutorial key
                self.userDefaults.set(true, forKey: Constants.scoreboardTutorialKey)
                
                //Show buttons in main view
                let parent = self.superview!.next as! GameController
                parent.expandButtons()
                
                //Do animations and removal
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.scoreboardTutorial!.alpha = 0
                    
                }, completion: { (Bool) in
                    
                    self.scoreboardTutorial!.removeFromSuperview()
                    self.scoreboardTutorial = nil
                    
                    //Restore score and best score labels
                    UIView.animate(withDuration: 0.3, animations: {
                        
                        self.scoreHeader.alpha = 1
                        self.score.alpha = 1
                        self.bestScoreHeader.alpha = 1
                        self.bestScore.alpha = 1
                        self.bestScoreBorder.alpha = 1
                    })
                })

            }
        }
    }
    
    
    internal func playSound(soundURL: NSURL) {
        
        
        //If not muted, play sound
        if !muted {
            
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: soundURL as URL)
                audioPlayer.play()
            }
            catch let error as NSError {
                print("Error playing sound: \(error)")
            }
        }
    }
}
