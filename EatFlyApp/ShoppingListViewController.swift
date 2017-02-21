//
//  ShoppingListViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 03/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var listItems = [String]()
    var items = [Item]()
    
    
    @IBOutlet var textField: UITextField!
    
    @IBOutlet var tableView: UITableView!
    
    
    @IBAction func addButton(_ sender: UIButton) {
        
        let newItem = textField.text
        listItems.append(newItem!)
        textField.resignFirstResponder()
        textField.text = ""
        tableView.reloadData()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Alamofire.request("http://178.62.90.238/items.json").response { response in
            
            if let error = response.error {
                print(error)
                return
            }
            
            guard let data = response.data else { return }
            
            let json = JSON(data: data)
            
            for item in json["data"]["items"].arrayValue {
                
                let newItem = Item(json: item)
                self.items.append(newItem)
            }
            
            print(self.items)
            
            for item in self.items {
                print(item.barcode)
            }
            
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return listItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = listItems[indexPath.row]
        cell.textLabel?.textColor = UIColor.red
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        if selectedRow.accessoryType == UITableViewCellAccessoryType.none{
            selectedRow.accessoryType = UITableViewCellAccessoryType.checkmark
            selectedRow.tintColor = UIColor.green
        }
            
        else{
            selectedRow.accessoryType = UITableViewCellAccessoryType.none
            
        }//end if/else statement
        
        
    }// end didSelectRow function
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let deletedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            listItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            deletedRow.accessoryType = UITableViewCellAccessoryType.none
            
        }
    }
    


}
