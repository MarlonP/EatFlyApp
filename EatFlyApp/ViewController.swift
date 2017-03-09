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

class ViewController: UIViewController {
    
    @IBOutlet weak var scanBtn: UIBarButtonItem!
    
    
//    lazy var button: UIButton = {
//        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor.black
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
//        button.setTitleColor(UIColor.white, for: UIControlState())
//        button.setTitle("Scan", for: UIControlState())
//        button.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)
//        
//        return button
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        view.backgroundColor = UIColor.white
//        view.addSubview(button)
    
        
        
    }
    
    
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        
//        button.frame.size = CGSize(width: 250, height: 80)
//        button.center = view.center
//    }
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        
        present(controller, animated: true, completion: nil)
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
                            controller.dismiss(animated: true, completion: nil)

                        }
                        
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
    
    
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
    
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
