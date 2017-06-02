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
var userItems = [shoppingListItem]()

class ShoppingListTableViewController: UITableViewController {
    @IBOutlet weak var input: UITextField!
    var userAddedItems = [ManualAddedItem]()
    var BCfromDB = [String]()
    
    var shoppingList = [Item]()
    
    var SLCompletion = [Bool]()
    var itemListIDs = [String]()
    
    
    
    var ref: FIRDatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.hideKeyboardWhenTappedAround()
      
        
        //getItemDetails()
        observeShoppingList()
        observeUsersManualItems()
        
  
     

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let yourBackImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
      
    }
    
    


    
    @IBAction func locateItemsBtnPressed(_ sender: Any) {
        
        
        
        performSegue(withIdentifier: "locateItemsSegue", sender: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShoppingListCell
       
        
        if indexPath.section == 0 {
            cell.indexPath = indexPath as NSIndexPath
             cell.SLListID = userItems[indexPath.row].listID
            
            cell.checkCompletion()
            
            cell.itemName.text = shoppingList[indexPath.row].itemName
            cell.itemDesc.text = shoppingList[indexPath.row].itemType
            cell.price.text = "£\(shoppingList[indexPath.row].price!)"
        
        } else if indexPath.section == 1 {
            cell.indexPath = indexPath as NSIndexPath
            cell.MLListID = self.userAddedItems[indexPath.row].id
            
            if userAddedItems[indexPath.row].completion == true {
                
                cell.checkBox.checked = true
            }else{
                
                cell.checkBox.checked = false
            }
            
            cell.itemName.text = userAddedItems[indexPath.row].itemName
            cell.itemDesc.text = "Manual"
            cell.price.text = ""
            
            
        }
        
        usersShoppingListItems = shoppingList

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
    
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let view = view as? UITableViewHeaderFooterView {
        
            view.textLabel?.backgroundColor = UIColor.clear
            view.textLabel?.textColor = UIColor.white
        }
    }
    
    //Delete cell function NEED TO FIX AND INCLUDE THE MANUAL ADD AS WELL!!!!
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
        let deletedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        ref = FIRDatabase.database().reference()
    
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            //PROBLEM IS ARRAY IS CHANGING PLACES AND BECAUSE ID'S ARE IN DIFFERENT PLACES ITS DELETING THE WRONG ITEM
            if indexPath.section == 0 {
                
                let listID = userItems[indexPath.row].listID
                
                self.ref.child("users").child(uid).child("itemsList").child(listID!).removeValue()
                
                self.shoppingList.remove(at: indexPath.row)
                userItems.remove(at: indexPath.row)
//                self.BCfromDB.remove(at: indexPath.row)
//                self.SLCompletion.remove(at: indexPath.row)
//                self.itemListIDs.remove(at: indexPath.row)
                
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                  deletedRow.accessoryType = UITableViewCellAccessoryType.none
                
                    
              
                tableView.reloadData()
            }
            
            if indexPath.section == 1 {
                
                if let listID = self.userAddedItems[indexPath.row].id{
                
                    self.ref.child("users").child(uid).child("manuallyAddedItems").child(listID).removeValue()
                
                    //self.userAddedItems.remove(at: indexPath.row)
               
                    //tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    deletedRow.accessoryType = UITableViewCellAccessoryType.none
               
                    tableView.reloadData()
                }
            }
            
            
    
            

    
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

    }// end didSelectRow function
   
    
    @IBAction func addPressed(_ sender: Any) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").child(uid).child("itemsList").childByAutoId().key
        
        if (input.text != ""){
        
            let newItemName = input.text
            let completion = false
        
            let item: [String : Any] = ["name" : newItemName!, "completion" : completion, "listID" : key]
            let itemsList = ["\(key)" : item]
        
            ref.child("users").child(uid).child("manuallyAddedItems").updateChildValues(itemsList)
        
            input.resignFirstResponder()
            input.text = ""
            tableView.reloadData()
        }
        
    }
    
    
    func observeUsersManualItems() {
        let uid = FIRAuth.auth()!.currentUser!.uid
        ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("manuallyAddedItems").observe(.childAdded, with: { (snapshot) in
            
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let manualItemData = ManualAddedItem()
                
                manualItemData.itemName = dictionary["name"] as! String
                manualItemData.completion = dictionary["completion"] as! Bool
                manualItemData.id = dictionary["listID"] as! String

                self.userAddedItems.append(manualItemData)
                
                
            }
            self.tableView.reloadData()
            
        })
        
        ref.child("users").child(uid).child("manuallyAddedItems").observe(.childRemoved, with: { (snapshot) in
            
            
            var manualItemsIndex: Int!
            
            for i in 0...self.userAddedItems.count-1{
                
                
                if self.userAddedItems[i].id == snapshot.key{
                    
                    manualItemsIndex = i
                    
                }
                
            }
            
            self.userAddedItems.remove(at: manualItemsIndex)
            self.tableView.reloadData()
            
        })

        
    }

    
    
    func getItemDetails() {
        
        ref = FIRDatabase.database().reference()
        
        ref.child("items").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let itemsSnap = snapshot.value as! [String : AnyObject]
            self.shoppingList.removeAll()
            
            for (_,value) in itemsSnap {
                
                let itemData = Item()
                if let itemName = value["itemName"] as? String, let itemType = value["itemType"] as? String, let barcode = value["barcode"] as? String, let price = value["price"] as? String, let beaconID = value["beacon"] as? String, let imgPath = value["img"] as? String{
                    itemData.itemName = itemName
                    itemData.itemType = itemType
                    itemData.barcode = barcode
                    itemData.price = price
                    itemData.beaconID = beaconID
                    itemData.img = imgPath
                   
                    
                    if userItems.count != 0 {
                        for item in userItems {
                            if (itemData.barcode == item.barcode){
                                itemData.timestamp = item.timestamp
                                self.shoppingList.append(itemData)
                                
                                
                            }
                        }
                        self.shoppingList.sort(by: { (item1, item2) -> Bool in
                            
                            return (item1.timestamp?.intValue)! < (item2.timestamp?.intValue)!
                        })
                        
                        self.tableView.reloadData()
                    }
                    
                }
                
                
                
            }
            
        })
        ref.removeAllObservers()
        
    }
// sort both arrays with timestamp
    //Both arrays have same timestamps, so should be sorted in the same order
    
    func observeShoppingList(){
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("itemsList").observe(.childAdded, with: { (snapshot) in
            
            let itemData = shoppingListItem()
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                let barcode = dictionary["barcode"] as! String
                let completion = dictionary["completion"] as! Bool
                let listID = dictionary["listID"] as! String
                let timeStamp = dictionary["timestamp"] as! NSNumber
                
//                self.BCfromDB.append(barcode)
//                self.SLCompletion.append(completion)
//                self.itemListIDs.append(listID)
                
                itemData.barcode = barcode
                itemData.completion = completion
                itemData.timestamp = timeStamp
                itemData.listID = listID
                
                //self.tableView.reloadData()
                
                userItems.append(itemData)
                
                
            }
            userItems.sort(by: { (item1, item2) -> Bool in
                    
                    return item1.timestamp.intValue < item2.timestamp.intValue
                })
            self.getItemDetails()
        }, withCancel: nil)
        
        ref.child("users").child(uid).child("itemsList").observe(.childRemoved, with: { (snapshot) in
            //self.getItemDetails()
            
            var itemsIndex: Int!
            
            for i in 0...userItems.count-1{
               
                
                if userItems[i].listID == snapshot.key{
                   
                    itemsIndex = i
                    
                    self.shoppingList.remove(at: itemsIndex)
                    userItems.remove(at: itemsIndex)
//                    self.BCfromDB.remove(at: itemsIndex)
//                    self.SLCompletion.remove(at: itemsIndex)
//                    self.itemListIDs.remove(at: itemsIndex)
                    
                    self.tableView.reloadData()
                }
                
            }
            
            
        }, withCancel: nil)
        
    }
   




}
