//
//  FeedViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 06/05/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase
import IBAnimatable

let FeedNotificationKey1 = "com.mp.feedNotificationKey"
let FeedNotificationKey2 = "com.mp.feedNotificationKey2"
class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarControllerDelegate {
    
    @IBOutlet weak var FeedCollectionView: UICollectionView!
    
    var posts = [Post]()
    var user = [User]()
    var following = [String]()
    
    var ref: FIRDatabaseReference?
    var databaseHandle: FIRDatabaseHandle?
    
    var refresher:UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify), name: NSNotification.Name(rawValue: FeedNotificationKey1), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAfterLikeFromPPage), name: NSNotification.Name(rawValue: FeedNotificationKey2), object: nil)
        self.tabBarController?.delegate = self
        // Sets up the database reference
        ref = FIRDatabase.database().reference()
        
        observePosts()
        
        let refresher = UIRefreshControl()
        self.FeedCollectionView!.alwaysBounceVertical = true
        refresher.tintColor = UIColor.white
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.FeedCollectionView!.refreshControl = refresher
        self.FeedCollectionView!.refreshControl?.beginRefreshing()


        
    }
    
    func doThisWhenNotify() {
        posts.removeAll()
        observePosts()
        
    }
    
    func refreshAfterLikeFromPPage(){
        self.attemptReloadOfTable()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {
            print("1")
            self.FeedCollectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),at: .top, animated: true)
        }
    }



 
    
    func refresh()
    {
       self.attemptReloadOfTable()
   
        self.FeedCollectionView!.refreshControl?.endRefreshing()
    }


    
    
    func observeUsers(){
        
        //____
        
        databaseHandle = ref?.child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let userToShow = User()
                
                userToShow.fullName = dictionary["full name"] as! String
                userToShow.imgPath = dictionary["urlToImage"] as! String
                userToShow.userID = dictionary["uid"] as! String
                
                
                self.user.append(userToShow)
                
                DispatchQueue.main.async(execute: {
                    self.FeedCollectionView.reloadData()
                })
                
            }
            
            
            
        })
    }
    
    
    func observePosts() {
        observeUsers()
        observePostsChildRemoved()
        observePostsChildChanged()
        
        databaseHandle = ref?.child("posts").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let post = Post()
                
                post.title = dictionary["title"] as! String
                post.timestamp = dictionary["timestamp"] as! NSNumber
                post.desc = dictionary["description"] as! String
                post.likes = dictionary["likes"] as! Int
                post.pathToImage = dictionary["pathToImage"] as! String
                post.postID = dictionary["postID"] as! String
                post.userID = dictionary["userID"] as! String
                
                self.posts.append(post)
                
                
                self.attemptReloadOfTable()
            }
            
            
            
        })
        
    }
    
    func observePostsChildRemoved() {
        //
        databaseHandle = ref?.child("posts").observe(.childRemoved, with: { (snapshot) in
        
            print("\(snapshot.key) is the key")
            print("deleted")
            var postsIndex: Int!
            
            for i in 0...self.posts.count-1{
                print(self.posts[i].postID)
            
                if self.posts[i].postID == snapshot.key{
                    print(i)
                    postsIndex = i
                    
                }
            
            }
            
         self.posts.remove(at: postsIndex)
            
        self.attemptReloadOfTable()
        
        
        })
        
    }
    
    func observePostsChildChanged() {
        //
        databaseHandle = ref?.child("posts").observe(.childChanged, with: { (snapshot) in
            
            var postsIndex: Int!
            
            for i in 0...self.posts.count-1{
                print(self.posts[i].postID)
                
                if self.posts[i].postID == snapshot.key{
                    print(i)
                    postsIndex = i
                    
                }
                
            }
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let likes: Int!
                
         
                likes = dictionary["likes"] as! Int
           
                
                
                self.posts[postsIndex].likes = likes
                
               
            }
            
            
            
            
            
        })
        
    }
    
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    func handleReloadTable() {
        self.posts.sort(by: { (post1, post2) -> Bool in
            
            return post1.timestamp.intValue > post2.timestamp.intValue
        })
        
        DispatchQueue.main.async(execute: {
            self.FeedCollectionView.reloadData()
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        
        //Sets Authors display name to post
        for x in 0...user.count-1 {
            if posts[indexPath.row].userID == user[x].userID {
                cell.authorLabel.text = self.user[x].fullName
                
            }
        }
        
        //Displays post's image
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        
        //Displays amount of likes on post
        cell.likeLabel.text = "\(self.posts[indexPath.row].likes!) "
        
        //Sets cells post id to the one in the array
        cell.postID = self.posts[indexPath.row].postID
        
        //Displays post's title
        cell.titleLabel.text = self.posts[indexPath.row].title
        
        //Displays post's date
        
        
        let timeStampDate = NSDate(timeIntervalSince1970: self.posts[indexPath.row].timestamp.doubleValue)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        //cell.dateLabel.text = dateFormatter.string(from: timeStampDate as Date)
        cell.dateLabel.text = timeAgoSinceDate(date: timeStampDate, numericDates: true)
        
        //Shows either like or unlike button depending on if user has liked the post
        for person in self.posts[indexPath.row].peopleWhoLike {
            if person == FIRAuth.auth()!.currentUser!.uid {
                cell.likeBtn.isHidden = true
                cell.unlikeBtn.isHidden = false
                break
            }
        }
        
        //Sets posts user profile image
        for i in 0...user.count-1 {
            
            if posts[indexPath.row].userID == user[i].userID {
                
                cell.imageView.downloadImage(from: user[i].imgPath)
            }
        }
        
        //Checks if user has liked the post
        cell.checkIfLiked()

        cell.contentView.layer.backgroundColor = UIColor.white.cgColor
       
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        selectedPostID = self.posts[indexPath.row].postID
        
        
        
        performSegue(withIdentifier: "postPage", sender: self)
        
    }

    
    @IBAction func mePressed(_ sender: Any) {
        let Puid = FIRAuth.auth()?.currentUser?.uid
        
        userPageID = Puid
        performSegue(withIdentifier: "userPage", sender: self)
    }
    
    @IBAction func ProfilePicPressed(_ sender: Any) {
        performSegue(withIdentifier: "userPage", sender: self)
    }
    @IBAction func usernamePressed(_ sender: Any) {
        performSegue(withIdentifier: "userPage", sender: self)
    }
   

}


