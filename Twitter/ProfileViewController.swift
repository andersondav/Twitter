//
//  ProfileViewController.swift
//  AFNetworking
//
//  Created by Anderson David on 2/5/19.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileBannerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileTweetsTableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    
    var userInfo = NSDictionary()
    var screen_name:String = ""
    var userTweets = [NSDictionary]()
    var numberOfTweet:Int = 20
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = "https://api.twitter.com/1.1/account/verify_credentials.json"
        
        TwitterAPICaller.client?.getDictionaryRequest(url: url, parameters: [:], success: { (results) in
            self.userInfo = results
            print(self.userInfo)
            
            self.usernameLabel.text = (self.userInfo["name"] as! String)
            self.screennameLabel.text = "@\(self.userInfo["screen_name"] as! String)"
            
            let profile_img_url = URL(string: self.userInfo["profile_image_url_https"] as! String)
            let data = try? Data(contentsOf: profile_img_url!)
            
            if let image = data {
                self.profileImage.image = UIImage(data: image)
            }
            
            let bannerurl = URL(string: self.userInfo["profile_banner_url"] as! String)
            let bannerdata = try? Data(contentsOf: bannerurl!)
            
            if let image = bannerdata {
                self.profileBannerImage.image = UIImage(data: image)
            }
            
            self.followersLabel.text = String(self.userInfo["followers_count"] as! Int)
            self.followingLabel.text = String(self.userInfo["friends_count"] as! Int)
            
            self.tweetLabel.text = "\(String(self.userInfo["statuses_count"] as! Int)) Tweets"
            
            self.screen_name = self.userInfo["screen_name"] as! String
        }, failure: { (error) in
            print("there was an error retrieving profiles: \(error)")
        })
        
        profileTweetsTableView.delegate = self
        profileTweetsTableView.dataSource = self
        
        loadTweets()
        
        profileTweetsTableView.rowHeight = UITableView.automaticDimension
        profileTweetsTableView.estimatedRowHeight = 150
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    func loadTweets() {
        
        numberOfTweet = 20
        
        let url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let params = ["screen_name": self.screen_name, "count": numberOfTweet, "include_rts": true] as [String : Any]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: params, success: { (results) in
            self.userTweets = results
            print(self.userTweets)
            self.numberOfTweet = self.userTweets.count
            self.profileTweetsTableView.reloadData()
        }, failure: { (error) in
            print("error in retrieving user tweets: \(error)")
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userTweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell") as! TweetCell
        
        let user = userTweets[indexPath.row]["user"] as! NSDictionary
        
        cell.usernameLabel.text = user["name"] as! String
        cell.tweetContentLabel.text = userTweets[indexPath.row]["text"] as! String
        
        let imageUrl = URL(string: user["profile_image_url_https"] as! String)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        cell.setFavorite(userTweets[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = userTweets[indexPath.row]["id"] as! Int
        cell.setRetweet(userTweets[indexPath.row]["retweeted"] as! Bool)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == userTweets.count {
            loadMoreTweets()
        }
    }
    
    func loadMoreTweets() {
        
        let myUrl = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        
        numberOfTweet = numberOfTweet + 20
        
        let params = ["screen_name": self.screen_name, "count": numberOfTweet, "include_rts": true] as [String : Any]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: params, success: { (tweets: [NSDictionary]) in
            
            self.userTweets.removeAll()
            for tweet in tweets {
                self.userTweets.append(tweet)
            }
            
            self.profileTweetsTableView.reloadData()
            
        }, failure: { (Error) in
            print("could not retrieve tweets")
        })
        
    }
}
