//
//  ViewController.swift
//  Dex
//
//  Created by Felipe Campos on 8/8/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

import UIKit
import SnapKit
import Contacts
import CoreLocation
import Firebase
import SwiftSpinner

class ViewController: UIViewController, UIScrollViewDelegate, MultipeerManagerDelegate, CardViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var swipeLabel: UILabel!
    @IBOutlet var embeddedTableView: UIView!
    @IBOutlet var exchangeButton: UIButton!
    @IBOutlet var dexLogo: UIImageView!
    
    var ourUser: DexUser!
    var cardView: CardView!
    var cards: [Card] = []
    var cardIndex = 0
    // TODO: scroll vs send switch!!
    // TODO: have some sort of mini page controller for cards
    // TODO: implement swipe upward to constrast sideways mechanism (maybe lock card?) idk
    
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference(forURL: "gs://dex-app-89824.appspot.com/")
    let database = Database.database()
    let databaseRef = Database.database().reference()
    
    let multipeerService = MultipeerManager()
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        multipeerService.delegate = self
        
        embeddedTableView.isHidden = true
        exchangeButton.isHidden = true
        embeddedTableView.alpha = 0
        
        leftButton.isHidden = true
        rightButton.isHidden = true
        
        let cornerRadius: CGFloat = 8
        let shadowOffsetWidth: Int = 3
        let shadowOffsetHeight: Int = 5
        let shadowColor: UIColor? = UIColor.black
        let shadowOpacity: Float = 0.5
        
        self.embeddedTableView.layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: self.embeddedTableView.bounds, cornerRadius: cornerRadius)
        
        self.embeddedTableView.layer.masksToBounds = false
        self.embeddedTableView.layer.shadowColor = shadowColor?.cgColor
        self.embeddedTableView.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        self.embeddedTableView.layer.shadowOpacity = shadowOpacity
        self.embeddedTableView.layer.shadowPath = shadowPath.cgPath
        self.embeddedTableView.layer.masksToBounds = true
        
        if cards.count > 0 {
            cardView = CardView(card: cards[cardIndex])
            self.view.addSubview(cardView)
            
            cardView.delegate = self
            
            if cards.count > 1 {
                rightButton.isHidden = false
            }
        
            makeView()
        } else {
            let defaultName = UserDefaults.standard.value(forKey: defaultKeys.displayName) as! String
            let defaultOcc = UserDefaults.standard.value(forKey: defaultKeys.displayOccupation) as! String
            cardView = CardView(card: Card(name: defaultName, occupation: defaultOcc))
            self.view.addSubview(cardView)
            
            cardView.delegate = self
            
            makeView()
            
            handleLogin(user: Auth.auth().currentUser)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func leftButtonTapped(_ button: UIButton) {
        rightButton.isHidden = false
        cardIndex -= 1
        if cardIndex == 0 {
            leftButton.isHidden = true
        }
        
        cardView.setCard(card: cards[cardIndex])
    }
    
    func rightButtonTapped(_ button: UIButton) {
        leftButton.isHidden = false
        cardIndex += 1
        if cardIndex == cards.count - 1 {
            rightButton.isHidden = true
        }
        
        cardView.setCard(card: cards[cardIndex])
    }
    
    @IBAction func exchangeAction(_ sender: Any) {
        print("Hiding embedded views.")
        UIView.animate(withDuration: 0.5, delay: 1.0, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.embeddedTableView.alpha = 0.0
        }, completion: nil) // FIXME: not working
        embeddedTableView.isHidden = true
        exchangeButton.isHidden = true
        
        // multipeerService.send(card: currentCard())
    }
    
    // MARK: Methods
    
    private func handleLogin(user: User?) {
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
                    
                    self.ourUser = DexUser(name: name, influence: Double(inf)!)
                    
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
                                let card = Card(user: self.ourUser, occupation: occupation, email: email, phones: [phone], web: website, avi: image!)
                                self.cards.append(card)
                                
                                if i == numCards - 1 {
                                    DispatchQueue.main.async {
                                        self.cardView.setCard(card: card)
                                    
                                        self.leftButton.isHidden = true
                                        if self.cards.count > 1 {
                                            self.rightButton.isHidden = false
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
            })
        })
    }
    
    func sendViewCompletion(_ sender: UIButton) {
        // do whatever you want
        // make view disappear again or remove from its superview
    }
    
    func editingViewCompletion(_ sender: UIButton) {
        // do whatever you want
    }
    
    func currentCard() -> Card {
        return cards[cardIndex]
    }
    
    func makeView() {
        dexLogo.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Utils.hugeOffset * 2)
            make.centerX.equalToSuperview()
            make.height.equalTo(Utils.hugeOffset)
            make.width.equalTo(dexLogo.snp.height).multipliedBy(2.1 / 1.0)
        }
        
        welcomeLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(dexLogo.snp.bottom).offset(Utils.hugeOffset * 2)
            make.centerX.equalToSuperview()
            make.height.equalTo(welcomeLabel.font.lineHeight)
        }
        
        cardView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(Utils.largeOffset)
            make.left.equalToSuperview().offset(Utils.largeOffset)
            make.right.equalToSuperview().inset(Utils.largeOffset)
            make.height.equalTo(cardView.snp.width).multipliedBy(1.0 / 2.0)
        } // TODO: make fixed height??
        
        cardView.makeView()
        
        leftButton.addTarget(self, action: #selector(self.leftButtonTapped(_:)), for: .touchUpInside)
        leftButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(cardView.snp.centerY)
            make.left.equalToSuperview().offset(5)
            make.right.lessThanOrEqualTo(cardView.snp.left).inset(5)
        }
        
        rightButton.addTarget(self, action: #selector(self.rightButtonTapped(_:)), for: .touchUpInside)
        rightButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(cardView.snp.centerY)
            make.right.equalToSuperview().inset(5)
            make.left.greaterThanOrEqualTo(cardView.snp.right).offset(5)
        }
        
        swipeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(cardView.snp.bottom).offset(Utils.largeOffset)
            make.centerX.equalToSuperview()
            make.height.equalTo(swipeLabel.font.lineHeight)
        }
        
        embeddedTableView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.height.equalTo(self.view.snp.height).inset(150)
            make.top.equalTo(dexLogo.snp.bottom).offset(Utils.largeOffset)
        }
        
        exchangeButton.snp.makeConstraints { (make) in
            make.top.equalTo(embeddedTableView.snp.bottom).offset(Utils.smallOffset)
            make.centerX.equalToSuperview()
            // TODO: aspect ratio??
        }
    }
    
    // MARK: Protocols
    
    func connectedDevicesChanged(manager: MultipeerManager, connectedDevices: [String]) {
        // FIXME: implement
    }
    
    func cardReceived(manager: MultipeerManager, card: Card) {
        // FIXME: implement
    }
    
    func sendCard(card: Card) {
        print("Showing embedded views.")
        
        self.view.bringSubview(toFront: embeddedTableView)
        self.view.bringSubview(toFront: exchangeButton)
        embeddedTableView.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.embeddedTableView.alpha = 1.0
        }, completion: nil)
        exchangeButton.isHidden = false
    }
    
    func showStatistics(card: Card) {
        // FIXME: implement
    }
}

