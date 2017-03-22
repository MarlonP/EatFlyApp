//
//  userPageViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 02/03/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class UserPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var followingLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var postsLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let ref = FIRDatabase.database().reference()
    
    var user = [User]()
    var following = [String]()
    var followers = [String]()
    var posts = [Post]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveUser()
        getFollowers()
        getFollowing()
        fetchPosts()
      
        
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveUser()
        getFollowers()
        getFollowing()
        fetchPosts()
        
        nameLbl.text = self.user[0].fullName
        profileImageView.downloadImage(from: self.user[0].imgPath!)
        followingLbl.text = "\(following.count)"
        followersLbl.text = "\(followers.count)"
        postsLbl.text = "\(posts.count)"
    }
    
    func retrieveUser(){
        
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            self.user.removeAll()
            
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid == FIRAuth.auth()?.currentUser!.uid{
                        let userToShow = User()
                        if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String {
                            userToShow.fullName = fullName
                            userToShow.imgPath = imagePath
                            userToShow.userID = uid
                            
                            self.user.append(userToShow)
                        }
                    }
                }
            }
        
        })
        
        ref.removeAllObservers()
    }
    
    func getFollowers(){
        let uid = FIRAuth.auth()!.currentUser!.uid
        
        ref.child("users").child(uid).child("followers").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let Snap = snapshot.value as! [String : AnyObject]
            self.followers.removeAll()
            
            
            for (_,value) in Snap {
                if let follower = value as? String {
                    
                    self.followers.append(follower)
                }
                
            }
            
            
            
        })
        
    }
    
    func getFollowing(){
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let Snaps = snapshot.value as! [String : AnyObject]
            self.following.removeAll()
            
            
            for (_,value) in Snaps {
                if let usersFollowing = value as? String {
                    
                    self.following.append(usersFollowing)
                }
                
            }
            
            
            
        })

        
    }
    
    func fetchPosts(){
        let uid = FIRAuth.auth()!.currentUser!.uid
        
        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            
            let postsSnap = snap.value as! [String : AnyObject]
            self.posts.removeAll()
            
            for (_,post) in postsSnap {
                if let userID = post["userID"] as? String {
                    
                        if uid == userID {
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
                    
                    
                    self.collectionView.reloadData()
                }
            }
        })
        
        
    }


    @IBAction func logOutPressed(_ sender: Any) {
        
        try! FIRAuth.auth()?.signOut()
        
    }

    @IBAction func followPressed(_ sender: Any) {
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! userPostCell
        
    
        print(self.posts[indexPath.row].pathToImage)
        
        cell.imageView.downloadImage(from: self.posts[indexPath.row].pathToImage)
   
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Code for when cell is selected
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
