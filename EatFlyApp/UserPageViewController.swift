//
//  userPageViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 02/03/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class UserPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func logOutPressed(_ sender: Any) {
        
        try! FIRAuth.auth()?.signOut()
    }

}
