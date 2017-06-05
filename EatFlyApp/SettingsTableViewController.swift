//
//  SettingsTableViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 12/04/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import  Firebase

class SettingsTableViewController: UITableViewController {
    
    let data = [["Edit Profile", "Email Address", "Change Password"],["Log Out"]]
    let Titles = ["Account", "   "]
    

    override func viewDidLoad() {
        super.viewDidLoad()
       

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let yourBackImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationController?.navigationBar.backItem?.title = ""
    }


   
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = data[indexPath.section][indexPath.row]

        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < Titles.count {
            return Titles[section]
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                performSegue(withIdentifier: "editProfile", sender: nil)
            
            }
        
            if indexPath.row == 1 {
                performSegue(withIdentifier: "email", sender: nil)
            
            }
        
            if indexPath.row == 2 {
                performSegue(withIdentifier: "changePW", sender: nil)
            
            }
        }
        if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                try! FIRAuth.auth()?.signOut()
            
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
                
                self.present(vc, animated: true, completion: nil)
            

            }
        }
    }
    
 


  

  

}
