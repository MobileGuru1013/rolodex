//
//  CardView.swift
//  Dex
//
//  Created by Felipe Campos on 12/19/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

import UIKit
import SnapKit
// import Shiny

protocol CardViewDelegate: class {
    func sendCard(card: Card)
    func showStatistics(card: Card)
}

/** A card view class. */
@IBDesignable
class CardView: UIView {
    
    // MARK: Properties
    
    private var _card: Card
    private var _name: UILabel = UILabel()
    private var _occupation: UILabel = UILabel()
    private var _email: UILabel?
    private var _phone: UILabel?
    private var _website: UILabel?
    private var _profilePicture: UIImage?
    private var _imageView: UIImageView = UIImageView()
    
    private var _editButton: UIButton = UIButton()
    
    var delegate: CardViewDelegate?
    
    @IBInspectable var cornerRadius: CGFloat = 8
    @IBInspectable var shadowOffsetWidth: Int = 3
    @IBInspectable var shadowOffsetHeight: Int = 5
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5
    
    // MARK: Initialization
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 250, height: 150)
    }
    
    convenience init(card: Card) {
        self.init(card: card, frame: CGRect.zero)
    }
    
    init(card: Card, frame: CGRect) {
        _card = card
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        _name.text = card.user().name()
        self.addSubview(_name)
        
        _occupation.text = card.occupation()
        self.addSubview(_occupation)
        
        if card.hasPhoneNumbers() {
            _phone = UILabel()
            _phone!.text = card.primaryPhone().formatted()
            self.addSubview(_phone!)
        }
        
        if card.hasEmail() {
            _email = UILabel()
            _email!.text = card.email()
            self.addSubview(_email!)
        }
        
        if card.hasWebsite() {
            _website = UILabel()
            _website!.text = card.website()
            self.addSubview(_website!)
        }
        
        if card.hasProfilePicture() {
            _profilePicture = card.profilePicture()
            _imageView.image = _profilePicture!
        }
        _imageView.layer.cornerRadius = _imageView.frame.height / 2
        _imageView.layer.masksToBounds = true
        self.addSubview(_imageView)
        
        _editButton.backgroundColor = UIColor.clear
        _editButton.tintColor = UIColor.blue
        _editButton.setTitle("Edit", for: .normal)
        _editButton.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        self.addSubview(_editButton)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.addGestureRecognizer(swipeDown)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
    // MARK: Actions
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) { // FIXME:
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right.")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down, showing card statistics.")
                self.delegate?.showStatistics(card: card())
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left.")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up, preparing card for sharing.")
                self.delegate?.sendCard(card: card())
            default:
                break
            }
        }
    }
    
    // MARK: Methods
    
    /** Returns this view's card. */
    func card() -> Card {
        return _card
    }
    
    /** Sets the view's card to CARD and remakes the view. */
    func setCard(card: Card) {
        _card = card
        
        _name.text = card.user().name()
        self.addSubview(_name)
        
        _occupation.text = card.occupation()
        self.addSubview(_occupation)
        
        if card.hasPhoneNumbers() {
            _phone = UILabel()
            _phone!.text = card.primaryPhone().formatted()
            self.addSubview(_phone!)
        }
        
        if card.hasEmail() {
            _email = UILabel()
            _email!.text = card.email()
            self.addSubview(_email!)
        }
        
        if card.hasWebsite() {
            _website = UILabel()
            _website!.text = card.website()
            self.addSubview(_website!)
        }
        
        if card.hasProfilePicture() {
            _profilePicture = card.profilePicture()
            _imageView.image = _profilePicture!
        }
        _imageView.layer.cornerRadius = _imageView.frame.height / 2
        _imageView.layer.masksToBounds = true
        self.addSubview(_imageView)
        
        makeView(card: card)
    }
    
    /** Makes the CardView with constraints. */
    func makeView() {
        makeView(card: _card)
    }
    
    /** Makes the CardView given CARD. */
    private func makeView(card: Card) { // FIXME: make bottom and right INSETS
        _name.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(Utils.mediumOffset)
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.lessThanOrEqualTo(_imageView.snp.left).inset(Utils.smallOffset)
            make.height.equalTo(_name.font.lineHeight)
        }
        
        _imageView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(Utils.mediumOffset)
            make.left.greaterThanOrEqualTo(_name.snp.right).offset(Utils.smallOffset)
            make.width.equalTo(_name.font.lineHeight + CGFloat(Utils.largeOffset))
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.bottom.equalTo(_name.snp.bottom).offset(Utils.largeOffset)
        }
        
        var topTarget: ConstraintItem = _name.snp.bottom
        
        _occupation.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topTarget).offset(Utils.largeOffset)
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.height.equalTo(_occupation.font.lineHeight)
        }
        
        var bottomItem: ConstraintViewDSL = _occupation.snp
        topTarget = bottomItem.bottom
        
        if card.hasPhoneNumbers() {
            _phone!.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(topTarget).offset(Utils.mediumOffset)
                make.left.equalToSuperview().offset(Utils.mediumOffset)
                make.right.equalToSuperview().inset(Utils.mediumOffset)
                make.height.equalTo(_phone!.font!.lineHeight)
            }
            
            bottomItem = _phone!.snp
            topTarget = bottomItem.bottom
            
            /*
             var text: String = ""
             for phone in card.phones() {
                text.append(phone.number() + "(\(phone.type()))\n")
             }
             text.remove(at: text.endIndex)
             _phones!.text = text
             */
        }
        
        if card.hasEmail() {
            _email!.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(topTarget).offset(Utils.mediumOffset)
                make.left.equalToSuperview().offset(Utils.mediumOffset)
                make.right.equalToSuperview().inset(Utils.mediumOffset)
                make.height.equalTo(_email!.font!.lineHeight)
            }
            
            bottomItem = _email!.snp
            topTarget = bottomItem.bottom
        }
        
        if card.hasWebsite() {
            _website!.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(topTarget).offset(Utils.mediumOffset)
                make.left.equalToSuperview().offset(Utils.mediumOffset)
                make.right.equalToSuperview().inset(Utils.mediumOffset)
                make.height.equalTo(_website!.font!.lineHeight)
            }
            
            bottomItem = _website!.snp
            topTarget = bottomItem.bottom
        }
        
        _editButton.snp.makeConstraints { (make) -> Void in
            make.bottom.equalToSuperview().inset(Utils.smallOffset)
            make.right.equalToSuperview().offset(Utils.smallOffset)
            make.width.equalTo(50)
            make.height.equalTo(25)
        }
        
        /*
        
        let shinyView = ShinyView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        shinyView.colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.gray]
        shinyView.locations = [0, 0.1, 0.2, 0.3, 1] // FIXME: test locations
        shinyView.startUpdates() // necessary
        self.addSubview(shinyView) // make shiny
        
        */
    }
    
    func editAction(sender: UIButton!) { // FIXME:
        // TODO: show pop-up view that edits card properties
        print("Editing")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
