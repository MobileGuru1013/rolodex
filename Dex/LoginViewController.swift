//
//  LoginViewController.swift
//  Dex
//
//  Created by Felipe Campos on 1/25/18.
//  Copyright © 2018 Orange Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftSpinner

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet var logoView: UIImageView!
    @IBOutlet var contactLabel: UILabel!
    @IBOutlet var contactField: UITextField!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    var isPhone: Bool = false
    var savedPhone: Phone?
    var u: DexUser?
    var cards: [Card] = []
    
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference(forURL: "gs://dex-app-89824.appspot.com/")
    let database = Database.database()
    let databaseRef = Database.database().reference()
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.isEnabled = false
        contactField.delegate = self
        passwordField.delegate = self
        
        hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
        if isPhone {
            contactLabel.text = "Phone Number:"
            contactField.placeholder = "(415) 555-5555"
            contactField.keyboardType = .phonePad
            contactLabel.sizeToFit()
        } else {
            contactLabel.text = "Email:"
            contactField.placeholder = "chris@dex.com"
            contactField.keyboardType = .emailAddress
            contactField.autocapitalizationType = .none
        }
        
        makeView()
    }
    
    // MARK: Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editedContact(_ sender: Any) {
        if isPhone {
            let phoneNumber = contactField.text!
            savedPhone = Phone(number: phoneNumber, kind: .other)
            if let formatted = Utils.format(phoneNumber: phoneNumber) {
                contactField.text = formatted
            }
        }
        loginCheck()
    }
    
    
    @IBAction func editedPassword(_ sender: Any) {
        loginCheck()
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        SwiftSpinner.show("Fetching your data...")
        if isPhone {
            // FIXME: implement
        } else {
            Auth.auth().signIn(withEmail: contactField.text!, password: passwordField.text!, completion: { (user, error) in
                if user != nil {
                    var image: UIImage?
                    self.storage.reference(forURL: user!.photoURL!.absoluteString).getData(maxSize: 25 * 1024 * 1024, completion: { (data, error) -> Void in
                        image = UIImage(data: data!)
                        
                        self.databaseRef.child("users").child(user!.uid).observeSingleEvent(of: .value, with: { (snap) in
                            if !snap.exists() {
                                print("Data snapshot does not exist.")
                                return
                            }
                            
                            if let shot = snap.value as? [String : AnyObject] {
                                let name = shot["name"] as! String
                                let inf = shot["influence"] as! String
                                let numCards = Int(shot["cardCount"] as! String)!
                                
                                self.u = DexUser(name: name, influence: Double(inf)!)
                                
                                for i in 0..<numCards {
                                    self.databaseRef.child("users").child(user!.uid).child("cards").child(String(i)).observeSingleEvent(of: .value, with: { (snap) in
                                        if !snap.exists() {
                                            print("Data snapshot does not exist.")
                                            return
                                        }
                                        
                                        if let shot = snap.value as? [String : AnyObject] {
                                            let occupation = shot["occupation"] as! String
                                            let email = shot["email"] as! String
                                            let number = shot["phone"] as! String
                                            let website = shot["website"] as! String
                                            
                                            let phone = Phone(number: number, kind: .other)
                                            let card = Card(user: self.u!, occupation: occupation, email: email, phones: [phone], web: website, avi: image!)
                                            self.cards.append(card)
                                            if i == numCards - 1 {
                                                DispatchQueue.main.async {
                                                    UserDefaults.standard.set(true, forKey: defaultKeys.loggedIn)
                                                    UserDefaults.standard.set(self.u!.name(), forKey: defaultKeys.displayName)
                                                    UserDefaults.standard.set(self.u!.primaryCard().occupation(), forKey: defaultKeys.displayOccupation)
                                                    print("Signed in.")
                                                    SwiftSpinner.hide({
                                                        self.performSegue(withIdentifier: "loggedIn", sender: self)
                                                    })
                                                }
                                            }
                                        }
                                    })
                                }
                            }
                        })
                    })
                } else {
                    let loginAlert = UIAlertController(title: "Invalid Email or Password", message: "Whoops! Looks like your email or password are incorrect. Please try again.", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    
                    loginAlert.addAction(okAction)
                    DispatchQueue.main.async {
                        SwiftSpinner.hide({
                            self.present(loginAlert, animated: true, completion:  nil)
                        })
                    }
                    
                    if let err = error?.localizedDescription {
                        print(err)
                    } else {
                        print("Undefined error.")
                    }
                }
            })
        }
    }
    
    // MARK: Methods
    
    func loginCheck() {
        if contactField.hasText && passwordField.hasText {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
    func makeView() {
        logoView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Utils.hugeOffset)
            make.centerX.equalToSuperview()
            make.height.equalTo(Utils.hugeOffset)
            make.width.equalTo(logoView.snp.height).multipliedBy(2.1 / 1.0)
        }
        
        contactLabel.snp.makeConstraints { (make) in
            make.top.equalTo(logoView.snp.bottom).offset(Utils.hugeOffset * 2)
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.height.equalTo(contactLabel.font.lineHeight)
        }
        
        contactField.snp.makeConstraints { (make) in
            make.top.equalTo(contactLabel.snp.bottom).offset(Utils.smallOffset)
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.height.equalTo(contactField.font!.lineHeight * 2)
        }
        
        passwordLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contactField.snp.bottom).offset(Utils.hugeOffset * 2)
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.height.equalTo(passwordLabel.font.lineHeight)
        }
        
        passwordField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordLabel.snp.bottom).offset(Utils.smallOffset)
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.height.equalTo(passwordField.font!.lineHeight * 2)
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(loginButton.snp.height).multipliedBy(19.0 / 15.0)
            make.bottom.equalToSuperview().inset(Utils.mediumOffset)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let tb = segue.destination as! UITabBarController
        let vc = tb.viewControllers![0] as! ViewController
        vc.ourUser = self.u!
        vc.cards = self.u!.cards()
    }

}
