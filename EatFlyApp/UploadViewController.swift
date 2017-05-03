//
//  UploadViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 24/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

var uploadRecipe = [RecipeItem]()

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate{
    
    
    @IBOutlet weak var postBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var previewImage: UIImageView!
    //@IBOutlet weak var selectBtn: UIButton!
    
    var picker = UIImagePickerController()
    var array = ["Photo/Video", "Recipe", "Instructions"]
    
    var recipeDone = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        picker.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(doSomethingAfterNotified1),
                                               name: NSNotification.Name(rawValue: myNotificationKey1),
                                               object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(whenNotify), name: NSNotification.Name(rawValue: FeedNotificationKey), object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(uploadRecipe)
    }
    
    func doSomethingAfterNotified1() {
        if recipeDone == false {
            recipeDone = true
        }
        
        tableView.reloadData()
        
        
    }
    func whenNotify(){
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (descriptionTextView.text == "Description..."){
            descriptionTextView.textColor = .black
            descriptionTextView.text = ""
        }
        //descriptionTextView.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (descriptionTextView.text == ""){
            descriptionTextView.text = "Description..."
            descriptionTextView.textColor = .lightGray
        }
        //descriptionTextView.resignFirstResponder()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.previewImage.image = image
            //selectBtn.isHidden = true
            //postBtn.isHidden = false
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }

    //@IBAction func selectPressed(_ sender: Any) {
        
        //picker.allowsEditing = true
        //picker.sourceType = .photoLibrary
        //self.present(picker, animated: true, completion: nil)
    //}

    @IBAction func postPressed(_ sender: Any) {
        AppDelegate.instance().showActivityIndicator()
        
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference(forURL: "gs://eatfly-70803.appspot.com")
        
        let key = ref.child("posts").childByAutoId().key
        let imageRef = storage.child("posts").child(uid).child("\(key).jpg")
        
        let data = UIImageJPEGRepresentation(self.previewImage.image!, 0.6)
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        let dateToday = "\(day!).\(month!).\(year!)"
   
        let uploadTask = imageRef.put(data!, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                AppDelegate.instance().dismissActivityIndicator()
                return
            }
            
            imageRef.downloadURL(completion: { (url, error) in
                if let url = url {
                    let feed = ["userID" : uid,
                                "pathToImage" : url.absoluteString,
                                "likes" : 0,
                                "author" : FIRAuth.auth()!.currentUser!.displayName!,
                                "title" : self.titleTextField.text as String!,
                                "description" : self.descriptionTextView.text as String!,
                                "date" : dateToday,
                                "postID" : key] as [String : Any]
                    
                    let postFeed = ["\(key)" : feed]
                    
                    ref.child("posts").updateChildValues(postFeed)
                    
                    
                    
                    for i in 0...uploadRecipe.count-1{
                        let key1 = ref.child("posts").childByAutoId().key
                        let recipe = ["itemName" : uploadRecipe[i].itemName, "amount" : uploadRecipe[i].amount, "fraction" : uploadRecipe[i].fraction, "RID" : key1] as [String : Any]
                        
                        let recipeFeed = ["\(key1)" : recipe]
                        
                        ref.child("posts").child(key).child("recipe").updateChildValues(recipeFeed)
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: FeedNotificationKey), object: nil)
                    
                    uploadRecipe.removeAll()
                    recipe.removeAll()
                    AppDelegate.instance().dismissActivityIndicator()
                    
                    
                    //This is the problem of going back to the log out
                    _ = self.navigationController?.popViewController(animated: true)
                    
                    
                }
            })
        }
        
        uploadTask.resume()
        
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return array.count
    }
    
    
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        
        cell.textLabel?.text = array[indexPath.row]
        if indexPath.row == 1 {
            if recipeDone == true{
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        
        if indexPath.row == 0 {
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
            
            
            let containerView = UIView(frame: CGRect(x:0,y:0,width:320,height:500))
            let imageView = UIImageView()
            
            if let image = UIImage(named: "a_image") {
                let ratio = image.size.width / image.size.height
                if containerView.frame.width > containerView.frame.height {
                    let newHeight = containerView.frame.width / ratio
                    imageView.frame.size = CGSize(width: containerView.frame.width, height: newHeight)
                }
                else{
                    let newWidth = containerView.frame.height * ratio
                    imageView.frame.size = CGSize(width: newWidth, height: containerView.frame.height)
                }
            }
        }
        
        if indexPath.row == 1 {
            performSegue(withIdentifier: "recipeView", sender: nil)
        }
        
        
    }

    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
