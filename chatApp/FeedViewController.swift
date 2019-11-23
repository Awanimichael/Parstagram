//
//  FeedViewController.swift
//  chatApp
//
//  Created by Rotimi Awani on 11/15/19.
//  Copyright © 2019 Rotimi Awani. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import Alamofire
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar() // commentBar for MessageInputBa cocoapods
    
    var posts = [PFObject]()
    var myRefreshControl: UIRefreshControl!
    var number: Int!
    var showsCommentBar = false
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
        DataRequest.addAcceptableImageContentTypes(["application/octet-stream"])

        myRefreshControl = UIRefreshControl()
        myRefreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(myRefreshControl, at: 0)
        
        tableView.keyboardDismissMode = .interactive
        
        //call the keyboardwillbehiidden method
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
    }
    
    //method to hide commentBar when keyboard is hidden
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        
    }
    //This is called when the post button is clicked in the MessageInputBar
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment Saved")
            } else {
                print("Error saving comment")
            }
        }
        //After comments are set reload data to fetch new comments form parse
        tableView.reloadData()
    
        //clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    // two functions to implement the feature for message input bar
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()
    }
    
    func loadData() {
        number = 5
        let query = PFQuery(className: "Posts")  //Get query Store data reload the table view
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = number
        query.order(byDescending: "createdAt")

        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts.removeAll()
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        
    }
    
    func loadMoreData() {
        let query = PFQuery(className: "Posts")  //Get query Store data reload the table view
        query.includeKey("author")
        number = number + 5
        query.limit = number
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts.removeAll()
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    // This helps to load more data as users scrolls to the end of the table view
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadMoreData()
        }
    }
    
    // Implement Sections
    func numberOfSections(in tableView: UITableView) -> Int {
           return posts.count
       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            
            
            let imageFile = post["iamge"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            cell.photoView.af_setImage(withURL: url)
            
            //get profile picture
            let imgFile = user["profilePicture"] as? PFFileObject
            if imgFile != nil{
                let urlStr = imgFile?.url!
                let url2 = URL(string: urlStr!)
                cell.profilePhotoView.af_setImage(withURL: url2!)
            } else {
                cell.profilePhotoView.image = UIImage(systemName: "person")
            }
            

            
            return cell
            
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Run when a user click of each cell
        let post = posts[indexPath.section]
        // Create a comments table
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
        }
        selectedPost = post
        
//        Creating fake comments
//        comment["text"] = "This is a random comment"
//        comment["post"] = post // What post it is linked to
//        comment["author"] = PFUser.current() // Who made the comment
//
//        post.add(comment, forKey: "comments")
//
//        post.saveInBackground { (sucess, error) in
//            if sucess {
//                print("Comment Saved")
//            } else {
//                print("Error saving comments")
//            }
//        }
        
    }
   
    
    // Implement the delay method
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    @objc func onRefresh() {
        run(after: 2) {
            self.myRefreshControl.endRefreshing()
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut() // Clears the cache, now no one is logged in
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window?.rootViewController = loginViewController
        
    }
    

}
