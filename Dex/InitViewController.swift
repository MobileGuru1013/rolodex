//
//  InitViewController.swift
//  Dex
//
//  Created by Felipe Campos on 1/10/18.
//  Copyright © 2018 Orange Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class InitViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet var emailLoginButton: UIButton!
    @IBOutlet var emailSignUpButton: UIButton!
    @IBOutlet var phoneLoginButton: UIButton!
    @IBOutlet var phoneSignUpButton: UIButton!
    var u: DexUser?
    var cards: [Card] = []
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        phoneLoginButton.isEnabled = false
        phoneSignUpButton.isEnabled = false
        // phoneLoginButton.isUserInteractionEnabled = false
        // phoneSignUpButton.isUserInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let id = segue.identifier
        if id != nil {
            if id == "loginEmail" {
                let vc = segue.destination as! LoginViewController
                vc.isPhone = false
            } else if id == "loginPhone" {
                let vc = segue.destination as! LoginViewController
                vc.isPhone = true
            } else if id == "emailSignUp" {
                let vc = segue.destination as! SignUpViewController
                vc.isPhone = false
            } else if id == "phoneSignUp" {
                let vc = segue.destination as! SignUpViewController
                vc.isPhone = true
            }
        }
    }

}
