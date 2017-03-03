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
    var userAddedItems = [String]()
    var BCfromDB = [String]()
    var shoppingList = [Item]()
    var ref: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return shoppingList.count
    }
    
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        

        cell.textLabel?.text = shoppingList[indexPath.row].itemName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
        let deletedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
    
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let uid = FIRAuth.auth()!.currentUser!.uid
            ref = FIRDatabase.database().reference()
            //let key = ref.child("users").child("barcode").key
            
            
            ref.child("users").child(uid).child("itemsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                
                
                                
                            if let hasItem = snapshot.value as? [String : AnyObject] {
                                for (key, value) in hasItem {
                                    
                                    print(listDetail.count)
                                    print(listDetail[indexPath.row].barcode)
                                    print(value)
                                    if value as! String == listDetail[indexPath.row].barcode {
                                        
                
                                        self.ref.child("users").child(uid).child("itemsList/\(key)").removeValue()
                                        listDetail.remove(at: indexPath.row)
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
    
        let selectedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
    
        if selectedRow.accessoryType == UITableViewCellAccessoryType.none{
            selectedRow.accessoryType = UITableViewCellAccessoryType.checkmark
            selectedRow.tintColor = UIColor.green
        }
    
        else{
            selectedRow.accessoryType = UITableViewCellAccessoryType.none
    
        }//end if/else statement
    }// end didSelectRow function
    
    
    @IBAction func addPressed(_ sender: Any) {
        
        if (input.text != ""){
            let newItem = input.text
            userAddedItems.append(newItem!)
            input.resignFirstResponder()
            input.text = ""
            tableView.reloadData()
        }
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        getItemDetails()
        tableView.reloadData()
        print(shoppingList)
    }
    
    
    func getItemDetails() {
        
        getUsersItems()
        
        ref = FIRDatabase.database().reference()
        
        ref.child("items").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let itemsSnap = snapshot.value as! [String : AnyObject]
            
            
            
            for (_,value) in itemsSnap {
                
                
                
                let itemData = Item()
                if let itemName = value["itemName"] as? String, let barcode = value["barcode"] as? String, let price = value["price"] as? String {
                    itemData.itemName = itemName
                    itemData.barcode = barcode
                    itemData.price = price
                    if self.BCfromDB.count != 0 {
                        for i in 0...self.BCfromDB.count-1 {
                            if (itemData.barcode == self.BCfromDB[i]){
                                
                                self.shoppingList.append(itemData)
                            }
                        }
                    
                    }
                    
                }
                
                
                
            }
            
        })
        ref.removeAllObservers()
        tableView.reloadData()
    }

    //let itemsList = ["itemsList/\(key)" : self.filteredItems[indexPath.row].barcode]
    
    //ref.child("users").child(uid).updateChildValues(itemsList)

 
    func getUsersItems() {
        let uid = FIRAuth.auth()!.currentUser!.uid
        ref = FIRDatabase.database().reference()
        let key = ref.child("users").child("barcode").key
        
        ref.child("users").child(uid).child("itemsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            print(snapshot.value as Any)
            if let itemsSnap = snapshot.value as? [String : AnyObject] {
            self.BCfromDB.removeAll()
            
            
            for (_,value) in itemsSnap {
                
                // Error here: fatal error: unexpectedly found nil while unwrapping an Optional value
                let barcode = value["barcode"] as! String
                
                self.BCfromDB.append(barcode)
                
                    
                
                }
                
                
            }
            
        })
        ref.removeAllObservers()
    }
 
   
    
 
    
    
    
  
    
    
    
    


}
