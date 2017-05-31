//
//  userPageViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 02/03/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

var userPageID: String!
let FollowNotificationKey = "com.mp.followNotificationKey"

class UserPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var followingLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var postsLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var settingsBarBtn: UIButton!
    var settingsBarBtnItem:UIBarButtonItem!
    var followBarBtn: UIButton!
    var followBarBtnItem:UIBarButtonItem!
    var unfollowBarBtn: UIButton!
    var unfollowBarBtnItem:UIBarButtonItem!
   
    
    let ref = FIRDatabase.database().reference()
    let uid = FIRAuth.auth()!.currentUser!.uid
    
    var user = [User]()
    var following = [String]()
    var followers = [String]()
    var posts = [Post]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Settings Btn
        settingsBarBtn = UIButton(type: .custom)
        settingsBarBtn.setImage(UIImage(named: "settings"), for: .normal)
        settingsBarBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        settingsBarBtn.addTarget(self, action: #selector(UserPageViewController.buttonMethod), for: .touchUpInside)
        settingsBarBtnItem = UIBarButtonItem(customView: settingsBarBtn)
        
        //Follow Btn
        followBarBtn = UIButton(type: .custom)
        followBarBtn.setImage(UIImage(named: "follow"), for: .normal)
        followBarBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        followBarBtn.addTarget(self, action: #selector(UserPageViewController.followMethod), for: .touchUpInside)
        followBarBtnItem = UIBarButtonItem(customView: followBarBtn)
        
        //Unfollow Btn
        unfollowBarBtn = UIButton(type: .custom)
        unfollowBarBtn.setImage(UIImage(named: "unfollow"), for: .normal)
        unfollowBarBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        unfollowBarBtn.addTarget(self, action: #selector(UserPageViewController.unfollowMethod), for: .touchUpInside)
        unfollowBarBtnItem = UIBarButtonItem(customView: unfollowBarBtn)
        
        
        
        
        self.navigationItem.setRightBarButtonItems([self.followBarBtnItem], animated: true)        

        
        
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveUser()
        getFollowers()
        getFollowing()
        fetchPosts()
        
    

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let yourBackImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    
    
    func buttonMethod() {
        performSegue(withIdentifier: "settingsSegue", sender: nil)
    }
    
    func unfollowMethod(){
      

            ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                
                if let following = snapshot.value as? [String : AnyObject] {
                    for (ke, value) in following {
                        if value as! String == self.user[0].userID {
                            
                            self.ref.child("users").child(self.uid).child("following/\(ke)").removeValue()
                            self.ref.child("users").child(self.user[0].userID).child("followers/\(ke)").removeValue()
                            
                            self.navigationItem.setRightBarButtonItems([self.followBarBtnItem], animated: true)
                        }
                    }
                    
                }
                
            })
            
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FollowNotificationKey), object: nil)

        
    }
    
    func followMethod(){
        let key = ref.child("users").childByAutoId().key
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
                let following = ["following/\(key)" : self.user[0].userID]
                let followers = ["followers/\(key)" : self.uid]
                
                self.ref.child("users").child(self.uid).updateChildValues(following)
                self.ref.child("users").child(self.user[0].userID).updateChildValues(followers)
                
                self.navigationItem.setRightBarButtonItems([self.unfollowBarBtnItem], animated: true)
                
                
            
        })
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FollowNotificationKey), object: nil)
    }
    
    func retrieveUser(){
        
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            self.user.removeAll()
            
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid == userPageID{
                        let userToShow = User()
                        if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String, let bio = value["bio"] as? String {
                            userToShow.fullName = fullName
                            userToShow.imgPath = imagePath
                            userToShow.userID = uid
                            userToShow.bio = bio
                            
                            self.user.append(userToShow)
                        }
                    }
                }
            }
        
            self.doSetup()
        })
        
        ref.removeAllObservers()
    }
    
    func doSetup() {
        nameLbl.text = self.user[0].fullName
        navigationItem.title = self.user[0].fullName
        infoLbl.text = self.user[0].bio
        profileImageView.downloadImage(from: self.user[0].imgPath!)
        
        if uid == userPageID {
            self.navigationItem.setRightBarButtonItems([settingsBarBtnItem], animated: true)
       
        }
        
        
        if uid != user[0].userID{
            ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                
                if let following = snapshot.value as? [String : AnyObject] {
                    for (_, value) in following {
                        if value as! String == self.user[0].userID {
                            
                            self.navigationItem.setRightBarButtonItems([self.unfollowBarBtnItem], animated: true)
                            
                        }
                        
                    }
                }
            })
            ref.removeAllObservers()
        }
        
    }

    

    
    func getFollowers(){
        
        
        ref.child("users").child(userPageID).child("followers").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let Snap = snapshot.value as? [String : AnyObject] {
            self.followers.removeAll()
            
            
            for (_,value) in Snap {
                if let follower = value as? String {
                    
                    self.followers.append(follower)
                }
                
            }
            
                self.followersLbl.text = "\(self.followers.count)"
            } else {
                self.followersLbl.text = "0"
            }
        })
        
        
    }
    
    func getFollowing(){
        
        
        ref.child("users").child(userPageID).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let Snaps = snapshot.value as? [String : AnyObject] {
            self.following.removeAll()
            
            
            for (_,value) in Snaps {
                if let usersFollowing = value as? String {
                    
                    self.following.append(usersFollowing)
                }
                
            }
            
                self.followingLbl.text = "\(self.following.count)"
                
            }else{
                
                self.followingLbl.text = "0"
            }
            
        })

        
    }
    
    func fetchPosts(){
   
        
        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            
            let postsSnap = snap.value as! [String : AnyObject]
            self.posts.removeAll()
            
            for (_,post) in postsSnap {
                if let userID = post["userID"] as? String {
                    
                        if userPageID == userID {
                            let posst = Post()
                            if  let likes = post["likes"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String {
                                
                            
                                posst.likes = likes
                                posst.pathToImage = pathToImage
                                posst.postID = postID
                                posst.userID = userID
                                if let people = post["peopleWhoLike"] as? [String : AnyObject] {
                                    for (_,person) in people {
                                        posst.peopleWhoLike.append(person as! String)
                                    }
                                }
                                
                                self.posts.append(posst)
                            }
                        }
                    
                    
                    self.collectionView.reloadData()
                }
            }
            
            self.postsLbl.text = "\(self.posts.count)"
        })
        
        
    }

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! userPostCell
        
        
        cell.imageView.downloadImage(from: self.posts[indexPath.row].pathToImage)
        
        let imageView2 = UIImageView()
        
        imageView2.downloadImage(from: self.posts[indexPath.row].pathToImage)
   
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPostID = self.posts[indexPath.row].postID
        performSegue(withIdentifier: "cellPostPage", sender: nil)
    }
    
}

extension UIImageView {
    func downloadImage(from imgURL: String!) {
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        
        task.resume()
    }
    
}

