//
//  SListTableViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 21/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase



class SListTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var itemNames = [String]()
    var filteredData = [String]()
    var items = [Item]()
    var filteredItems = [Item]()
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    
    var shoppingList = [String]()
    let searchController = UISearchController(searchResultsController: nil)

    
    var BCfromDB = [String]()
    var recentSearches = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        getItemDetails()
        
   
        
      
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
        
        //self.tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        getItems()
    }
    
    
    func doThisWhenNotifySL() {
       
        
    }
    
    
    func getItems() {
        ref = FIRDatabase.database().reference()
        
        ref.child("items").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let itemsSnap = snapshot.value as! [String : AnyObject]
            self.items.removeAll()
            
            
            for (_,value) in itemsSnap {
                
               
                
                        let itemData = Item()
                        if let itemName = value["itemName"] as? String, let barcode = value["barcode"] as? String, let price = value["price"] as? String, let imgPath = value["img"] as? String {
                            itemData.itemName = itemName
                            itemData.barcode = barcode
                            itemData.price = price
                            itemData.img = imgPath
                            
                            
                            self.items.append(itemData)
                            self.itemNames.append(itemData.itemName)
                            
                            print(itemData.itemName)
                        }
                
                    
                
            }
            
        })
        ref.removeAllObservers()
    }
    
    


   
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.searchController.isActive
        {
            return self.filteredData.count
        }
        else
        {
            
            return self.recentSearches.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
        
        if self.searchController.isActive
        {
            cell.itemNameLbl.text = self.filteredData[indexPath.row]
            

            
            cell.itemTypeLbl.text = "£\(self.filteredItems[indexPath.row].price!)"
            cell.itemImageView.downloadImage(from: self.filteredItems[indexPath.row].img)
            
            
        }
        else
        {
            cell.itemNameLbl.text = self.recentSearches[indexPath.row].itemName
            cell.itemTypeLbl.text = "£\(self.recentSearches[indexPath.row].price!)"
            cell.itemImageView.downloadImage(from: self.recentSearches[indexPath.row].img)
            
        }
        
        
    
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive {
            return nil
        }
            return "Recent Searches"
   
        }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        
        //compares string filteredData array to the items array and appends all the filteredData into filteredItems
        //THIS IS THE PROBLEM ONLY HAS 1 ITEM WHEN THERE IS 2
        
        
        self.filteredData.removeAll(keepingCapacity: false)
        filteredItems.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (self.itemNames as NSArray).filtered(using: searchPredicate)
        
        print(array)
        
        self.filteredData = array as! [String]
        
        for item in items{
            for filteredItem in filteredData{
                if item.itemName == filteredItem {
                    filteredItems.append(item)
                }
            }
            
        }
        print(filteredItems)
        
        
        self.tableView.reloadData()
        
        
    }
    
    func checkForDuplicateItems(barcode:String) -> Bool {
        
        var duplicateItem = false
        
        
        for item in userItems {
            
            if item.barcode == barcode {
                
                duplicateItem = true
            }
            
            
        }
        
        
        return duplicateItem
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").child(uid).child("itemsList").childByAutoId().key
        let timestamp = NSDate().timeIntervalSince1970
        
        if self.searchController.isActive {
            if checkForDuplicateItems(barcode:self.filteredItems[indexPath.row].barcode) == true {
                let alert = UIAlertController(title: "Item is already in your shopping list.", message: "", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                searchController.searchBar.endEditing(true)
            
            }else{

        print( self.filteredItems[indexPath.row])
        
        let item: [String : Any] = ["barcode" : self.filteredItems[indexPath.row].barcode, "completion" : false, "timestamp" : Int(timestamp), "listID" : key]
        let itemsList = ["\(key)" : item]
        
        ref.child("users").child(uid).child("itemsList").updateChildValues(itemsList)
        ref.child("users").child(uid).child("recentSearches").updateChildValues(itemsList)
        
        ref.child("users").child(uid).child("itemsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
                
            
        })
         
        ref.removeAllObservers()
        
        let selectedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
        
      
        for i in 0...items.count-1{
            if selectedRow.textLabel?.text == items[i].itemName{
                listDetail.append(items[i])
            }
            
        }

        //searchController.searchBar.endEditing(true)
        //searchController.dismiss(animated: true, completion: nil)
            
            }
        
        }else{
            if checkForDuplicateItems(barcode:self.recentSearches[indexPath.row].barcode) == true {
                let alert = UIAlertController(title: "Item is already in your shopping list.", message: "", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                
            }else{
            
            
            let item: [String : Any] = ["barcode" : self.recentSearches[indexPath.row].barcode, "completion" : false, "timestamp" : Int(timestamp), "listID" : key]
            let itemsList = ["\(key)" : item]
            
            ref.child("users").child(uid).child("itemsList").updateChildValues(itemsList)
            }
        }

        navigationController?.popViewController(animated: true)
    }
    
    func getItemDetails() {
        
        getUsersItems()
        
        ref = FIRDatabase.database().reference()
        
        ref.child("items").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let itemsSnap = snapshot.value as! [String : AnyObject]
            self.shoppingList.removeAll()
            
            for (_,value) in itemsSnap {
                
                let itemData = Item()
                if let itemName = value["itemName"] as? String, let barcode = value["barcode"] as? String, let price = value["price"] as? String, let imgPath = value["img"] as? String {
                    itemData.itemName = itemName
                    itemData.barcode = barcode
                    itemData.price = price
                    itemData.img = imgPath
                    
                    
                    if self.BCfromDB.count != 0 {
                        for i in 0...self.BCfromDB.count-1 {
                            if (itemData.barcode == self.BCfromDB[i]){
                                
                                self.recentSearches.append(itemData)
                            }
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                }
                
                
                
            }
            
        })
        ref.removeAllObservers()
        
    }
    
    //let itemsList = ["itemsList/\(key)" : self.filteredItems[indexPath.row].barcode]
    
    //ref.child("users").child(uid).updateChildValues(itemsList)
    
    
    func getUsersItems() {
        let uid = FIRAuth.auth()!.currentUser!.uid
        ref = FIRDatabase.database().reference()
        //let key = ref.child("users").child("barcode").key
        
        ref.child("users").child(uid).child("recentSearches").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let itemsSnap = snapshot.value as? [String : AnyObject] {
                
                self.BCfromDB.removeAll()
                
                
                for (_,value) in itemsSnap {
                    
                    // Error here: fatal error: unexpectedly found nil while unwrapping an Optional value
                    let barcode = value["barcode"] as? String
                    
                    self.BCfromDB.append(barcode!)
                    
                    
                    
                }
                
                
            }
            
        })
        ref.removeAllObservers()
    }
    
   
  

   
}
