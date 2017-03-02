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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listDetail.count
    }
    
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        

        cell.textLabel?.text = listDetail[indexPath.row].itemName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
        let deletedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
    
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let uid = FIRAuth.auth()!.currentUser!.uid
            let ref = FIRDatabase.database().reference()
            //let key = ref.child("users").child("barcode").key
            
            
            ref.child("users").child(uid).child("itemsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                
                
                                
                            if let hasItem = snapshot.value as? [String : AnyObject] {
                                for (key, value) in hasItem {
                                    
                                    print(listDetail.count)
                                    print(listDetail[indexPath.row].barcode)
                                    print(value)
                                    if value as! String == listDetail[indexPath.row].barcode {
                                        
                
                                        ref.child("users").child(uid).child("itemsList/\(key)").removeValue()
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
        tableView.reloadData()
    }



 
    
 
   
        
 
    
        
        
  
    
    
    
    


}
