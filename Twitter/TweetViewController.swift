//
//  TweetViewController.swift
//  Twitter
//
//  Created by Anderson David on 2/4/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tweetTextView.becomeFirstResponder()
        
        characterCountLabel.text = "0/280"
        
        tweetTextView.delegate = self
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tweet(_ sender: Any) {
        if (!tweetTextView.text.isEmpty) {
            TwitterAPICaller.client?.postTweet(tweetString: tweetTextView.text, success: {
                self.dismiss(animated: true, completion: nil)
                }, failure: { (error) in
                    print("Error posting tweet \(error)")
                })
        } else {
            dismiss(animated: true, completion: nil)
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

    func textViewDidChange(_ textView: UITextView) {
        var count = tweetTextView.text.count
        
        if count >= 280 {
            count = 280
            tweetTextView.text = String(tweetTextView.text!.prefix(280))
        }
        
        characterCountLabel.text = "\(count)/280"
        
        
    }
    
}
