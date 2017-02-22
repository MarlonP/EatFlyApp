//
//  SListTableViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 21/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SListTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var itemNames = [String]()
    var filteredData = [String]()
    var items = [Item]()
    var shoppingList = [String]()
    var resultSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        URLCache.shared.removeAllCachedResponses()
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
            
            for item in self.items {
                print(item.itemName)
                self.itemNames.append(item.itemName)
            }
            
            
        }

        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        }
        else
        {
            //cell!.textLabel?.text = self.shoppingList[indexPath.row]
        }

       
        
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
        
        let selectedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        self.shoppingList.append((selectedRow.textLabel?.text)!)

        resultSearchController.searchBar.endEditing(true)
        searchBarCancelButtonClicked(searchBar: resultSearchController.searchBar)
        
        resultSearchController.dismiss(animated: true, completion: nil)
        
        navigationController?.popViewController(animated: true)
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        self.searchDisplayController?.setActive(false, animated: true)
    }
  

   
}
