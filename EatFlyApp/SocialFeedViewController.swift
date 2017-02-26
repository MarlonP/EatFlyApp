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
    var following = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchPosts()
    }
    
    
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
                                            if let author = post["author"] as? String, let likes = post["likes"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String {
                                                
                                                posst.author = author
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
        
        for person in self.posts[indexPath.row].peopleWhoLike {
            if person == FIRAuth.auth()!.currentUser!.uid {
                cell.likeBtn.isHidden = true
                cell.unlikeBtn.isHidden = false
                break
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Code for when cell is selected
    }
    
}
