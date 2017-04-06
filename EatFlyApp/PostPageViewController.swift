//
//  PostPageViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello (i7240992) on 05/04/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class PostPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    var postID : String?
    let ref = FIRDatabase.database().reference()
    var posts = [Post]()
    var user = [User]()
    let testRecipe = ["1 (9 5/8 ounce) package pork sausage","8 eggs", "1⁄4 cup parmesan cheese, grated", "1⁄4 teaspoon salt", "2 green onions, thinly sliced"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveUser()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveUser()
        print(posts)
        print(user)
        
        profileImageView.downloadImage(from: self.user[0].imgPath!)
        titleLbl.text = posts[0].title
        navigationItem.title = posts[0].title
        userLbl.text = user[0].fullName
        dateLbl.text = posts[0].date
        descriptionLbl.text = posts[0].desc
        postImageView.downloadImage(from: self.posts[0].pathToImage!)
        
    }
    
    func fetchPost(){
        
        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            
            let postsSnap = snap.value as! [String : AnyObject]
            self.posts.removeAll()
            
            for (_,post) in postsSnap {
                if let postsID = post["postID"] as? String {
                    
                    if self.postID == postsID {
                        let posst = Post()
                        if let author = post["author"] as? String, let likes = post["likes"] as? Int, let title = post["title"] as? String, let description = post["description"] as? String, let date = post["date"] as? String, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String, let userID = post["userID"] as? String {
                            
                            posst.author = author
                            posst.likes = likes
                            posst.title = title
                            posst.desc = description
                            posst.date = date
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
                    
                    
                    //self.collectionView.reloadData()
                }
            }
        })
        
        
    }
    
    func retrieveUser(){
       
        fetchPost()
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            self.user.removeAll()
            
            for (_, value) in users {
                //print(value)
                if let uid = self.posts[0].userID {
                    
                    let userToShow = User()
                    if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String, let userID = value["uid"] as? String {
                        if userID == uid {
                        
                            userToShow.fullName = fullName
                            userToShow.imgPath = imagePath
                            userToShow.userID = uid
                        
                            self.user.append(userToShow)
                        }
                    }
                    
                }
                
            }
            //self.FeedCollectionView.reloadData()
            
        })
        
        ref.removeAllObservers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return testRecipe.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        
        cell.textLabel?.text = testRecipe[indexPath.row]
        
       
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }// end didSelectRow function





}
