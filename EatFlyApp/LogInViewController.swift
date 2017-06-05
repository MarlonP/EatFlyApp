//
//  LogInViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 03/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase


class LogInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
  
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
        
    }
    
    override func viewDidLayoutSubviews() {
        // Creates the Top border
        let borderTop = CALayer()
        let borderWidth = CGFloat(2.0)
        
        borderTop.borderColor = UIColor.lightGray.cgColor
        borderTop.frame = CGRect(x: 0, y: 0, width: pwField.frame.width, height: 1)
        borderTop.borderWidth = borderWidth
        pwField.layer.addSublayer(borderTop)
        pwField.layer.masksToBounds = true
        
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if FIRAuth.auth()?.currentUser?.uid != nil {
//            
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "feedVC")
//            self.present(vc, animated: true, completion: nil)
//            
//        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("begin")
        scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
         print("end")
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        //can put notification for error before return in else method same in sign up
        guard emailField.text != "", pwField.text != "" else { return}
        
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: pwField.text!, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            
            if let user = user {
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "feedVC")
                
                self.present(vc, animated: true, completion: nil)
                
            }
        })
    }

}
