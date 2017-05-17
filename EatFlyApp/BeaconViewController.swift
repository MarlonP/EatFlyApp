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
    
    //var beaconsBeingTracked = [Beacon]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        //getItems()
        getBeacons()
        
        
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
            }
            
            cell.detailTextLabel?.text = proximity
            
            
        }
        
        
//        if item.proximity == "Unknown"{
//            
//        
//        }else{
//            if (item.accuracy < 1) {
//                cell.detailTextLabel?.text = "Approx. > 1m"
//            }else{
//                let accuracyString = (String(format: "%.0f", item.accuracy))
//                //print(accuracyString)
//                cell.detailTextLabel?.text = "Approx. \(accuracyString)m"
//            }
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "mapViewSegue", sender: nil)
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
        
        tableView.reloadData()
        
//        itemsBeingTracked.removeAll()
//   
//        
//        
//        print(usersShoppingListItems)
//        for beacon in beacons {
//            let trackedItem = Item()
//            
//            var beaconProximity: String;
//            switch (beacon.proximity) {
//            case CLProximity.unknown:    beaconProximity = "Unknown";
//            case CLProximity.far:        beaconProximity = "Far";
//            case CLProximity.near:       beaconProximity = "Near";
//            case CLProximity.immediate:  beaconProximity = "Immediate";
//            }
//            
//          
//            for item in usersShoppingListItems {
//                
//                
//                if item.beaconID == "\(beacon.major):\(beacon.minor)" {
//                    
//                 
//                    
//                    
//                    
//                    trackedItem.major = beacon.major
//                    trackedItem.minor = beacon.minor
//                    trackedItem.accuracy =  beacon.accuracy as Double
//                    trackedItem.proximity = beaconProximity
//                    trackedItem.itemName = item.itemName
//                    trackedItem.barcode = item.barcode
//                    trackedItem.price = item.price
//                    
//                   
//                    
//                    itemsBeingTracked.append(trackedItem)
//                     print(trackedItem.itemName)
//                    print("----------")
//                }
//                
//            
//            }
//            
//            
//            
//            //print("BEACON RANGED: accuracy: \(beacon.accuracy) major: \(beacon.major)  minor: \(beacon.minor) proximity: \(beaconProximity)")
//    }
    
      
        
    }
    
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        print(region)
    }
        
    func locationString(nearestBeacon: CLBeacon!) {
            guard let beacon = nearestBeacon else { return }
            let proximity = nameForProximity(beacon.proximity)
            let accuracy = String(format: "%.2f", beacon.accuracy)
            
            var location = "Location: \(proximity)"
            if beacon.proximity != .unknown {
                location += " (approx. \(accuracy)m)"
            }
        
        print(accuracy)
        label1.text = location
    
    }
    
        func nameForProximity(_ proximity: CLProximity) -> String {
            switch proximity {
            case .unknown:
                return "Unknown"
            case .immediate:
                return "Immediate"
            case .near:
                return "Near"
            case .far:
                return "Far"
            }
        }
    
    
//    func getItems() {
//        ref = FIRDatabase.database().reference()
//        
//        ref?.child("items").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
//            let itemsSnap = snapshot.value as! [String : AnyObject]
//            self.items.removeAll()
//            
//            
//            for (_,value) in itemsSnap {
//                
//                let itemData = Item()
//                if let itemName = value["itemName"] as? String, let barcode = value["barcode"] as? String, let price = value["price"] as? String, let beaconID = value["beacon"] as? String {
//                    itemData.itemName = itemName
//                    itemData.barcode = barcode
//                    itemData.price = price
//                    itemData.beaconID = beaconID
//                    
//                    
//                    self.items.append(itemData)
//                   
//                    
//                }
//                
//                self.tableView.reloadData()
//                
//            }
//            
//        })
//        ref?.removeAllObservers()
//    }

    
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
                
//                for bbeacon in self.beaconsFromDB {
//                    let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: bbeacon.UUID)! , major: bbeacon.major as! CLBeaconMajorValue, minor: bbeacon.minor as! CLBeaconMinorValue, identifier: "Estimote")
//                    
//                    
//                    
//                    self.beaconManager.startRangingBeacons(in: beaconRegion)
//                    print(beaconRegion)
//                }
                
                self.tableView.reloadData()
                
            }
            
            
        })
        
        
    }
    

   




}
