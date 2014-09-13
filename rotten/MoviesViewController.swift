//
//  MoviesViewController.swift
//  rotten
//
//  Created by Franklin Ho on 9/12/14.
//  Copyright (c) 2014 Franklin Ho. All rights reserved.
//

import UIKit
import Foundation


class MoviesViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary] = []
    var refreshControl : UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.movieSearchBar.delegate = self
        
        UITabBar.appearance().backgroundColor = UIColor.blackColor()
        
        GSProgressHUD.show()

        
        
        networkErrorView.hidden = true
        
        navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.yellowColor()]
        navigationController?.navigationBar.tintColor = UIColor.yellowColor()

        navigationController?.navigationBar.backgroundColor = UIColor.blackColor()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "requestMovies:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.requestMovies(self)
        
        
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

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return movies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("I'm at row \(indexPath.row),section: \(indexPath.section)")
        
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell") as MovieCell

        
        var movie = movies[indexPath.row]
        var mpaaRating : String! = movie["mpaa_rating"] as String
        var boldAttrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(17.0)]
        var attrs = [NSFontAttributeName : UIFont.systemFontOfSize(17.0)]
    
        var synopsisAttributed = NSMutableAttributedString(string:mpaaRating, attributes:boldAttrs)
        
        var synopsis = NSMutableAttributedString(string: movie["synopsis"] as String)
        
        synopsisAttributed.appendAttributedString(NSMutableAttributedString(string:" "))
        synopsisAttributed.appendAttributedString(synopsis)
        
        
        cell.movieTitleLabel.text = movie["title"] as? String
        cell.synopsisLabel.attributedText = synopsisAttributed
        
        var posters = movie["posters"] as NSDictionary
        var posterURL = posters["thumbnail"] as String
        
        cell.posterView.alpha = 0.0
        cell.posterView.setImageWithURL(NSURL(string: posterURL))
        
        UIView.animateWithDuration(1.0,
            delay: 0.0,
            options: nil,
            animations: {
                cell.posterView.alpha = 1.0
            },
            completion: {
                finished in
        })
        
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var movieDetailsViewController: MovieDetailsViewController = segue.destinationViewController as MovieDetailsViewController
        var movieIndex = tableView!.indexPathForSelectedRow()?.row
        var selectedMovie = self.movies[movieIndex!]
        movieDetailsViewController.movie = selectedMovie
        
    }
    
    func showNetworkError(){
        UIView.animateWithDuration(1.0,
            delay: 0.0,
            options: nil,
            animations: {
                self.networkErrorView.hidden = false
            },
            completion: {
                finished in
        })
        
        
    }
    
    func requestMovies(sender:AnyObject){
        
        var url = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=ta8ydxyay5r2xgqrrtfqpek3&limit=20&country=us"
        
        
        if movieSearchBar.text != "" {
            var encodedString : String = movieSearchBar.text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())! as String
            url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=ta8ydxyay5r2xgqrrtfqpek3&page_limit=1&q=\(encodedString)"
        }
        
        
        var request = NSURLRequest(URL: NSURL(string:url))
        println("\(request)")
        
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error:NSError!) -> Void in
            
            if (error == nil) {
                var object = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as NSDictionary
                
                println("object: \(object)")
                
                self.movies = object["movies"] as [NSDictionary]
                
                
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                if(GSProgressHUD.isVisible()) {
                    GSProgressHUD.dismiss()
                }
                self.networkErrorView.hidden = true
            } else {
                if(GSProgressHUD.isVisible()) {
                    GSProgressHUD.dismiss()
                }
                self.refreshControl.endRefreshing()
                self.showNetworkError()
                
            }
            
            
            
            
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        println("Search button pressed")
        self.requestMovies(self)
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        movieSearchBar.enablesReturnKeyAutomatically = false
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        movieSearchBar.text = ""
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.view.endEditing(true)
    }
    

}
