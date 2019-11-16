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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    var myRefreshControl: UIRefreshControl!
    var number: Int!
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
        DataRequest.addAcceptableImageContentTypes(["application/octet-stream"])

        myRefreshControl = UIRefreshControl()
        myRefreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(myRefreshControl, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()
    }
    
    func loadData() {
        number = 20
        let query = PFQuery(className: "Posts")  //Get query Store data reload the table view
        query.includeKey("author")
        query.limit = number

        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        
    }
    
    func loadMoreData() {
        let query = PFQuery(className: "Posts")  //Get query Store data reload the table view
        query.includeKey("author")
        query.limit = number + 10
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as? String
        
        let imageFile = post["iamge"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        print(url)
        
        cell.photoView.af_setImage(withURL: url)
        return cell
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
        PFUser.logOutInBackground { (error) in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error \(error?.localizedDescription ?? "Could not log out")")
            }
        }
        
    }
    

}
