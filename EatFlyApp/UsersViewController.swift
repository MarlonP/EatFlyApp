//
//  UsersViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 23/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    var user = [User]()
    var usersNames = [String]()
    var filteredData = [String]()
    var filteredUsers = [User]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    
        
        self.hideKeyboardWhenTappedAround()
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
        self.tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.layer.borderColor = UIColor.marlonBlue().cgColor
        searchController.searchBar.layer.borderWidth = 5
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor.marlonBlue()
        
    
        
        searchController.searchBar.placeholder = ""
        
         definesPresentationContext = true
        
        

        
        NotificationCenter.default.addObserver(self, selector: #selector(notifyMethod), name: NSNotification.Name(rawValue: FollowNotificationKey), object: nil)
        self.tableView.tableFooterView = UIView()
        
        retrieveUsers()

    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        
        
        self.filteredData.removeAll(keepingCapacity: false)
        filteredUsers.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (self.usersNames as NSArray).filtered(using: searchPredicate)
        
        print(array)
        
        self.filteredData = array as! [String]
        
        for users in user{
            for filteredItem in filteredData{
                if users.fullName == filteredItem {
                    filteredUsers.append(users)
                }
            }
            
        }
        print(filteredUsers)
        
        
        self.tableView.reloadData()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let yourBackImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationController?.navigationBar.backItem?.title = ""
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
                            self.usersNames.append(fullName)
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
        
        if self.searchController.isActive{
            cell.nameLbl.text = self.filteredUsers[indexPath.row].fullName
            cell.userID = self.filteredUsers[indexPath.row].userID
            cell.userImage.downloadImage(from: self.filteredUsers[indexPath.row].imgPath!)
        }else{
            cell.nameLbl.text = self.user[indexPath.row].fullName
            cell.userID = self.user[indexPath.row].userID
            cell.userImage.downloadImage(from: self.user[indexPath.row].imgPath!)
            
        }
        
        cell.followBtn.setImage(UIImage(named: "follow"), for: .normal)
        cell.checkFollowing()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive{
            return filteredUsers.count
        }else{
            return user.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.searchController.isActive{
            userPageID = self.filteredUsers[indexPath.row].userID
            performSegue(withIdentifier: "goUserProfileSegue", sender: self)
        }else{
            userPageID = self.user[indexPath.row].userID
            performSegue(withIdentifier: "goUserProfileSegue", sender: self)
        }
        
        

    }
    
  

    
    

}
