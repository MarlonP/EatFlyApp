//
//  UsersViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 23/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var user = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notifyMethod), name: NSNotification.Name(rawValue: FollowNotificationKey), object: nil)
        self.tableView.tableFooterView = UIView()
        
        retrieveUsers()

    }
    
    func notifyMethod(){
        print("done")
        tableView.reloadData()
    }
    
    func retrieveUsers(){
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            self.user.removeAll()
            
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid != FIRAuth.auth()?.currentUser!.uid{
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
            
            self.tableView.reloadData()
        })
        
        ref.removeAllObservers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        cell.selectionStyle = .none
        cell.nameLbl.text = self.user[indexPath.row].fullName
        cell.userID = self.user[indexPath.row].userID
        cell.userImage.downloadImage(from: self.user[indexPath.row].imgPath!)
        cell.followBtn.setImage(UIImage(named: "username"), for: .normal)
        cell.checkFollowing()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        userPageID = self.user[indexPath.row].userID
        performSegue(withIdentifier: "goUserProfileSegue", sender: self)
        

    }
    
  

    
    

}
