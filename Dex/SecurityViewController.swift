//
//  SecurityViewController.swift
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

class SecurityViewController: UIViewController, UITextFieldDelegate, SecurityViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet var dexLogo: UIImageView!
    @IBOutlet var finishingUpLabel: UILabel!
    var securityCardView: SecuritySetUpCardView!
    var card: Card!
    
    let databaseRef = Database.database().reference()
    let storageRef = Storage.storage().reference(forURL: "gs://dex-app-89824.appspot.com/")
    
    // MARK: Initialization

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        
        securityCardView = SecuritySetUpCardView()
        
        securityCardView.delegate = self
        securityCardView.textFieldDelegate = self
        securityCardView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(securityCardView)
        
        makeView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Methods
    
    func makeView() {
        dexLogo.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Utils.largeOffset)
            make.centerX.equalToSuperview()
            make.height.equalTo(Utils.hugeOffset)
            make.width.equalTo(dexLogo.snp.height).multipliedBy(1.0 / 1.0)
        }
        
        finishingUpLabel.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(dexLogo.snp.bottom).offset(Utils.largeOffset) // TODO: offset from logo
            make.centerX.equalToSuperview()
        }
        
        securityCardView.snp.makeConstraints { (make) in
            make.top.equalTo(finishingUpLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(40)
        }
        
        securityCardView.makeView()
    }
    
    // MARK: Protocols
    
    func saveButtonTapped() {
        SwiftSpinner.show("Creating your profile...")
        Auth.auth().createUser(withEmail: card.email(), password: securityCardView.password()) { (user, error) in
            if user != nil {
                let u = self.card.user()
                let userData = [
                    "name" : u.name(),
                
                    "influence" : String(u.influence()),
                    
                    "cardCount" : String(u.cards().count)
                ]
                self.databaseRef.child("users").child(user!.uid).setValue(userData)
                
                let cardData = [
                    "occupation" : self.card.occupation(),
                    
                    "email" : self.card.email(),
                    
                    "phone" : self.card.primaryPhone().number(),
                    
                    "website" : self.card.website()
                ]
                self.databaseRef.child("users").child(user!.uid).child("cards").child("0").setValue(cardData)
                
                let imageData = UIImagePNGRepresentation(self.card.profilePicture())!
                let imageRef = self.storageRef.child("userData").child("profilePictures").child("\(user!.uid).png")
                
                var downloadURL: URL?
                imageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if let err = error {
                        print(err.localizedDescription)
                    } else if let md = metadata {
                        downloadURL = md.downloadURL()
                        let changeRequest = user!.createProfileChangeRequest()
                        changeRequest.displayName = u.name()
                        changeRequest.photoURL = downloadURL!
                        changeRequest.commitChanges(completion: nil)
                        print("Successful.")
                    }
                })
                
                UserDefaults.standard.set(true, forKey: defaultKeys.loggedIn)
                UserDefaults.standard.set(u.name(), forKey: defaultKeys.displayName)
                UserDefaults.standard.set(u.primaryCard().occupation(), forKey: defaultKeys.displayOccupation)
                
                SwiftSpinner.hide({
                    self.performSegue(withIdentifier: "securityComplete", sender: self)
                })
            } else {
                if let err = error?.localizedDescription {
                    print(err)
                } else {
                    print("Undefined error.")
                }
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = NSTextAlignment.left
                let messageText = NSMutableAttributedString(
                    string: "\nLooks like there was a problem with your sign up. Check that your email is valid and try again.",
                    attributes: [
                        NSParagraphStyleAttributeName: paragraphStyle,
                        NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote),
                        NSForegroundColorAttributeName : UIColor.black
                    ]
                )
                let titleStyle = NSMutableParagraphStyle()
                titleStyle.alignment = NSTextAlignment.center
                let titleText = NSMutableAttributedString(
                    string: "There was a problem signing you up.",
                    attributes: [
                        NSParagraphStyleAttributeName: titleStyle,
                        NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
                        NSForegroundColorAttributeName : UIColor.black
                    ]
                )
                let signUpAlert = UIAlertController()
                signUpAlert.setValue(titleText, forKey: "attributedTitle")
                signUpAlert.setValue(messageText, forKey: "attributedMessage")
                
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                signUpAlert.addAction(okAction)
                DispatchQueue.main.async {
                    SwiftSpinner.hide({
                        self.present(signUpAlert, animated: true, completion:  nil)
                    })
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let tb = segue.destination as! UITabBarController
        let vc = tb.viewControllers![0] as! ViewController
        vc.ourUser = card.user()
        vc.cards = [card]
    }
}
