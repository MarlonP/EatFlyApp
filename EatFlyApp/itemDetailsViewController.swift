//
//  itemDetailsViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 09/05/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

var currentShopBarcode: String!

import UIKit
import Firebase

class itemDetailsViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var itemTypeLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(currentShopBarcode)
        getItemData()
        
    }
    
    func getItemData(){
        let ref = FIRDatabase.database().reference()
        
        ref.child("items").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let itemsSnap = snapshot.value as! [String : AnyObject]
            
            
            for (_,value) in itemsSnap {
                
        
                if currentShopBarcode == value["barcode"] as! String {
                
                
                if let itemName = value["itemName"] as? String, let price = value["price"] as? String, let itemType = value["itemType"] as? String {
                    
                    self.itemNameLbl.text = itemName
                    self.priceLbl.text = price
                    self.itemTypeLbl.text = itemType
                    
                }
                }
                
                
            }
            
        })
        ref.removeAllObservers()
        
        
    }

  

}
