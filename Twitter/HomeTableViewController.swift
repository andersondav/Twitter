//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Anderson David on 1/28/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweetsArray = [NSDictionary]()
    var numberOfTweet: Int!
    
    let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTweet()
        
        myRefreshControl.addTarget(self, action: #selector(loadTweet), for: .valueChanged)
        
        tableView.refreshControl = myRefreshControl
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 150

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTweet()
    }
    
    @objc func loadTweet() {
        
        numberOfTweet = 20
        
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        
        let myParams = ["count": numberOfTweet]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams, success: { (tweets: [NSDictionary]) in
            
            self.tweetsArray.removeAll()
            for tweet in tweets {
                self.tweetsArray.append(tweet)
            }
            //print(self.tweetsArray)
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print("could not retrieve tweets")
            self.myRefreshControl.endRefreshing()
        })
        
    }
    
    func loadMoreTweets() {
        
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        
        numberOfTweet = numberOfTweet + 20
        
        let myParams = ["count": numberOfTweet]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams, success: { (tweets: [NSDictionary]) in
            
            self.tweetsArray.removeAll()
            for tweet in tweets {
                self.tweetsArray.append(tweet)
            }
            
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print("could not retrieve tweets")
        })
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetsArray.count {
            loadMoreTweets()
        }
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let entities = tweetsArray[indexPath.row]["entities"] as! NSDictionary
        
        //print(entities)
        
        if let media = entities["media"] as? [NSDictionary] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCellWithImage") as! TweetCellWithImage
            
            print("adding subview")
            
            let mediaUrl = URL(string: media[0]["media_url_https"] as! String)
            
            let mediaData = try? Data(contentsOf: mediaUrl!)
            
            cell.mediaImage.image = UIImage(data: mediaData!)
            
            let user = tweetsArray[indexPath.row]["user"] as! NSDictionary
            
            cell.usernameLabel.text = user["name"] as! String
            cell.tweetContentLabel.text = tweetsArray[indexPath.row]["text"] as! String
            
            let imageUrl = URL(string: user["profile_image_url_https"] as! String)
            let data = try? Data(contentsOf: imageUrl!)
            
            if let imageData = data {
                cell.profileImageView.image = UIImage(data: imageData)
            }
            
            cell.setFavorite(tweetsArray[indexPath.row]["favorited"] as! Bool)
            cell.tweetId = tweetsArray[indexPath.row]["id"] as! Int
            cell.setRetweet(tweetsArray[indexPath.row]["retweeted"] as! Bool)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
            
            let user = tweetsArray[indexPath.row]["user"] as! NSDictionary
            
            cell.usernameLabel.text = user["name"] as! String
            cell.tweetContentLabel.text = tweetsArray[indexPath.row]["text"] as! String
            
            let imageUrl = URL(string: user["profile_image_url_https"] as! String)
            let data = try? Data(contentsOf: imageUrl!)
            
            if let imageData = data {
                cell.profileImageView.image = UIImage(data: imageData)
            }
            
            cell.setFavorite(tweetsArray[indexPath.row]["favorited"] as! Bool)
            cell.tweetId = tweetsArray[indexPath.row]["id"] as! Int
            cell.setRetweet(tweetsArray[indexPath.row]["retweeted"] as! Bool)
            return cell
        }
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
