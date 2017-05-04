//
//  PostPageViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello (i7240992) on 05/04/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

var selectedPostID : String!

class PostPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var barBtn: UIBarButtonItem!
    
    var postID : String!
    let ref = FIRDatabase.database().reference()
    var posts = [Post]()
    var user = [User]()
    var postRecipe = [RecipeItem]()
    
    let uid = FIRAuth.auth()!.currentUser!.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        
        barBtn = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserPageViewController.buttonMethod))

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        retrieveUser()
       
        
        
    }
    
    func buttonMethod() {
        
        let alertController = UIAlertController(title: nil, message: "Takes the appearance of the bottom bar if specified; otherwise, same as UIActionSheetStyleDefault.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let editAction = UIAlertAction(title: "Edit Post", style: .default) { action in
            self.performSegue(withIdentifier: "editPostSegue", sender: nil)
        }
        alertController.addAction(editAction)
        
        let deleteAction = UIAlertAction(title: "Delete Post", style: .destructive) { action in
            let DeleteAlertController = UIAlertController(title: "Are You Sure?", message: "Press delete if you still want to delete this post.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                // ...
            }
            DeleteAlertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                self.ref.child("posts").child(self.posts[0].postID).removeValue()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "feedVC")
                self.present(vc, animated: true, completion: nil)
                
            }
            DeleteAlertController.addAction(OKAction)
            
            self.present(DeleteAlertController, animated: true) {
                // ...
            }
        }
        alertController.addAction(deleteAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
        
    }
    
    func fetchPost(){
        
        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            
            let postsSnap = snap.value as! [String : AnyObject]
            self.posts.removeAll()
            
            for (_,post) in postsSnap {
                if let postsID = post["postID"] as? String {
                    
                  
                    if selectedPostID == postsID {
                        
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
                            print(posst)
                            self.posts.append(posst)
                        }
                        
                        self.ref.child("posts").child(postsID).child("recipe").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
                            let recipeSnap = snap.value as! [String : AnyObject]
                            self.postRecipe.removeAll()
                            
                             for (_,recipe1) in recipeSnap {
                                let rec = RecipeItem()
                                
                                if let itemName = recipe1["itemName"] as? String, let amount = recipe1["amount"] as? String, let fraction = recipe1["fraction"] as? String {
                                    
                                    rec.itemName = itemName
                                    rec.amount = amount
                                    rec.fraction = fraction
                                    
                                    self.postRecipe.append(rec)
                                    
                                }
                               self.tableView.reloadData()
                            }

                            
                            
                        })
                        
                    }
                    
                    
                    //self.collectionView.reloadData()
                }
            }
        })
        
        ref.removeAllObservers()
    }
    
    
    func setData(){
        profileImageView.downloadImage(from: self.user[0].imgPath!)
        titleLbl.text = posts[0].title
        navigationItem.title = posts[0].title
        userLbl.text = user[0].fullName
        dateLbl.text = posts[0].date
        descriptionLbl.text = posts[0].desc
        postImageView.downloadImage(from: self.posts[0].pathToImage!)
        
        if uid != posts[0].userID {
            navigationItem.rightBarButtonItems = []
        }else{
            navigationItem.rightBarButtonItems = [barBtn]
        }
    }

    func retrieveUser(){
       
        fetchPost()
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            self.user.removeAll()
            
            for (_, value) in users {
                
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
            self.setData()
        })
        
        ref.removeAllObservers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postRecipe.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let pointSize: CGFloat = 14.0
        let string = "\(postRecipe[indexPath.row].amount!) \(postRecipe[indexPath.row].itemName!)"
        
        let attribString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: pointSize), NSForegroundColorAttributeName: UIColor.black])
        attribString.addAttributes([NSFontAttributeName: UIFont.fractionFont(ofSize: pointSize)], range: (string as NSString).range(of: postRecipe[indexPath.row].fraction!))
        cell.textLabel?.attributedText = attribString
        cell.textLabel?.sizeToFit()

        
       
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }// end didSelectRow function
    
    
    @IBAction func addToShoppingPressed(_ sender: Any) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        
        if (postRecipe.count != 0){
            for i in 0...postRecipe.count-1{
                let key = ref.child("users").child(uid).child("itemsList").childByAutoId().key
            
                let newItem = ManualAddedItem()
            
                let newItemName = postRecipe[i].itemName
                let completion = false
            
                newItem.itemName = newItemName
                newItem.completion = completion
                newItem.id = newItemName
            
                let item: [String : Any] = ["name" : newItemName!, "completion" : completion, "listID" : key]
                let itemsList = ["\(key)" : item]
            
                ref.child("users").child(uid).child("manuallyAddedItems").updateChildValues(itemsList)
                
                let alertController = UIAlertController(title: "Done", message: "Recipe added to your shopping list", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
            
           
            
            }
        }
    }





}
