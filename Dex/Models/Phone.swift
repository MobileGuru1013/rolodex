//
//  Phone.swift
//  Dex
//
//  Created by Felipe Campos on 12/25/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

import Foundation

/** A phone class. */
internal class Phone: Equatable, Hashable {
    
    enum Kind {
        case home
        case work
        case mobile
        case fax
        case pager
        case other
    }
    
    // MARK: Properties
    
    /** The phone number. */
    private var _number: String
    
    /** The phone type. */
    private var _type: Phone.Kind
    
    /** The validity of the phone. */
    private lazy var _valid: Bool = {
        return self.check(isLazy: true)
    }()
    
    /** The regex pattern for testing the phone number validity. */
    private static let REGEX = "*" // TODO: fill in phone regex, test
    
    // MARK: Initialization
    
    init(number: String, kind: Phone.Kind) {
        _number = number
        _type = kind
    }
    
    // MARK: - Methods
    
    /** Returns the phone number. */
    func number() -> String {
        return _number
    }
    
    /** Returns a potentially formatted version of the phone's number. */
    func formatted() -> String {
        let format = Utils.format(phoneNumber: _number)
        if format != nil {
            return format!
        }
        
        return _number
    }
    
    /** Returns the phone type (home, mobile, etc.). */
    func type() -> Phone.Kind {
        return _type
    }
    
    /** Checks and returns whether the phone is valid. */
    func check() -> Bool {
        return check(isLazy: false)
    }
    
    /** Checks and returns whether the phone is valid.
    If !ISLAZY, sets valid field. */
    private func check(isLazy: Bool) -> Bool {
        let result = Utils.regex(pattern: Phone.REGEX, object: _number)
        
        if !isLazy {
            _valid = result
        }
        
        return result
    }
    
    /** Returns whether the phone is valid. */
    func isValid() -> Bool {
        return _valid
    }
    
    // MARK: Protocols
    
    static func ==(lhs: Phone, rhs: Phone) -> Bool {
        return lhs.number() == rhs.number() && lhs.type() == rhs.type()
    }
    
    /** Combines the hash value of each non-nil property
     multiplied by a prime constant. */
    var hashValue: Int {
        return _number.hashValue ^ _type.hashValue ^ _valid.hashValue &* Utils.HASH_PRIME
    }
}
