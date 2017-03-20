//
//  PayTableViewCell.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 15/03/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class PayTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var addAmountBtn: UIView!
    @IBOutlet weak var minusAmountBtn: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    
    var itemID: String!
    var itemPrice: Double = 0
    var amount: Int = 1
    
    
    @IBAction func pressPlusBtn(_ sender: Any) {
       
        var price: Double = 0
        
        amount = amount + 1
        
        amountTextField.text = "\(amount)"
        
        price = itemPrice * Double(amount)
        let priceText = String(format: "%.2f", price)
        priceLbl.text = "£\(priceText)"
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        let itemsList = ["amount" : amount]
        
        ref.child("users").child(uid).child("currentShop").child(itemID).updateChildValues(itemsList)
        
        
        ref.removeAllObservers()
        
    }

    @IBAction func pressMinusBtn(_ sender: Any) {
        
        var price: Double = 0
        
        if amount > 0 {
            amount = amount - 1
        }
        amountTextField.text = "\(amount)"
        
        price = itemPrice * Double(amount)
        let priceText = String(format: "%.2f", price)
        priceLbl.text = "£\(priceText)"
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        let itemsList = ["amount" : amount]
        
        ref.child("users").child(uid).child("currentShop").child(itemID).updateChildValues(itemsList)
        
        
        ref.removeAllObservers()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        amountTextField.resignFirstResponder()
        return (true)
    }

}
