//
//  ChangePasswordViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 19/04/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var oldPWTextField: UITextField!
    @IBOutlet weak var newPWTextField: UITextField!
    @IBOutlet weak var confirmNewPWTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func savePressed(_ sender: Any) {
        
        let user = FIRAuth.auth()?.currentUser
        let email = user?.email
        let currentPassword = oldPWTextField.text
        
        let credential = FIREmailPasswordAuthProvider.credential(withEmail: email!, password: currentPassword!)
        
        user?.reauthenticate(with: credential, completion: { (error) in
            if error != nil{
                
                print("Error reauthenticating user")
                
            }else{
                
                if self.newPWTextField.text == self.confirmNewPWTextField.text{
                    
                    FIRAuth.auth()?.currentUser?.updatePassword(self.newPWTextField.text!) { error in
                        if let error = error {
                            
                        } else {
                            // Password updated.
                            print("success")
                            
                            _ = self.navigationController?.popViewController(animated: true)

                            
                        }
                    }
                    
                }else{
                    let alertController = UIAlertController(title: "Try Again", message: "new passwords are not the same", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
            
                }
                
            }
        })
    }
 

}
