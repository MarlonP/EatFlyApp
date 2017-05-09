//
//  EditRecipeViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 09/05/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit

class EditRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var recipeEdit = [RecipeItem]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeEdit.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }



}
