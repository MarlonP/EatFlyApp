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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getItems()
     
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        self.tableView.reloadData()
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
    
    
  
    
    func checkItemsList(indexPath: IndexPath) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (_, value) in following {
                    if value as! String == self.items[indexPath.row].barcode {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                    
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
            
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell?
        
        if self.resultSearchController.isActive
        {
            cell!.textLabel?.text = self.filteredData[indexPath.row]
            
            //compares string filteredData array to the items array and appends all the filteredData into filteredItems
            filteredItems.removeAll()
            for i in 0...items.count-1{
                if self.filteredData[indexPath.row]  == items[i].itemName{
                    filteredItems.append(items[i])
                }
                
            }
        }
        else
        {
            //cell!.textLabel?.text = self.shoppingList[indexPath.row]
        }

        checkItemsList(indexPath: indexPath)
        
        
        
        return cell!
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        self.filteredData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (self.itemNames as NSArray).filtered(using: searchPredicate)
        
        self.filteredData = array as! [String]
        
        self.tableView.reloadData()
        
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").child(uid).child("itemsList").childByAutoId().key
        
        
        
        
        let item: [String : Any] = ["barcode" : self.filteredItems[indexPath.row].barcode, "completion" : false, "listID" : key]
        let itemsList = ["\(key)" : item]
        
        ref.child("users").child(uid).child("itemsList").updateChildValues(itemsList)
        
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
        
        navigationController?.popViewController(animated: true)
        
    }
    
   
  

   
}
