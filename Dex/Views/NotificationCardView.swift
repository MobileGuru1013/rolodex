//
//  NotificationCardView.swift
//  Dex
//
//  Created by Felipe Campos on 12/28/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

// TODO: have ad view pop up every once in a while
// TODO: work on rectangular cube vertical rotation animation for this when changing notification
// TODO: OR have options for transitions like sliding or whatever

import UIKit

/** A notification card view class. */
@IBDesignable
class NotificationCardView: UIView {
    
    // MARK: Properties
    
    private var _titleLabel: UILabel = UILabel()
    private var _title: String = ""
    private var _noteLabel: UILabel = UILabel()
    private var _note: String = ""
    private var _timeLabel: UILabel?
    private var _time: String?
    private var _imageView: UIImageView?
    private var _image: UIImage = UIImage()
    
    private var _frame: CGRect = CGRect.zero
    
    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5
    
    // MARK: Initialization
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 250, height: 50)
    }
    
    convenience init(title: String, note: String, time: String) {
        self.init(title: title, note: note, frame: CGRect.zero)
        _timeLabel = UILabel()
        _timeLabel!.text = time
    }
    
    convenience init(title: String, note: String, time: String, img: UIImage) {
        self.init(title: title, note: note, img: img, frame: CGRect.zero)
        _timeLabel = UILabel()
        _timeLabel!.text = time
    }
    
    convenience init(title: String, note: String) {
        self.init(title: title, note: note, frame: CGRect.zero)
    }
    
    convenience init(title: String, note: String, img: UIImage, frame: CGRect) {
        self.init(title: title, note: note, frame: frame)
        _image = img
    }
    
    init(title: String, note: String, frame: CGRect) {
        super.init(frame: frame)
        _title = title
        _note = note
        _frame = frame
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
    
    // MARK: Methods
    
    func makeView(hasImage: Bool) {
        if hasImage {
            makeView(title: _title, note: _note, img: _image, frame: _frame)
        } else {
            makeView(title: _title, note: _note, frame: _frame)
        }
    }
    
    private func makeView(title: String, note: String, img: UIImage, frame: CGRect) { // FIXME: insets/offsets
        makeView(title: title, note: note, frame: frame)
        
        _imageView = UIImageView(image: img)
        _imageView!.layer.cornerRadius = _imageView!.frame.height / 2
        _imageView!.layer.masksToBounds = true
        self.addSubview(_imageView!)
        
        _imageView!.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(_titleLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(5)
            make.left.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
        }
    }
    
    private func makeView(title: String, note: String, frame: CGRect) {
        _titleLabel.text = title
        self.addSubview(_titleLabel)
        
        _titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(5)
        }
        
        _noteLabel.text = note
        self.addSubview(_noteLabel)
        
        _noteLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(_titleLabel.snp.bottom).offset(5)
            make.right.equalTo(self.snp.left).offset(-5)
            make.left.equalToSuperview().offset(5 + _imageView!.frame.size.width + 5)
            make.bottom.equalToSuperview().offset(-5)
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
