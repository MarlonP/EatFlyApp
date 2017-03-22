//
//  LogInViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 03/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        emailField.text = "t@t.com"
        pwField.text = "123456"
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser?.uid != nil {
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "feedVC")
            self.present(vc, animated: true, completion: nil)
            
        }
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
