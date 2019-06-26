//
//  SecuritySetUpCardView.swift
//  Dex
//
//  Created by Felipe Campos on 1/24/18.
//  Copyright © 2018 Orange Inc. All rights reserved.
//

import UIKit
// import LocalAuthentication

protocol SecurityViewDelegate: class {
    func saveButtonTapped()
}

class SecuritySetUpCardView: UIView {

    // MARK: Properties
    
    private var _passwordFieldLabel: UILabel = UILabel()
    private var _passwordField: UITextField = UITextField()
    private var _confirmPasswordFieldLabel: UILabel = UILabel()
    private var _confirmPasswordField: UITextField = UITextField()
    
    private var _passwordsMatchWarning: UILabel = UILabel()
    private let countWarning = "Passwords must have more than 5 characters."
    private let matchWarning = "Passwords must match."
    
    private var _saveButton: UIButton = UIButton(type: .custom)
    
    weak var delegate: SecurityViewDelegate?
    weak var textFieldDelegate: UITextFieldDelegate?
    
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
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        _passwordFieldLabel.text = "Your password (*)"
        _confirmPasswordFieldLabel.text = "Confirm your password (*)"
        _passwordField.addTarget(self, action: #selector(passwordEdited(_:)), for: .editingDidEnd)
        _confirmPasswordField.addTarget(self, action: #selector(confirmEdited(_:)), for: .editingDidEnd)
        self.addSubview(_passwordFieldLabel)
        self.addSubview(_passwordField)
        self.addSubview(_confirmPasswordFieldLabel)
        self.addSubview(_confirmPasswordField)
        
        _passwordsMatchWarning.text = countWarning
        _passwordsMatchWarning.adjustsFontSizeToFitWidth = true
        _passwordsMatchWarning.textColor = .red
        _passwordsMatchWarning.isHidden = true
        self.addSubview(_passwordsMatchWarning)
        
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
    
    func passwordEdited(_ sender: UITextField) {
        passwordCheck()
    }
    
    func confirmEdited(_ sender: UITextField) {
        passwordCheck()
    }
    
    // MARK: Methods
    
    func passwordCheck() {
        if passwordsMatch() {
            _saveButton.isHidden = false
            _passwordsMatchWarning.isHidden = true
        } else {
            _saveButton.isHidden = true
            if !validPassword() {
                _passwordsMatchWarning.text = countWarning
                _passwordsMatchWarning.isHidden = false
            } else if hasConfirmation() {
                _passwordsMatchWarning.text = matchWarning
                _passwordsMatchWarning.isHidden = false
            } else {
                _passwordsMatchWarning.isHidden = true
            }
        }
    }
    
    func passwordsMatch() -> Bool {
        return validPassword() && password() == confirm()
    }
    
    func validPassword() -> Bool {
        return password().count > 5
    }
    
    func hasPassword() -> Bool {
        return _passwordField.hasText
    }
    
    func password() -> String {
        return _passwordField.text!
    }
    
    func hasConfirmation() -> Bool {
        return _confirmPasswordField.hasText
    }
    
    func confirm() -> String {
        return _confirmPasswordField.text!
    }
    
    func makeView() {
        _passwordFieldLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Utils.mediumOffset)
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.height.equalTo(_passwordFieldLabel.font.lineHeight)
        }
        
        _passwordField.snp.makeConstraints { (make) in
            make.top.equalTo(_passwordFieldLabel.snp.bottom).offset(Utils.mediumOffset)
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.height.equalTo(_passwordField.font!.lineHeight)
        }
        
        _confirmPasswordFieldLabel.snp.makeConstraints { (make) in
            make.top.equalTo(_passwordField.snp.bottom).offset(Utils.largeOffset)
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.height.equalTo(_passwordFieldLabel.font.lineHeight)
        }
        
        _confirmPasswordField.snp.makeConstraints { (make) in
            make.top.equalTo(_confirmPasswordFieldLabel.snp.bottom).offset(Utils.mediumOffset)
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.height.equalTo(_passwordField.font!.lineHeight)
        }
        
        _passwordsMatchWarning.snp.makeConstraints { (make) in
            make.top.equalTo(_confirmPasswordField.snp.bottom).offset(Utils.mediumOffset)
            make.left.equalToSuperview().offset(Utils.mediumOffset)
            make.right.equalToSuperview().inset(Utils.mediumOffset)
            make.height.equalTo(_passwordsMatchWarning.font.lineHeight)
        }
        
        _saveButton.snp.makeConstraints { (make) -> Void in
            make.top.greaterThanOrEqualTo(_passwordsMatchWarning.snp.bottom).offset(Utils.largeOffset)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(Utils.largeOffset)
        }
        
        makePasswordField()
        makeConfirmationField()
    }
    
    private func makePasswordField() {
        _passwordField.autocapitalizationType = .none
        _passwordField.font = UIFont.systemFont(ofSize: 15)
        _passwordField.borderStyle = UITextBorderStyle.roundedRect
        _passwordField.autocorrectionType = UITextAutocorrectionType.no
        _passwordField.keyboardType = UIKeyboardType.default
        _passwordField.returnKeyType = UIReturnKeyType.done
        _passwordField.clearButtonMode = UITextFieldViewMode.whileEditing
        _passwordField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        _passwordField.isSecureTextEntry = true
        _passwordField.delegate = textFieldDelegate!
    }
    
    private func makeConfirmationField() {
        _confirmPasswordField.autocapitalizationType = .none
        _confirmPasswordField.font = UIFont.systemFont(ofSize: 15)
        _confirmPasswordField.borderStyle = UITextBorderStyle.roundedRect
        _confirmPasswordField.autocorrectionType = UITextAutocorrectionType.no
        _confirmPasswordField.keyboardType = UIKeyboardType.default
        _confirmPasswordField.returnKeyType = UIReturnKeyType.done
        _confirmPasswordField.clearButtonMode = UITextFieldViewMode.whileEditing
        _confirmPasswordField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        _confirmPasswordField.isSecureTextEntry = true
        _confirmPasswordField.delegate = textFieldDelegate!
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
