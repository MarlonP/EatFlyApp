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
    var resultSearchController = UISearchController()
    
    var BCfromDB = [String]()
    var recentSearches = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getItemDetails()
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        self.tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        getItems()
    }
    
    
    
    
    
    func getItems() {
        ref = FIRDatabase.database().reference()
        
        ref.child("items").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let itemsSnap = snapshot.value as! [String : AnyObject]
            self.items.removeAll()
            
            
            for (_,value) in itemsSnap {
                
               
                
                        let itemData = Item()
                        if let itemName = value["itemName"] as? String, let barcode = value["barcode"] as? String, let price = value["price"] as? String {
                            itemData.itemName = itemName
                            itemData.barcode = barcode
                            itemData.price = price
                            
                            
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
        
        if self.resultSearchController.isActive
        {
            return self.filteredData.count
        }
        else
        {
            
            return self.recentSearches.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell?
        
        if self.resultSearchController.isActive
        {
            cell!.textLabel?.text = self.filteredData[indexPath.row]
            
            //compares string filteredData array to the items array and appends all the filteredData into filteredItems
            //THIS IS THE PROBLEM ONLY HAS 1 ITEM WHEN THERE IS 2
            
            for i in 0...items.count-1{
                if self.filteredData[indexPath.row]  == items[i].itemName{
                    print(filteredData[indexPath.row])
                    filteredItems.append(items[i])
                    print(filteredItems.count)
                    print(filteredItems)
                }
                
            }
        }
        else
        {
            cell!.textLabel?.text = self.recentSearches[indexPath.row].itemName
            
        }
        
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if resultSearchController.isActive {
            return nil
        }
            return "Recent Searches"
   
        }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        self.filteredData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (self.itemNames as NSArray).filtered(using: searchPredicate)
        
        print(array)
        
        self.filteredData = array as! [String]
        
        filteredItems.removeAll(keepingCapacity: false)
        self.tableView.reloadData()
        
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").child(uid).child("itemsList").childByAutoId().key
        
        if self.resultSearchController.isActive {

        print( self.filteredItems[indexPath.row])
        
        let item: [String : Any] = ["barcode" : self.filteredItems[indexPath.row].barcode, "completion" : false, "listID" : key]
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

        resultSearchController.searchBar.endEditing(true)
        resultSearchController.dismiss(animated: true, completion: nil)
        
        
        }else{
            let item: [String : Any] = ["barcode" : self.recentSearches[indexPath.row].barcode, "completion" : false, "listID" : key]
            let itemsList = ["\(key)" : item]
            
            ref.child("users").child(uid).child("itemsList").updateChildValues(itemsList)
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
                if let itemName = value["itemName"] as? String, let barcode = value["barcode"] as? String, let price = value["price"] as? String {
                    itemData.itemName = itemName
                    itemData.barcode = barcode
                    itemData.price = price
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
