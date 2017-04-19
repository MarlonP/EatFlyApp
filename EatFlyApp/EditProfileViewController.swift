//
//  EditProfileViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 19/04/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var BioTextField: UITextField!
    
    var user = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveUsers()
        print(user)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveUsers()
        print(user)
        profileImageView.downloadImage(from: self.user[0].imgPath!)

    }

    @IBAction func editPressed(_ sender: Any) {
    }

    @IBAction func savePressed(_ sender: Any) {
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
            
        })
        
        ref.removeAllObservers()
    }
}
