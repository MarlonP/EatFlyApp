//
//  BeaconViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 12/05/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

var usersShoppingListItems = [Item]()

class BeaconViewController: UIViewController, ESTBeaconManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let beaconManager = ESTBeaconManager()
    let beaconRegion = CLBeaconRegion(
        proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
        identifier: "ranged region")
    
    var ref: FIRDatabaseReference?
    var databaseHandle: FIRDatabaseHandle?
    
    var beaconsFromDB = [Beacon]()
    
    var itemsBeingTracked = [Item]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        self.tableView.tableFooterView = UIView()
        
        let alert = UIAlertController(title: "Read Below:", message: "Do not completely rely on the distances as it is not 100% accurate. And for this to work turn you bluetooth on.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
       
        //getBeacons()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.beaconManager.startRangingBeacons(in: self.beaconRegion)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(self.beaconManager.startRangingBeacons(in: self.beaconRegion))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.beaconManager.stopRangingBeacons(in: self.beaconRegion)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let yourBackImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usersShoppingListItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = usersShoppingListItems[indexPath.row]
        
        
        
        
        
        
        print(item.itemName)
        cell.textLabel?.text = item.itemName
        
        if let proximity = item.proximity, let accuracy = item.accuracy {
            
            if proximity == "Unknown"{
                cell.detailTextLabel?.text = proximity
                
            }else{
                if (accuracy < 1) {
                    cell.detailTextLabel?.text = "Approx. > 1m"
                }else{
                    let accuracyString = (String(format: "%.0f", accuracy))
                    //print(accuracyString)
                    cell.detailTextLabel?.text = "Approx. \(accuracyString)m"
                }
                
              handleReloadTable()
            }
            

        }
        
        

        return cell
    }
    
    var valueToPass:String!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        valueToPass = currentCell.textLabel?.text
        performSegue(withIdentifier: "mapViewSegue", sender: self)
        
        passedValue = valueToPass
        
        
    }
    
 

    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon],
                       in region: CLBeaconRegion) {
        
        
        for item in usersShoppingListItems {
            for beacon in beacons {
                
                guard item.beaconID == "\(beacon.major):\(beacon.minor)" else { continue }
                
                var beaconProximity: String;
                switch (beacon.proximity) {
                    case CLProximity.unknown:    beaconProximity = "Unknown";
                    case CLProximity.far:        beaconProximity = "Far";
                    case CLProximity.near:       beaconProximity = "Near";
                    case CLProximity.immediate:  beaconProximity = "Immediate";
                }
                
                item.proximity = beaconProximity
                item.accuracy = beacon.accuracy
                
                
            }
        }
        print(beacons.count)
       
        tableView.reloadData()
   
        
    }
    

    
    func handleReloadTable() {
        usersShoppingListItems.sort(by: { (item1, item2) -> Bool in
            guard let accuracyOne = item1.accuracy, let accuracyTwo = item2.accuracy else { return false }
            
            return accuracyOne < accuracyTwo
        })
        

    }
    
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        print(region)
    }
        

    
    

    
    func getBeacons(){
        
        
        ref?.child("beacons").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            
            let beaconsSnap = snap.value as! [String : AnyObject]
            self.beaconsFromDB.removeAll()
            
            for (_,beacon) in beaconsSnap {
                
                let beaconGet = Beacon()
                if  let major = beacon["major"] as? NSNumber, let minor = beacon["minor"] as? NSNumber, let listID = beacon["listID"] as? String, let UUID = beacon["UUID"] as? String {
                    
                    beaconGet.UUID = UUID
                    beaconGet.major = major
                    beaconGet.minor = minor
                    beaconGet.listID = listID
                    
                    print(beaconGet)
                    
                    self.beaconsFromDB.append(beaconGet)
                }
                
              
                self.tableView.reloadData()
                
            }
            
            
        })
        
        
    }
    

   




}
