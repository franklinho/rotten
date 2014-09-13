//
//  MovieDetailsViewController.swift
//  rotten
//
//  Created by Franklin Ho on 9/12/14.
//  Copyright (c) 2014 Franklin Ho. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    var movie : NSDictionary = [:]
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var summaryView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = movie["title"] as? String
        
        var title : String = movie["title"] as String
        var year : Int = movie["year"] as Int
        var ratings : NSDictionary = movie["ratings"] as NSDictionary
        var criticsScore : Int = ratings["critics_score"] as Int
        var audienceScore : Int = ratings["audience_score"] as Int
        var synopsis :String = movie["synopsis"] as String
        var rating : String = movie["mpaa_rating"] as String
    
        summaryView.frame.origin.y=350
        
        self.titleLabel.text = title+" ("+String(year)+")"
        self.scoreLabel.text = "Critics Score: \(String(criticsScore)), Audience Score: \(String(audienceScore))"
        self.ratingLabel.text = rating
        self.summaryLabel.text = synopsis
        
        var posters = movie["posters"] as NSDictionary
        var thumbnailPosterURL = posters["thumbnail"] as String

        var detailedPosterURL = thumbnailPosterURL.stringByReplacingOccurrencesOfString("tmb", withString: "det", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        println("\(detailedPosterURL)")
        
        posterView.alpha = 0.0
        posterView.setImageWithURL(NSURL(string: thumbnailPosterURL))
        
        UIView.animateWithDuration(1.0,
            delay: 0.0,
            options: nil,
            animations: {
                self.posterView.alpha = 1.0
            },
            completion: {
                finished in
        })

        
        posterView.setImageWithURL(NSURL(string: detailedPosterURL))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    @IBAction func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
        var newY : CGPoint = CGPoint(x: sender.view!.frame.origin.x, y: sender.view!.frame.origin.y + translation.y)

        
        
        if (newY.y > 57 && newY.y < 350){
            sender.view!.frame.origin = CGPoint(x:sender.view!.frame.origin.x,
                y:sender.view!.frame.origin.y + translation.y)
            sender.setTranslation(CGPointZero, inView: self.view)
            
            if sender.state == UIGestureRecognizerState.Ended {
                //1
                
                let velocity = sender.velocityInView(self.view)
                let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
                let slideMultiplier = magnitude/200
                println("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
                
                //2
                let slideFactor = 0.1 * slideMultiplier
                
                //3
                var finalPoint = CGPoint(x:sender.view!.frame.origin.x, y: sender.view!.frame.origin.y + (velocity.y * slideFactor))
                
                //4
                
                finalPoint.x = min(max(finalPoint.x, 0), self.view.frame.origin.x)
                finalPoint.y = min(max(finalPoint.y,63), 350)
                
                UIView.animateWithDuration(Double(slideFactor), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {sender.view!.frame.origin = finalPoint}, completion: nil)
                
        }
        
        
            
        }
        
        
        
        

    
    }
    
    
}
