//
//  Utils.swift
//  Dex
//
//  Created by Felipe Campos on 12/26/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

import Foundation
import UIKit
import Firebase

public struct defaultKeys {
    static let loggedIn = "loggedInBool"
    static let displayName = "userDefaultName"
    static let displayOccupation = "userDefaultOccupation"
    static let userTokens = "loginTokens"
}

extension String {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}

/** A utility class. */
public class Utils {
    /** A regex pattern checking function.
     Returns whether OBJECT matches PATTERN. */
    static func regex(pattern: String, object: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            return regex.firstMatch(in: object,
                                    options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                    range: NSMakeRange(0, object.count)) != nil
        } catch {
            return false
        }
    }
    
    /** Formats SOURCEPHONENUMBER into an optional +1 (AAA) BBB-CCCC format,
     returning nil if SOURCEPHONENUMBER cannot be formatted according to assumptions.
     
     Taken from: https://stackoverflow.com/questions/32364055/formattting-phone-number-in-swift
     */
    static func format(phoneNumber sourcePhoneNumber: String) -> String? {
        // Remove any character that is not a number
        let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = numbersOnly.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")
        
        // Check for supported phone number length
        guard length == 7 || length == 10 || (length == 11 && hasLeadingOne) else {
            return nil
        }
        
        let hasAreaCode = (length >= 10)
        var sourceIndex = 0
        
        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "1 "
            sourceIndex += 1
        }
        
        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return nil
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }
        
        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return nil
        }
        sourceIndex += prefixLength
        
        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return nil
        }
        
        return leadingOne + areaCode + prefix + "-" + suffix
    }
    
    static func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: defaultKeys.loggedIn)
    }
    
    /** Returns the user associated with this ID. If unavailable, returns nil. */
    static func getUser(id: String) -> DexUser? {
        return nil // FIXME: implement with Firebase
    }
    
    /** The regex pattern for testing email validity. */
    static let EMAIL_REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}" // TODO: gotta test this bih
    
    /** The regex pattern for testing website validity. */
    static let WEB_REGEX = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?" // TODO: gotta test this bih too
    
    /** A prime constant used for calculating hash values. */
    static let HASH_PRIME = 16777619
    
    /** A default image. */
    static let defaultImage = UIImage()
    
    /** A constant denoting a small offset for constraints. */
    static let smallOffset = 5
    
    /** A constant denoting a medium offset for constraints. */
    static let mediumOffset = 10
    
    /** A constant denoting a large offset for constraints. */
    static let largeOffset = 20
    
    /** A constant denoting a huge offset for constraints. */
    static let hugeOffset = 40
    
    /** A separator for making a parseable string. */
    static let separator = "~|~"
    
    static let nullField = "" + Utils.separator
    
    // reference images in assets as vars here (e.g. let chicken = "Assets/chicken.png")
}
