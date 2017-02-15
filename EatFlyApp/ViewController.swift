//
//  ViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 02/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import BarcodeScanner

class ViewController: UIViewController {
    
    var items = [Item]()
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.setTitle("Scan", for: UIControlState())
        button.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        view.addSubview(button)
        
        
        
        Alamofire.request("http://178.62.90.238/items.json").response { response in
            
            if let error = response.error {
                print(error)
                return
            }
            
            guard let data = response.data else { return }
            
            let json = JSON(data: data)
            
            for item in json["data"]["items"].arrayValue {
                
                let newItem = Item(json: item)
                self.items.append(newItem)
            }
            
            
            
            for item in self.items {
                print(item.name)
            }
            
            
        }
        
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        button.frame.size = CGSize(width: 250, height: 80)
        button.center = view.center
    }
    
    func buttonDidPress() {
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        
        present(controller, animated: true, completion: nil)
    }
}

extension ViewController: BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        print(code)
        print(type)
        
        let delayTime = DispatchTime.now() + Double(Int64(6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            controller.resetWithError()
        }
    }
    
    
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
    
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
