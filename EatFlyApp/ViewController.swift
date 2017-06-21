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
    var ref = FIRDatabase.database().reference()
    var databaseHandle: FIRDatabaseHandle?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.tableView.tableFooterView = UIView()
        //tableView.reloadData()
        
//        getItemDetails()
//        getAmounts()
//        
//        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getItemDetails()
        getAmounts()
//        
       tableView.reloadData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let yourBackImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    @IBAction func startNewShopPressed(_ sender: Any) {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
       
            
            let alert = UIAlertController(title: "Start a new shop",
                                          message: "Are you sure you want to start a new shop?",
                                          preferredStyle: .alert)
            // Submit button
            let submitAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                self.currentShop.removeAll()
                self.ref.child("users").child(uid!).child("currentShop").removeValue()
                
                self.tableView.reloadData()
                
                
                
            })
        
        // Cancel button
        let cancel = UIAlertAction(title: "No", style: .destructive, handler: { (action) -> Void in })
        
        
        // Add action buttons and present the Alert
        alert.addAction(submitAction)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    

        
    }
    
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func payButtonPressed(_ sender: Any) {
        finalTotalPrice = totalPriceLbl.text
        amountOfItems = currentShop.count
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
        
        currentShopBarcode = currentShop[indexPath.row].barcode
        
        performSegue(withIdentifier: "itemPageSegue", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
       
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let deletedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        ref = FIRDatabase.database().reference()
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
                
                ref.child("users").child(uid).child("currentShop").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                    
                    
                    
                    if let hasItem = snapshot.value as? [String : AnyObject] {
                        for (_, value) in hasItem {
                            
                            let barcode = value["barcode"] as! String
                            
                            print(barcode)
                            print(self.currentShop[indexPath.row].barcode)
                            
                            if barcode == self.currentShop[indexPath.row].barcode {
                                
                                
                                self.ref.child("users").child(uid).child("currentShop").child(barcode).removeValue()
                                self.currentShop.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                                deletedRow.accessoryType = UITableViewCellAccessoryType.none
                                
                                
                                
                            }
                        }
                        
                    }
                    
                })
                tableView.reloadData()
            
            
     
            
            
            //let key = ref.child("users").child("barcode").key
            
            
            
            
        }
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
    
    func updateAmounts(){
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        
        databaseHandle = ref.child("users").child(uid).child("currentShop").observe(.childChanged, with: { (snapshot) in
            
            var amountsIndex: Int!
            
            for i in 0...self.currentShop.count-1{
                print(self.currentShop[i].barcode)
                print(snapshot.key)
                
                if self.currentShop[i].barcode == snapshot.key{
                    print(i)
                    amountsIndex = i
                    
                }
                
            }
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                let newAmount: Int!
                
                newAmount = dictionary["amount"] as! Int
                
                self.Amounts[amountsIndex] = newAmount
                
                self.tableView.reloadData()
            }
            
            
            
        })
        
    }
    
    
   
}

extension ViewController: BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        BarcodeScanner.Title.color = UIColor.white
        BarcodeScanner.CloseButton.color = UIColor.white
        BarcodeScanner.SettingsButton.color = UIColor.white
        BarcodeScanner.Info.textColor = UIColor.black
        BarcodeScanner.Info.tint = UIColor.black
        BarcodeScanner.Info.loadingTint = UIColor.marlonBlue()
        BarcodeScanner.Info.notFoundTint = UIColor.red
    }
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("itemsList").childByAutoId().key
        
        print(code)
        
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
        
        ref.child("users").child(uid).child("currentShop").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let itemss = snapshot.value as? [String : AnyObject] {
                for (_, value) in itemss {
                    let BC = value["barcode"]
                    if BC as! String == code {
                        
                        let alert = UIAlertController(title: "Item is already in your basket.", message: "Please Continue with you shop.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
        
                        
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
        updateAmounts()
        
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
