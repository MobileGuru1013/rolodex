//
//  SettingsViewController.swift
//  Dex
//
//  Created by Felipe Campos on 1/28/18.
//  Copyright © 2018 Orange Inc. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    // MARK: Properties

    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logOut(_ sender: Any) {
        do {
            UserDefaults.standard.set(false, forKey: defaultKeys.loggedIn)
            self.performSegue(withIdentifier: "signOutSegue", sender: self)
            try Auth.auth().signOut()
        } catch _ {
            let loginAlert = UIAlertController(title: "Sign Out Failed", message: "There was a problem signing you out, please try again.", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            loginAlert.addAction(okAction)
            
            DispatchQueue.main.async {
                self.present(loginAlert, animated: true, completion:  nil)
            }
        }
    }
    
    // MARK: Methods

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
