//
//  ShoppingListTableViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello (i7240992) on 22/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit

class ShoppingListTableViewController: UITableViewController {

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
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
        
    
   
        
        
        //
        //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        //        let selectedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
        //
        //        if selectedRow.accessoryType == UITableViewCellAccessoryType.none{
        //            selectedRow.accessoryType = UITableViewCellAccessoryType.checkmark
        //            selectedRow.tintColor = UIColor.green
        //        }
        //
        //        else{
        //            selectedRow.accessoryType = UITableViewCellAccessoryType.none
        //
        //        }//end if/else statement
        //
        //
        //    }// end didSelectRow function
        //
        //
        //    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //
        //        let deletedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
        //        
        //        if editingStyle == UITableViewCellEditingStyle.delete {
        //            listItems.remove(at: indexPath.row)
        //            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        //            deletedRow.accessoryType = UITableViewCellAccessoryType.none
        //            
        //        }
        
        
  
    
    
    
    


}
