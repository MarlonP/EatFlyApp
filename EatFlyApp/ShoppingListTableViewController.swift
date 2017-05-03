//
//  ShoppingListTableViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello (i7240992) on 22/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

var listDetail = [Item]()

class ShoppingListTableViewController: UITableViewController {
    @IBOutlet weak var input: UITextField!
    var userAddedItems = [ManualAddedItem]()
    var BCfromDB = [String]()
    var shoppingList = [Item]()
    var SLCompletion = [Bool]()
    var ref: FIRDatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        getItemDetails()
        getUsersManualItems()
        print(userAddedItems)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        getItemDetails()
        getUsersManualItems()
        print(userAddedItems)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            
            return userAddedItems.count
            
        }
        return shoppingList.count
    }
    
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0 {
            
            if SLCompletion[indexPath.row] == true {
            
                cell.accessoryType = .checkmark
            }else{
            
                cell.accessoryType = .none
            }
            
            cell.textLabel?.text = shoppingList[indexPath.row].itemName
        
        } else if indexPath.section == 1 {
            
            if userAddedItems[indexPath.row].completion == true {
                
                cell.accessoryType = .checkmark
            }else{
                
                cell.accessoryType = .none
            }
            
            cell.textLabel?.text = userAddedItems[indexPath.row].itemName
            
            
        }

        
        
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 1 {
            if userAddedItems.count == 0 {
                return nil
            } else {
                return "Non-Scannable"
            }
            
        }
        if section == 0 {
            if shoppingList.count != 0 {
                return "Scannable"
            } else {
                return nil
            }
        }
        
        return nil
    }
    //Delete cell function NEED TO FIX AND INCLUDE THE MANUAL ADD AS WELL!!!!
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
        let deletedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
    
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let uid = FIRAuth.auth()!.currentUser!.uid
            ref = FIRDatabase.database().reference()
            //let key = ref.child("users").child("barcode").key
            
            
            ref.child("users").child(uid).child("itemsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                
                
                                
                            if let hasItem = snapshot.value as? [String : AnyObject] {
                                for (key, value) in hasItem {
                                    
//                                    print(self.shoppingList.count)
//                                    print(self.shoppingList[indexPath.row].barcode)
//                                    print(value)
                                    let BC = value["barcode"]
                                    
                                    if BC as! String == self.shoppingList[indexPath.row].barcode {
                                        
                
                                        self.ref.child("users").child(uid).child("itemsList/\(key)").removeValue()
                                        self.shoppingList.remove(at: indexPath.row)
                                        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                                        deletedRow.accessoryType = UITableViewCellAccessoryType.none
                
                
                
                                    }
                                }
                
                            }
                            
                })
            
            
            
            tableView.reloadData()
    
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("itemsList").childByAutoId().key
        
      
        if indexPath.section == 0 {
        ref.child("users").child(uid).child("itemsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let completed = snapshot.value as? [String : AnyObject] {
                for (_, value) in completed {
                    let BC = value["barcode"]
                    if BC as! String == self.shoppingList[indexPath.row].barcode {
                    
                        let completion = value["completion"] as! Bool
                        let id = value["listID"] as! String
                    
                        if completion == true {
                            
                            let completionVal: [String : Any] = ["completion" : false]
                            ref.child("users").child(uid).child("itemsList").child(id).updateChildValues(completionVal)
                            self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                            
                        }else if completion == false{
                            
                            let completionVal: [String : Any] = ["completion" : true]
                            ref.child("users").child(uid).child("itemsList").child(id).updateChildValues(completionVal)
                            self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        }
                    
                    }
                }
            }
            
        })
        ref.removeAllObservers()
        }
        
        if indexPath.section == 1 {
            ref.child("users").child(uid).child("manuallyAddedItems").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                
                
                if let completed = snapshot.value as? [String : AnyObject] {
                    for (_, value) in completed {
                            
                            let completion = value["completion"] as! Bool
                            let id = value["listID"] as! String
                            
                            if completion == true {
                                
                                let completionVal: [String : Any] = ["completion" : false]
                                ref.child("users").child(uid).child("manuallyAddedItems").child(id).updateChildValues(completionVal)
                                self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                                
                            }else if completion == false{
                                
                                let completionVal: [String : Any] = ["completion" : true]
                                ref.child("users").child(uid).child("manuallyAddedItems").child(id).updateChildValues(completionVal)
                                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                            }
                            
                        
                    }
                }
                
            })
            ref.removeAllObservers()
        }
    
    }// end didSelectRow function
    
    
    @IBAction func addPressed(_ sender: Any) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").child(uid).child("itemsList").childByAutoId().key
        
        if (input.text != ""){
            let newItem = ManualAddedItem()
            
            let newItemName = input.text
            let completion = false
            
            newItem.itemName = newItemName
            newItem.completion = completion
            newItem.id = newItemName
                
            userAddedItems.append(newItem)
            
            let item: [String : Any] = ["name" : newItemName!, "completion" : completion, "listID" : key]
            let itemsList = ["\(key)" : item]
            
            ref.child("users").child(uid).child("manuallyAddedItems").updateChildValues(itemsList)
            
            input.resignFirstResponder()
            input.text = ""
            tableView.reloadData()
        }
        
        
    }
    
    func getUsersManualItems() {
        let uid = FIRAuth.auth()!.currentUser!.uid
        ref = FIRDatabase.database().reference()
        //let key = ref.child("users").child("barcode").key
        
        ref.child("users").child(uid).child("manuallyAddedItems").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let itemsSnap = snapshot.value as? [String : AnyObject] {
                
                self.userAddedItems.removeAll()
                
                
                for (_,value) in itemsSnap {
                    
                    let manualItemData = ManualAddedItem()
                    if let itemName = value["name"] as? String, let completion = value["completion"] as? Bool, let id = value["listID"] as? String {
                        
                        manualItemData.itemName = itemName
                        manualItemData.completion = completion
                        manualItemData.id = id
                        
                        print(completion)
                    
                        self.userAddedItems.append(manualItemData)
                    }
                }
            }
            self.tableView.reloadData()
        })
        ref.removeAllObservers()
    }
    

    
    
    func getItemDetails() {
        
        getUsersItems()
        
        ref = FIRDatabase.database().reference()
        
        ref.child("items").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let itemsSnap = snapshot.value as! [String : AnyObject]
            self.shoppingList.removeAll()
            
            for (_,value) in itemsSnap {
                
                let itemData = Item()
                if let itemName = value["itemName"] as? String, let barcode = value["barcode"] as? String, let price = value["price"] as? String{
                    itemData.itemName = itemName
                    itemData.barcode = barcode
                    itemData.price = price
                   
                    
                    if self.BCfromDB.count != 0 {
                        for i in 0...self.BCfromDB.count-1 {
                            if (itemData.barcode == self.BCfromDB[i]){
                                
                                self.shoppingList.append(itemData)
                            }
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                }
                
                
                
            }
            
        })
        ref.removeAllObservers()
        
    }


    func getUsersItems() {
        let uid = FIRAuth.auth()!.currentUser!.uid
        ref = FIRDatabase.database().reference()
        //let key = ref.child("users").child("barcode").key
        
        ref.child("users").child(uid).child("itemsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let itemsSnap = snapshot.value as? [String : AnyObject] {

            self.BCfromDB.removeAll()
            
            
            for (_,value) in itemsSnap {
                
                // Error here: fatal error: unexpectedly found nil while unwrapping an Optional value
                if let barcode = value["barcode"] as? String, let completion = value["completion"] as? Bool{
                
                self.BCfromDB.append(barcode)
                self.SLCompletion.append(completion)
                }
                    
                
                }
                
                
            }
            
        })
        ref.removeAllObservers()
    }
 
   



}
