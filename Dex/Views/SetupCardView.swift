//
//  SetupCardView.swift
//  Dex
//
//  Created by Felipe Campos on 12/30/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

import UIKit
import SnapKit

protocol SetupDelegate: class {
    func saveButtonTapped()
}

class SetupCardView: UIView, UITextFieldDelegate {
    
    // MARK: Properties
    
    private var _name: UILabel = UILabel()
    private var _profilePicture: UIImage = UIImage()
    private var _imageView: UIImageView = UIImageView()
    private var _occupationFieldTitle: UILabel = UILabel()
    private var _occupationField: UITextField = UITextField()
    private var _websiteFieldTitle: UILabel = UILabel()
    private var _websiteField: UITextField = UITextField()
    
    private var _phoneGiven: Bool = false
    private var _givenPhone: Phone?
    private var _givenEmail: String?
    
    private var _emailLabel: UILabel?
    private var _phoneLabel: UILabel?
    
    private var _emailFieldTitle: UILabel?
    private var _emailField: UITextField?
    private var _phoneFieldTitle: UILabel?
    private var _phoneField: UITextField?
    private var _savedPhone: Phone?
    
    private var validContactField: Bool = true
    
    private var _saveButton: UIButton = UIButton(type: .custom)
    
    weak var delegate: SetupDelegate?
    weak var textFieldDelegate: UITextFieldDelegate?
    
    private static let smallOffset = 5
    private static let mediumOffset = 10
    private static let largeOffset = 20
    
    @IBInspectable var cornerRadius: CGFloat = 8
    @IBInspectable var shadowOffsetWidth: Int = 3
    @IBInspectable var shadowOffsetHeight: Int = 5
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5
    
    // MARK: Initialization
    
    // TODO: Security section for required password / touch id / PIN
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 250, height: 500)
    }
    
    convenience init(name: String, phone: Phone, profilePic: UIImage) {
        self.init(name: name, profilePic: profilePic, frame: CGRect.zero)
        _givenPhone = phone
        _phoneGiven = true
        _phoneLabel = UILabel()
        if let num = Utils.format(phoneNumber: phone.number()) {
            _phoneLabel!.text = num
        } else {
            _phoneLabel!.text = phone.number()
        }
        self.addSubview(_phoneLabel!)
        
        _emailFieldTitle = UILabel()
        _emailField = UITextField()
        _emailFieldTitle!.text = "Email"
        self.addSubview(_emailFieldTitle!)
        self.addSubview(_emailField!)
    }
    
    convenience init(name: String, email: String, profilePic: UIImage) {
        self.init(name: name, profilePic: profilePic, frame: CGRect.zero)
        _givenEmail = email
        _phoneGiven = false
        _emailLabel = UILabel()
        _emailLabel!.text = email
        self.addSubview(_emailLabel!)
        
        _phoneFieldTitle = UILabel()
        _phoneField = UITextField()
        _phoneFieldTitle!.text = "Phone #"
        _phoneField!.addTarget(self, action: #selector(phoneNumberEdited(_:)), for: .editingDidEnd)
        _phoneField!.addTarget(self, action: #selector(phoneNumberStartedEditing(_:)), for: .editingDidBegin)
        self.addSubview(_phoneFieldTitle!)
        self.addSubview(_phoneField!)
    }
    
    init(name: String, profilePic: UIImage, frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        _name.text = name
        _profilePicture = profilePic
        
        self.addSubview(_name)
        
        _imageView.image = _profilePicture
        self.addSubview(_imageView)
        
        _occupationFieldTitle.text = "Occupation (*)" // TODO: caps
        _occupationField.addTarget(self, action: #selector(occupationEdited(_:)), for: .editingDidEnd)
        self.addSubview(_occupationFieldTitle)
        self.addSubview(_occupationField)
        
        _websiteFieldTitle.text = "Website" // TODO: caps
        self.addSubview(_websiteFieldTitle)
        self.addSubview(_websiteField)
        
        _saveButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        _saveButton.setImage(UIImage(named: "save"), for: .normal)
        _saveButton.isHidden = true
        _saveButton.addTarget(self, action: #selector(self.saveTapped(_:)), for: .touchUpInside)
        self.addSubview(_saveButton)
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
    
    func saveTapped(_ button: UIButton) {
        self.delegate?.saveButtonTapped()
    }
    
    func phoneNumberEdited(_ sender: UITextField) {
        self.savePhone()
    }
    
    func phoneNumberStartedEditing(_ sender: UITextField) {
        if let phone = _savedPhone {
            _phoneField!.text = phone.number()
        }
    }
    
    func occupationEdited(_ sender: UITextField) {
        if hasOccupation() && validContactField {
            _saveButton.isHidden = false
        } else {
            _saveButton.isHidden = true
        }
    }
    
    func emailFieldEdited(_ sender: UITextField) {
        // check if phone number is valid (regex) -> set text field color to red if invalid
        if hasEmail() && !Utils.regex(pattern: Utils.EMAIL_REGEX, object: _emailField!.text!) {
            validContactField = false
            _emailField!.backgroundColor = .red
        } else {
            validContactField = true
            _emailField!.backgroundColor = .white
        }
    }
    
    func websiteFieldEdited(_ sender: UITextField) {
        // check if website is valid (regex) -> set text field color to red if invalid
    }
    
    // MARK: Methods
    
    func hasOccupation() -> Bool {
        return _occupationField.hasText
    }
    
    func occupation() -> String {
        return _occupationField.text!
    }
    
    func hasWebsite() -> Bool {
        return _websiteField.hasText // FIXME: regex for validity
    }
    
    func website() -> String {
        return _websiteField.text!
    }
    
    func hasEmail() -> Bool {
        return _emailField!.hasText // FIXME: regex for validity
    }
    
    func email() -> String {
        return _emailField!.text!
    }
    
    func hasPhone() -> Bool {
        return _phoneField!.hasText // FIXME: regex for validity
    }
    
    func savePhone() {
        let phoneNumber = _phoneField!.text!
        _savedPhone = Phone(number: phoneNumber, kind: .other)
        if let formatted = Utils.format(phoneNumber: phoneNumber) {
            _phoneField!.text = formatted
        }
    }
    
    func phone() -> Phone {
        return _savedPhone!
    }
    
    func makeView() {
        if _phoneGiven {
            makeView(phone: _givenPhone!)
        } else {
            makeView(email: _givenEmail!)
        }
    }
    
    private func makeView(phone: Phone) {
        makeView(phone: phone, email: nil)
    }
    
    private func makeView(email: String) {
        makeView(phone: nil, email: email)
    }
    
    private func makeView(phone: Phone?, email: String?) {
        // TODO: setup for multiple lines
        
        _name.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(Utils.mediumOffset)
            make.left.equalTo(self).offset(Utils.mediumOffset)
            make.right.lessThanOrEqualTo(_imageView.snp.left).inset(Utils.smallOffset)
            make.height.equalTo(_name.font.lineHeight)
        }
        
        _name.sizeToFit()
        
        var topConstraint: ConstraintItem
        var contactLabelHeight: CGFloat
        if phone != nil {
            _phoneLabel!.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(_name.snp.bottom).offset(Utils.mediumOffset)
                make.left.equalTo(self).offset(Utils.mediumOffset)
                make.right.equalTo(self).inset(Utils.mediumOffset)
                make.height.equalTo(_phoneLabel!.font.lineHeight)
            }
            topConstraint = _phoneLabel!.snp.bottom
            contactLabelHeight = _phoneLabel!.font.lineHeight
        } else {
            _emailLabel!.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(_name.snp.bottom).offset(Utils.mediumOffset)
                make.left.equalTo(self).offset(Utils.mediumOffset)
                make.right.equalTo(self).inset(Utils.mediumOffset)
                make.height.equalTo(_emailLabel!.font.lineHeight)
            }
            topConstraint = _emailLabel!.snp.bottom
            contactLabelHeight = _emailLabel!.font.lineHeight
        }
        
        _imageView.layer.cornerRadius = _imageView.frame.height / 2
        _imageView.clipsToBounds = true
        
        _imageView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(Utils.mediumOffset)
            make.left.greaterThanOrEqualTo(_name.snp.right).offset(Utils.smallOffset)
            make.width.equalTo(_name.font.lineHeight + CGFloat(Utils.mediumOffset) + contactLabelHeight)
            make.right.equalTo(self).inset(Utils.mediumOffset)
            make.bottom.equalTo(topConstraint)
        }
        
        _occupationFieldTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topConstraint).offset(Utils.largeOffset)
            make.left.equalTo(self).offset(Utils.mediumOffset)
            make.right.equalTo(self).inset(Utils.mediumOffset)
            make.height.equalTo(_occupationFieldTitle.font.lineHeight)
        }
        _occupationField.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(_occupationFieldTitle.snp.bottom).offset(Utils.smallOffset)
            make.left.equalTo(self).offset(Utils.mediumOffset)
            make.right.equalTo(self).inset(Utils.mediumOffset)
            make.height.equalTo(_occupationField.font!.lineHeight)
        }
        
        if phone == nil {
            _phoneFieldTitle!.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(_occupationField.snp.bottom).offset(Utils.mediumOffset)
                make.left.equalTo(self).offset(Utils.mediumOffset)
                make.right.equalTo(self).inset(Utils.mediumOffset)
                make.height.equalTo(_phoneFieldTitle!.font.lineHeight)
            }
            _phoneField!.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(_phoneFieldTitle!.snp.bottom).offset(Utils.smallOffset)
                make.left.equalTo(self).offset(Utils.mediumOffset)
                make.right.equalTo(self).inset(Utils.mediumOffset)
                make.height.equalTo(_phoneField!.font!.lineHeight)
            }
            topConstraint = _phoneField!.snp.bottom
        } else {
            _emailFieldTitle!.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(_occupationField.snp.bottom).offset(Utils.mediumOffset)
                make.left.equalTo(self).offset(Utils.mediumOffset)
                make.right.equalTo(self).inset(Utils.mediumOffset)
                make.height.equalTo(_emailFieldTitle!.font.lineHeight)
            }
            _emailField!.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(_emailFieldTitle!.snp.bottom).offset(Utils.smallOffset)
                make.left.equalTo(self).offset(Utils.mediumOffset)
                make.right.equalTo(self).inset(Utils.mediumOffset)
                make.height.equalTo(_emailField!.font!.lineHeight)
            }
            topConstraint = _emailField!.snp.bottom
        }
        
        _websiteFieldTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topConstraint).offset(Utils.mediumOffset)
            make.left.equalTo(self).offset(Utils.mediumOffset)
            make.right.equalTo(self).inset(Utils.mediumOffset)
            make.height.equalTo(_websiteFieldTitle.font.lineHeight)
        }
        _websiteField.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(_websiteFieldTitle.snp.bottom).offset(Utils.smallOffset)
            make.left.equalTo(self).offset(Utils.mediumOffset)
            make.right.equalTo(self).inset(Utils.mediumOffset)
            make.height.equalTo(_websiteField.font!.lineHeight)
        }
        
        _saveButton.snp.makeConstraints { (make) -> Void in
            make.top.greaterThanOrEqualTo(_websiteField.snp.bottom).offset(Utils.largeOffset)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).inset(Utils.largeOffset)
        }
        
        makeOccupationField(example: "Developer, Photographer, etc.")
        if phone != nil {
            makeEmailField(example: "chris@dex.com")
        } else {
            makePhoneField(example: "(415) 555-5555")
        }
        makeWebsiteField(example: "www.dex.com")
    }
    
    private func makeOccupationField(example: String) {
        _occupationField.placeholder = "e.g. \(example)"
        _occupationField.autocapitalizationType = .words
        _occupationField.font = UIFont.systemFont(ofSize: 15)
        _occupationField.borderStyle = UITextBorderStyle.roundedRect
        _occupationField.autocorrectionType = UITextAutocorrectionType.no
        _occupationField.keyboardType = UIKeyboardType.default
        _occupationField.returnKeyType = UIReturnKeyType.done
        _occupationField.clearButtonMode = UITextFieldViewMode.whileEditing
        _occupationField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        _occupationField.delegate = textFieldDelegate!
    }
    
    private func makePhoneField(example: String) {
        _phoneField!.placeholder = "e.g. \(example)"
        _phoneField!.font = UIFont.systemFont(ofSize: 15)
        _phoneField!.borderStyle = UITextBorderStyle.roundedRect
        _phoneField!.autocorrectionType = UITextAutocorrectionType.no
        _phoneField!.keyboardType = UIKeyboardType.phonePad
        _phoneField!.returnKeyType = UIReturnKeyType.done
        _phoneField!.clearButtonMode = UITextFieldViewMode.whileEditing
        _phoneField!.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        _phoneField!.delegate = textFieldDelegate!
    }
    
    private func makeEmailField(example: String) {
        _emailField!.placeholder = "e.g. \(example)"
        _emailField!.autocapitalizationType = .none
        _emailField!.font = UIFont.systemFont(ofSize: 15)
        _emailField!.borderStyle = UITextBorderStyle.roundedRect
        _emailField!.autocorrectionType = UITextAutocorrectionType.no
        _emailField!.keyboardType = UIKeyboardType.emailAddress
        _emailField!.returnKeyType = UIReturnKeyType.done
        _emailField!.clearButtonMode = UITextFieldViewMode.whileEditing
        _emailField!.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        _emailField!.delegate = textFieldDelegate!
    }
    
    private func makeWebsiteField(example: String) {
        _websiteField.placeholder = "e.g. \(example)"
        _websiteField.autocapitalizationType = .none
        _websiteField.font = UIFont.systemFont(ofSize: 15)
        _websiteField.borderStyle = UITextBorderStyle.roundedRect
        _websiteField.autocorrectionType = UITextAutocorrectionType.no
        _websiteField.keyboardType = UIKeyboardType.URL
        _websiteField.returnKeyType = UIReturnKeyType.done
        _websiteField.clearButtonMode = UITextFieldViewMode.whileEditing
        _websiteField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        _websiteField.delegate = textFieldDelegate!
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
