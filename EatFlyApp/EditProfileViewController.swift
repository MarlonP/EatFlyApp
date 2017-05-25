//
//  EditProfileViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 19/04/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

let ProfileNotificationKey = "com.mp.profileNotificationKey"

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var BioTextField: UITextField!
    
    var user = [User]()
    
    let picker = UIImagePickerController()
    var userStorage: FIRStorageReference!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify), name: NSNotification.Name(rawValue: myNotificationKey), object: nil)
        
        picker.delegate = self
        
        let storage = FIRStorage.storage().reference(forURL: "gs://eatfly-70803.appspot.com")
        
        userStorage = storage.child("users")
        ref = FIRDatabase.database().reference()
        
        retrieveUsers()
        
    }
    
    func doThisWhenNotify() {
        
    }
    

    @IBAction func editPressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImageView.image = image
            
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savePressed(_ sender: Any) {
        updateUsersProfile()
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: myNotificationKey), object: nil)
        
        _ = navigationController?.popViewController(animated: true)
        
        
    }
    
    func updateUsersProfile(){
        //check to see if the user is logged in
        if let userID = FIRAuth.auth()?.currentUser?.uid{
            //create an access point for the Firebase storage
            let storageItem = self.userStorage.child("\(userID).jpg")
            //get the image uploaded from photo library
            guard let image = profileImageView.image else {return}
            if let newImage = UIImageJPEGRepresentation(image, 0.5){
                //upload to firebase storage
                storageItem.put(newImage, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    storageItem.downloadURL(completion: { (url, error) in
                        if error != nil{
                            print(error!)
                            return
                        }
                        if let profilePhotoURL = url?.absoluteString{
                            guard let newDisplayName = self.displayNameTextField.text else {return}
                            guard let newBioText = self.BioTextField.text else {return}
                            
                            let newValuesForProfile: [String : Any] = ["uid" : userID,
                                                            "full name" : newDisplayName,
                                                            "bio" : newBioText,
                                                            "urlToImage" : profilePhotoURL]
                            
                            //update the firebase database for that user
                            self.ref.child("users").child(userID).updateChildValues(newValuesForProfile, withCompletionBlock: { (error, ref) in
                                if error != nil{
                                    print(error!)
                                    return
                                }
                                print("Profile Successfully Update")
                            })
                            
                        }
                    })
                })
                
            }
        }
    }
    
    

    
    func retrieveUsers(){
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            self.user.removeAll()
            
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid == FIRAuth.auth()?.currentUser!.uid{
                        let userToShow = User()
                        if let fullName = value["full name"] as? String, let bio = value["bio"] as? String, let imagePath = value["urlToImage"] as? String {
                            userToShow.fullName = fullName
                            userToShow.bio = bio
                            userToShow.imgPath = imagePath
                            userToShow.userID = uid
                            
                            self.user.append(userToShow)
                            
                            self.displayNameTextField.text = fullName
                            self.BioTextField.text = bio
                            self.profileImageView.downloadImage(from: imagePath)
                        }
                    }
                }
            }
            
        })
        
        ref.removeAllObservers()
    }
}
