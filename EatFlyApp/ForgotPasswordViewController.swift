
//
//  ForgotPasswordViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 20/04/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func backBtnPressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
        
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func resetPressed(_ sender: Any) {
        if emailTextField.text == "" {
            let alertController = UIAlertController(title: "Try Again", message: "Enter an email", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        }else{
            FIRAuth.auth()?.sendPasswordReset(withEmail: emailTextField.text!) { (error) in
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Try Again"
                    message = (error?.localizedDescription)!
                    
                }else{
                    title = "Success"
                    message = "Password reset email sent."
                    self.emailTextField.text = ""
                    
                }
                
                let alertController1 = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController1.addAction(defaultAction)
                
                self.present(alertController1, animated: true, completion: nil)
            }
        }
        
    }

}
