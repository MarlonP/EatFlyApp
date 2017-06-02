//
//  ShoppingListCell.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 14/05/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import IBAnimatable
import Firebase

class ShoppingListCell: UITableViewCell {

    @IBOutlet weak var checkBox: AnimatableCheckBox!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemDesc: UILabel!
    @IBOutlet weak var price: UILabel!
    
    var itemCompletion: Bool!
    var indexPath: NSIndexPath!
    var SLListID: String!
    var MLListID: String!
    

    @IBAction func checkBoxPressed(_ sender: Any) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("itemsList").childByAutoId().key
        
        
        if self.indexPath.section == 0 {
            ref.child("users").child(uid).child("itemsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                
                
                if let completed = snapshot.value as? [String : AnyObject] {
                    for (_, value) in completed {
                        let listID = value["listID"]
                        if listID as! String == self.SLListID {
                            
                            let completion = value["completion"] as! Bool
                            let id = value["listID"] as! String
                            
                            if completion == true {
                                
                                let completionVal: [String : Any] = ["completion" : false]
                                ref.child("users").child(uid).child("itemsList").child(id).updateChildValues(completionVal)
                                
                                self.checkBox.checked = false
                                
                            }else if completion == false{
                                
                                let completionVal: [String : Any] = ["completion" : true]
                                ref.child("users").child(uid).child("itemsList").child(id).updateChildValues(completionVal)
                                self.checkBox.checked = true
                            }
                            
                        }
                    }
                }
                
            })
            ref.removeAllObservers()
        }
        
        if self.indexPath.section == 1 {
            ref.child("users").child(uid).child("manuallyAddedItems").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                
                
                if let completed = snapshot.value as? [String : AnyObject] {
                    for (_, value) in completed {
                        let listID = value["listID"]
                        print(listID)
                        print(self.MLListID)
                        if listID as! String == self.MLListID {
                        
                        let completion = value["completion"] as! Bool
                        let id = value["listID"] as! String
                        
                        if completion == true {
                            
                            let completionVal: [String : Any] = ["completion" : false]
                            ref.child("users").child(uid).child("manuallyAddedItems").child(id).updateChildValues(completionVal)
                            self.checkBox.checked = false
                            
                        }else if completion == false{
                            
                            let completionVal: [String : Any] = ["completion" : true]
                            ref.child("users").child(uid).child("manuallyAddedItems").child(id).updateChildValues(completionVal)
                            self.checkBox.checked = true
                        }
                        
                        }
                    }
                }
                
            })
            ref.removeAllObservers()
        }
        
        }
    
    func checkCompletion(){
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("itemsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let completed = snapshot.value as? [String : AnyObject] {
                for (_, value) in completed {
                    let listID = value["listID"]
                    if listID as! String == self.SLListID {
                        
                        let completion = value["completion"] as! Bool
                        let id = value["listID"] as! String
                        
                        if completion == true {
                            
                            
                            self.checkBox.checked = true
                            
                        }else if completion == false{
                            
                            self.checkBox.checked = false
                        }
                        
                    }
                }
            }
            
        })
        ref.removeAllObservers()
    }
    


}
