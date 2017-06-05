//
//  EmailViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 05/06/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class EmailViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.text = FIRAuth.auth()?.currentUser?.email
    }



}
