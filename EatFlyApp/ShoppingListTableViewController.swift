//
//  ShoppingListTableViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello (i7240992) on 22/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit

var list = [String]()

class ShoppingListTableViewController: UITableViewController {
    @IBOutlet weak var input: UITextField!

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
        
        return list.count
    }
    
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = list[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
        let deletedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
    
        if editingStyle == UITableViewCellEditingStyle.delete {
            list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            deletedRow.accessoryType = UITableViewCellAccessoryType.none
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
            list.append(newItem!)
            input.resignFirstResponder()
            input.text = ""
            tableView.reloadData()
        }
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

   

 
    
    
        //    @IBAction func addButton(_ sender: UIButton) {
        //
        //        let newItem = textField.text
        //        listItems.append(newItem!)
        //        textField.resignFirstResponder()
        //        textField.text = ""
        //        tableView.reloadData()
        //
        //
        //    }
        
    
   
        
 
    
        
        
  
    
    
    
    


}
