//
//  MakeProfileViewController.swift
//  Dex
//
//  Created by Felipe Campos on 12/29/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

import UIKit

class MakeProfileViewController: UIViewController, UITextFieldDelegate, SetupDelegate {
    
    // MARK: Properties
    
    @IBOutlet var logoView: UIImageView!
    @IBOutlet var completeProfileLabel: UILabel!
    var setupCardView: SetupCardView!
    var name: String = ""
    var profilePic: UIImage = UIImage()
    var isPhone: Bool = true
    var phone: Phone?
    var email: String?
    
    // MARK: Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        hideKeyboardWhenTappedAround()
        
        if isPhone {
            setupCardView = SetupCardView(name: name, phone: phone!, profilePic: profilePic)
        } else {
            setupCardView = SetupCardView(name: name, email: email!, profilePic: profilePic)
        }
        
        setupCardView.delegate = self
        setupCardView.textFieldDelegate = self
        setupCardView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(setupCardView)
        
        makeView()
    }
    
    // MARK: Actions
    
    @IBAction func backSignUp(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Methods
    
    func makeView() {
        logoView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Utils.largeOffset)
            make.centerX.equalToSuperview()
            make.height.equalTo(Utils.hugeOffset)
            make.width.equalTo(logoView.snp.height).multipliedBy(1.0 / 1.0)
        }
        
        completeProfileLabel.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(logoView.snp.bottom).offset(Utils.largeOffset) // TODO: offset from logo
            make.centerX.equalToSuperview()
        }
        
        setupCardView.snp.makeConstraints { (make) in
            make.top.equalTo(completeProfileLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(40)
        }
        
        setupCardView.makeView()
    }
    
    // MARK: Protocols
    
    func saveButtonTapped() {
        if setupCardView.occupation() == "" {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left
            let messageText = NSMutableAttributedString(
                string: "\nWhoops! Looks like your occupation is missing, please fill it in before saving and continuing.",
                attributes: [
                    NSParagraphStyleAttributeName: paragraphStyle,
                    NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote),
                    NSForegroundColorAttributeName : UIColor.black
                ]
            )
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.alignment = NSTextAlignment.center
            let titleText = NSMutableAttributedString(
                string: "Occupation Field Missing",
                attributes: [
                    NSParagraphStyleAttributeName: titleStyle,
                    NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
                    NSForegroundColorAttributeName : UIColor.black
                ]
            )
            let occupationFieldAlert = UIAlertController()
            occupationFieldAlert.setValue(titleText, forKey: "attributedTitle")
            occupationFieldAlert.setValue(messageText, forKey: "attributedMessage")
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            occupationFieldAlert.addAction(okAction)
            DispatchQueue.main.async {
                self.present(occupationFieldAlert, animated: true, completion:  nil)
            }
        } else {
            self.performSegue(withIdentifier: "profileComplete", sender: self)
        }
    }
    
    // MARK: Protocols
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! SecurityViewController
        let user = DexUser(name: name, interests: [])
        var card: Card
        if isPhone {
            var setupEmail = ""
            if setupCardView.hasEmail() {
                setupEmail = setupCardView.email()
            }
            if setupCardView.hasWebsite() {
                card = Card(user: user, occupation: setupCardView.occupation(), email: setupEmail, phones: [phone!], web: setupCardView.website(), avi: profilePic)
            } else {
                card = Card(user: user, occupation: setupCardView.occupation(), email: setupEmail, phones: [phone!], avi: profilePic)
            }
        } else {
            var phones: [Phone] = []
            if setupCardView.hasPhone() {
                phones.append(setupCardView.phone())
            }
            if setupCardView.hasWebsite() {
                card = Card(user: user, occupation: setupCardView.occupation(), email: email!, phones: phones, web: setupCardView.website(), avi: profilePic)
            } else {
                card = Card(user: user, occupation: setupCardView.occupation(), email: email!, phones: phones, avi: profilePic)
            }
        }
        
        vc.card = card
    }
}
