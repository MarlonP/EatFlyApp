//
//  ViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 02/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import BarcodeScanner
import Firebase



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scanBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPriceLbl: UILabel!
    var currentShop = [Item]()
    var Amounts = [Int]()
    var BCfromDB = [String]()
    let ref = FIRDatabase.database().reference()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        //tableView.reloadData()
        
        getItemDetails()
        getAmounts()
        
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//     getItemDetails()
//        
//        tableView.reloadData()

    }
    
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PayTableViewCell
        
        
        cell.delegate = self
        cell.amount = Amounts[indexPath.row]
        cell.itemPrice = Double(currentShop[indexPath.row].price)!
        
        cell.itemID = self.currentShop[indexPath.row].barcode
        
        cell.amountTextField.keyboardType = UIKeyboardType.numberPad
        
        cell.amountTextField.text = "\(cell.amount)"
        
        
        let initialPrice = cell.itemPrice * Double(cell.amount)
        let priceText = String(format: "%.2f", initialPrice)
        cell.priceLbl.text = "£\(priceText)"
        
        

        
        cell.itemNameLbl.text = self.currentShop[indexPath.row].itemName
        
        
        //Start From Here FIX TOTAL PRICE UPDATING
        
        var totalPrice: Double = 0
        
        for i in 0...currentShop.count-1 {
            
            let itemPrice = Double(self.currentShop[i].price)! * Double(Amounts[i])
            totalPrice = totalPrice + itemPrice
        }
        let price = String(format: "%.2f", totalPrice)
        totalPriceLbl.text = "Total: £\(price)"
        
        
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentShop.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
    }
    
    func getItemDetails() {
        
        getCurrentShop()
        
        
        ref.child("items").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let itemsSnap = snapshot.value as! [String : AnyObject]
            self.currentShop.removeAll()
            
            for (_,value) in itemsSnap {
                
                let itemData = Item()
                if let itemName = value["itemName"] as? String, let barcode = value["barcode"] as? String, let price = value["price"] as? String {
                    itemData.itemName = itemName
                    itemData.barcode = barcode
                    itemData.price = price
                    if self.BCfromDB.count != 0 {
                        for i in 0...self.BCfromDB.count-1 {
                            if (itemData.barcode == self.BCfromDB[i]){
                                
                                self.currentShop.append(itemData)
                            }
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                }
                
                
                
            }
            
        })
        ref.removeAllObservers()
        
    }
    
    
    
    func getCurrentShop() {
        let uid = FIRAuth.auth()!.currentUser!.uid
        
        ref.child("users").child(uid).child("currentShop").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let itemsSnap = snapshot.value as? [String : AnyObject] {
                
                self.BCfromDB.removeAll()
                
                for (_,value) in itemsSnap {
                    
                    
                    let barcode = value["barcode"] as? String
        
                    self.BCfromDB.append(barcode!)
                    
                }
                
                
            }
            
        })
        ref.removeAllObservers()
    }
    
    func getAmounts(){
        let uid = FIRAuth.auth()!.currentUser!.uid
        
        ref.child("users").child(uid).child("currentShop").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let itemsSnap = snapshot.value as? [String : AnyObject] {
                
                
                self.Amounts.removeAll()
                
                
                for (_,value) in itemsSnap {
                    
                    let currentAmount = value["amount"] as? Int
                    
                    self.Amounts.append(currentAmount!)
                    
                }
                self.tableView.reloadData()
                
            }
            
        })
        ref.removeAllObservers()
        
    }
    
    
   
}

extension ViewController: BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("itemsList").childByAutoId().key
        
        
        
        ref.child("users").child(uid).child("itemsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let completed = snapshot.value as? [String : AnyObject] {
                for (_, value) in completed {
                    let BC = value["barcode"]
                    if BC as! String == code {
                        
                        let completion = value["completion"] as! Bool
                        let id = value["listID"] as! String
                        
                        if completion == true {
                            
                            print("Got this Item already")
                            
                        }else if completion == false{
                            
                            let completionVal: [String : Any] = ["completion" : true]
                            ref.child("users").child(uid).child("itemsList").child(id).updateChildValues(completionVal)

                        }
                        
                    }
                }
            }
            
        })
        
        ref.child("items").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let itemsSnap = snapshot.value as! [String : AnyObject]
            
            for (_,value) in itemsSnap {
                
                if let barcode = value["barcode"] as? String {
                    if barcode == code {
                        self.pushItemsGot(barcode: barcode)
                        print("Got Item")
                        controller.dismiss(animated: true, completion: nil)
                    }
                    
                    
                }
                
                
                
            }
            
        })
        ref.removeAllObservers()
        
        print(code)
        
        
        let delayTime = DispatchTime.now() + Double(Int64(6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            controller.resetWithError()
        }
    }
    
    func pushItemsGot(barcode: String) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        //let key = ref.child("users").child(uid).child("currentShop").childByAutoId().key
        
        
        
        
        let item: [String : Any] = ["barcode" : barcode, "amount" : 1]
        let itemsList = ["\(barcode)" : item]
        
        ref.child("users").child(uid).child("currentShop").updateChildValues(itemsList)
        
        
        ref.removeAllObservers()
    }
    
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
    
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


extension ViewController: PayTableViewCellDelegate {
    
    func buttonPressed() {
        //need to update Amounts array
        getAmounts()
        
        print("something changed")
        var totalPrice: Double = 0
        
        for i in 0...currentShop.count-1 {
        
            let itemPrice = Double(self.currentShop[i].price)! * Double(Amounts[i])
            totalPrice = totalPrice + itemPrice
        }
        let price = String(format: "%.2f", totalPrice)
        totalPriceLbl.text = "Total: £\(price)"
    }
    
}
