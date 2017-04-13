//
//  RecipeTableViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 30/03/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit

var recipe = [RecipeItem]()
var fractions1 = [String]()


class RecipeTableViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(doSomethingAfterNotified),
                                               name: NSNotification.Name(rawValue: myNotificationKey),
                                               object: nil)
        
      
       


    }
   

   
    @IBAction func donePressed(_ sender: Any) {
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
        attribString.addAttributes([NSFontAttributeName: UIFont.fractionFont(ofSize: pointSize)], range: (string as NSString).range(of: fractions1[indexPath.row]))
        cell.textLabel?.attributedText = attribString
        cell.textLabel?.sizeToFit()
        
        //let ItemString = "\(recipe[indexPath.row].amount!) \(recipe[indexPath.row].itemName!)"
        
        //cell.textLabel?.text = ItemString

        return cell
    }
    


    
    // Override to support editing the table view.
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

