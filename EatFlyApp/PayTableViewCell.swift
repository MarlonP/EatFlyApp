//
//  PayTableViewCell.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 15/03/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

protocol PayTableViewCellDelegate {
    func buttonPressed()
}

class PayTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var addAmountBtn: UIView!
    @IBOutlet weak var minusAmountBtn: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    
    var itemID: String!
    var itemPrice: Double = 0
    var amount: Int = 1
    
    var delegate: PayTableViewCellDelegate?
    
    @IBAction func pressPlusBtn(_ sender: Any) {
       
        delegate?.buttonPressed()
        var price: Double = 0
        
        //Sets amount
        amount = amount + 1
        print(amount)
        amountTextField.text = "\(amount)"
        
        
        //Sets price
        price = itemPrice * Double(amount)
        let priceText = String(format: "%.2f", price)
        priceLbl.text = "£\(priceText)"
        
        //Writes amount to firebase
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        let itemsList = ["amount" : amount]
        
        ref.child("users").child(uid).child("currentShop").child(itemID).updateChildValues(itemsList)
        
        
        ref.removeAllObservers()
        
    }

    @IBAction func pressMinusBtn(_ sender: Any) {
        delegate?.buttonPressed()
        var price: Double = 0
        
        //Sets amount
        if amount > 1 {
            amount = amount - 1
        }
        print(amount)
        amountTextField.text = "\(amount)"
        
        //Sets price
        price = itemPrice * Double(amount)
        let priceText = String(format: "%.2f", price)
        priceLbl.text = "£\(priceText)"
        
        //Writes amount to firebase
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        let itemsList = ["amount" : amount]
        
        ref.child("users").child(uid).child("currentShop").child(itemID).updateChildValues(itemsList)
        
        
        ref.removeAllObservers()
    }
    
    

}
