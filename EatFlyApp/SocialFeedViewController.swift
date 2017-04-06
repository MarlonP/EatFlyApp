//
//  SocialFeedViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 03/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class SocialFeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var FeedCollectionView: UICollectionView!
    
    var posts = [Post]()
    var user = [User]()
    var following = [String]()
    var selectedPostID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchPosts()
        retrieveUsers()
        print(user)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        fetchPosts()
//        retrieveUsers()
//        print(user)
//    }
 
    
    
    func fetchPosts(){
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String : AnyObject]
            
            for (_,value) in users {
                if let uid = value["uid"] as? String {
                    if uid == FIRAuth.auth()?.currentUser?.uid {
                        if let followingUsers = value["following"] as? [String : String]{
                            for (_,user) in followingUsers{
                                self.following.append(user)
                            }
                        }
                        self.following.append(FIRAuth.auth()!.currentUser!.uid)
                        
                        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
                            
                            
                            let postsSnap = snap.value as! [String : AnyObject]
                            
                            for (_,post) in postsSnap {
                                if let userID = post["userID"] as? String {
                                    for each in self.following {
                                        if each == userID {
                                            let posst = Post()
                                            if let author = post["author"] as? String, let title = post["title"] as? String, let date = post["date"] as? String, let likes = post["likes"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String {
                                                
                                                posst.author = author
                                                posst.title = title
                                                posst.date = date
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
                                    }
                                    
                                    self.FeedCollectionView.reloadData()
                                }
                            }
                        })
                    }
                }
            }
            
        })
        ref.removeAllObservers()
    }
    
    func retrieveUsers(){
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            self.user.removeAll()
            
            for (_, value) in users {
                print(value)
                if let uid = value["uid"] as? String {
                    
                        let userToShow = User()
                        if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String {
                            userToShow.fullName = fullName
                            userToShow.imgPath = imagePath
                            userToShow.userID = uid
                            
                            self.user.append(userToShow)
                        }
                    
                }
                
            }
            self.FeedCollectionView.reloadData()
            
        })
        
        ref.removeAllObservers()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        cell.authorLabel.text = self.posts[indexPath.row].author
        cell.likeLabel.text = "\(self.posts[indexPath.row].likes!) Likes"
        cell.postID = self.posts[indexPath.row].postID
        cell.titleLabel.text = self.posts[indexPath.row].title
        cell.dateLabel.text = self.posts[indexPath.row].date
        
        for person in self.posts[indexPath.row].peopleWhoLike {
            if person == FIRAuth.auth()!.currentUser!.uid {
                cell.likeBtn.isHidden = true
                cell.unlikeBtn.isHidden = false
                break
            }
        }
        
        for i in 0...user.count-1 {
            print(i)
            if posts[indexPath.row].userID == user[i].userID {
                print(user[i].imgPath)
                cell.imageView.downloadImage(from: user[i].imgPath)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Row \(indexPath.row)selected")
        selectedPostID = self.posts[indexPath.row].postID
        
        print(self.posts[indexPath.row].postID)
        
        performSegue(withIdentifier: "postPage", sender: self)
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == "postPage") {
            let vc = segue.destination as! PostPageViewController
            vc.postID = selectedPostID
        }
    }
    
}
