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
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getItemDetails()
        
        

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
        var itemPrice: Double = 0
        cell.amount = Amounts[indexPath.row]
        cell.itemPrice = Double(currentShop[indexPath.row].price)!
        let amount = cell.amount
        cell.itemID = self.currentShop[indexPath.row].barcode
        cell.amountTextField.text = "1"
        
        
        itemPrice = Double(self.currentShop[indexPath.row].price)! * Double(amount)
        
        cell.itemNameLbl.text = self.currentShop[indexPath.row].itemName
        
        
        //Start From Here FIX TOTAL PRICE UPDATING
        
        var totalPrice: Double = 0
        
        for i in 0...currentShop.count-1 {
            
            let itemPrice = (self.currentShop[i].price as NSString).doubleValue
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
    
    //let itemsList = ["itemsList/\(key)" : self.filteredItems[indexPath.row].barcode]
    
    //ref.child("users").child(uid).updateChildValues(itemsList)
    
    
    func getCurrentShop() {
        let uid = FIRAuth.auth()!.currentUser!.uid
        
        ref.child("users").child(uid).child("currentShop").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let itemsSnap = snapshot.value as? [String : AnyObject] {
                
                self.BCfromDB.removeAll()
                
                
                for (_,value) in itemsSnap {
                    
                    
                    let currentAmount = value["amount"] as? Int
                    let barcode = value["barcode"] as? String
                    
                    
                    self.Amounts.append(currentAmount!)
                    self.BCfromDB.append(barcode!)
                    
                    
                    
                    
                }
                
                
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
        
        
        
        
        let item: [String : Any] = ["barcode" : barcode, "amount" : "1"]
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
