//
//  PayViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 24/05/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit

var finalTotalPrice: String!
var amountOfItems: Int!

class PayViewController: UIViewController {
    
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var amountOfItemsLbl: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalPriceLbl.text = finalTotalPrice
        amountOfItemsLbl.text = "\(amountOfItems!) Items"

        // Do any additional setup after loading the view.
    }

    @IBAction func PayCDPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Coming Soon!", message: "Paying is not avaliable at the moment.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }


    @IBAction func ApplePayPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Coming Soon!", message: "Paying is not avaliable at the moment.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
