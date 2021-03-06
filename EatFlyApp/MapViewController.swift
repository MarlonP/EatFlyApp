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
    
    let exhibtionsItems = ["Apple","Carrots","Chicken","Donut", "Salmon", "Ketchup", "Onions", "Crisp", "Salt", "Pepper"]
    
    

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var appleImg: UIImageView!
    @IBOutlet weak var chickenImg: UIImageView!
    @IBOutlet weak var donuntImg: UIImageView!
    @IBOutlet weak var carrotImg: UIImageView!
    @IBOutlet weak var salmonImg: UIImageView!
    @IBOutlet weak var ketchupImg: UIImageView!
    @IBOutlet weak var onionImg: UIImageView!
    @IBOutlet weak var crispImg: UIImageView!
    @IBOutlet weak var saltImg: UIImageView!
    @IBOutlet weak var pepperImg: UIImageView!
    
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
                        print("chic")
                    
                    case "Donut":
                        donuntImg.downloadImage(from: item.img)
                        donuntImg.isHidden = false
                        
                    case "Salmon":
                        salmonImg.downloadImage(from: item.img)
                        salmonImg.isHidden = false
                        print("hi")
                        
                        
                    case "Ketchup":
                        ketchupImg.downloadImage(from: item.img)
                        ketchupImg.isHidden = false
                        
                    case "Onions":
                        onionImg.downloadImage(from: item.img)
                        onionImg.isHidden = false
                        
                    case "Crisp":
                        crispImg.downloadImage(from: item.img)
                        crispImg.isHidden = false
                    
                    case "Salt":
                        saltImg.downloadImage(from: item.img)
                        saltImg.isHidden = false
                        
                    case "Pepper":
                        pepperImg.downloadImage(from: item.img)
                        pepperImg.isHidden = false
                        
                    default:
                        appleImg.isHidden = true
                        carrotImg.isHidden = true
                        chickenImg.isHidden = true
                        donuntImg.isHidden = true
                        pepperImg.isHidden = true
                        crispImg.isHidden = true
                        onionImg.isHidden = true
                        ketchupImg.isHidden = true
                        salmonImg.isHidden = true
                        saltImg.isHidden = true


                        
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
            scrollView.setContentOffset(CGPoint(x: 200.0, y: 0.0), animated: true)
            
        case "Chicken":
            scrollView.setContentOffset(CGPoint(x: 400.0, y: 0.0), animated: true)
            
        case "Donut":
            scrollView.setContentOffset(CGPoint(x: 200.0, y: 0.0), animated: true)
            
        case "Salmon":
            scrollView.setContentOffset(CGPoint(x: 400.0, y: 0.0), animated: true)
            
        case "Ketchup":
            scrollView.setContentOffset(CGPoint(x: 400.0, y: 0.0), animated: true)
            
        case "Onions":
            scrollView.setContentOffset(CGPoint(x: 50.0, y: 0.0), animated: true)
            
        case "Crisp":
            scrollView.setContentOffset(CGPoint(x: 50.0, y: 0.0), animated: true)
            
        case "Salt":
            scrollView.setContentOffset(CGPoint(x: 600.0, y: 0.0), animated: true)
            
        case "Pepper":
            scrollView.setContentOffset(CGPoint(x: 600.0, y: 0.0), animated: true)
        default: break
            
        }
    }
    

}
