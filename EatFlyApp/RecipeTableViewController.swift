//
//  RecipeTableViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 30/03/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit

var recipe = [RecipeItem]()
//var fractions1 = [String]()

let myNotificationKey1 = "com.mcp.notificationKey"

class RecipeTableViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(doSomethingAfterNotified),
                                               name: NSNotification.Name(rawValue: myNotificationKey),
                                               object: nil)
        
      
       NotificationCenter.default.addObserver(self, selector: #selector(doThisWhenNotify1), name: NSNotification.Name(rawValue: myNotificationKey1), object: nil)


    }
    
    func doThisWhenNotify1() {
        uploadRecipe = recipe
        
    }

   
    @IBAction func donePressed(_ sender: Any) {
        
        if recipe.count != 0 {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: myNotificationKey1), object: nil)
            
            
            
            _ = navigationController?.popViewController(animated: true)
            
        } else {
            print("No items in recipe")
        }
        
    }
    
    func doSomethingAfterNotified() {
        tableView.reloadData()
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return recipe.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let pointSize: CGFloat = 14.0
        let string = "\(recipe[indexPath.row].amount!) \(recipe[indexPath.row].itemName!)"

        let attribString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: pointSize), NSForegroundColorAttributeName: UIColor.black])
        attribString.addAttributes([NSFontAttributeName: UIFont.fractionFont(ofSize: pointSize)], range: (string as NSString).range(of: recipe[indexPath.row].fraction!))
        cell.textLabel?.attributedText = attribString
        cell.textLabel?.sizeToFit()
        
        //let ItemString = "\(recipe[indexPath.row].amount!) \(recipe[indexPath.row].itemName!)"
        
        //cell.textLabel?.text = ItemString

        return cell
    }
    


    
    // Override to support editing the table view.
    
    //not working for some reason!!!
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            recipe.remove(at: indexPath.row)
           
        }
    }

    


 
}

extension UIFont
{
    static func fractionFont(ofSize pointSize: CGFloat) -> UIFont
    {
        let systemFontDesc = UIFont.systemFont(ofSize: pointSize).fontDescriptor
        let fractionFontDesc = systemFontDesc.addingAttributes(
            [
                UIFontDescriptorFeatureSettingsAttribute: [
                    [
                        UIFontFeatureTypeIdentifierKey: kFractionsType,
                        UIFontFeatureSelectorIdentifierKey: kDiagonalFractionsSelector,
                        ], ]
            ] )
        return UIFont(descriptor: fractionFontDesc, size:pointSize)
    }
}

