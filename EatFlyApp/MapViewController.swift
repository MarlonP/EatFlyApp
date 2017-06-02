//
//  MapViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 17/05/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import MapKit

var passedValue: String!
class MapViewController: UIViewController, MKMapViewDelegate {
    
    let exhibtionsItems = ["Apple","Carrots","Chicken","Donut"]
    
    

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var appleImg: UIImageView!
    @IBOutlet weak var chickenImg: UIImageView!
    @IBOutlet weak var donuntImg: UIImageView!
    @IBOutlet weak var carrotImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in usersShoppingListItems {
            for exItem in exhibtionsItems{
                print(exItem)
                print(item.itemName)
                if item.itemName == exItem {
                    
                    
                    switch (exItem){
                    case "Apple":
                        appleImg.downloadImage(from: item.img)
                        appleImg.isHidden = false
                        
                    case "Carrots":
                        carrotImg.downloadImage(from: item.img)
                        carrotImg.isHidden = false
                        
                    case "Chicken":
                        chickenImg.downloadImage(from: item.img)
                        chickenImg.isHidden = false
                    
                    case "Donut":
                        donuntImg.downloadImage(from: item.img)
                        donuntImg.isHidden = false
                        
                    default:
                        appleImg.isHidden = true
                        carrotImg.isHidden = true
                        chickenImg.isHidden = true
                        donuntImg.isHidden = true
                        
                    }

                        
                }
            }
        }
        
        print(passedValue)
    }
    
    override func viewDidLayoutSubviews() {
       
        
        switch (passedValue) {
        case "Apple":
            scrollView.setContentOffset(CGPoint(x: 400.0, y: 0.0), animated: true)
            
        case "Carrots":
            scrollView.setContentOffset(CGPoint(x: 700.0, y: 0.0), animated: true)
            
        case "Chicken":
            scrollView.setContentOffset(CGPoint(x: 400.0, y: 0.0), animated: true)
            
        case "Donut":
            scrollView.setContentOffset(CGPoint(x: 700.0, y: 0.0), animated: true)
        default: break
            
        }
    }
    

}
