//
//  Card.swift
//  Dex
//
//  Created by Felipe Campos on 12/18/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

import Foundation
import UIKit

/** A card class denoting a user's information. */
internal class Card: Equatable, Comparable, Hashable {
    
    // MARK: Properties
    
    /** The card's user. */
    private var _user: DexUser
    
    /** The card's location. */
    private var _location: String?
    
    /** The card's occupation. */
    private var _occupation: String
    
    /** The card's email. */
    private var _email: String = ""
    
    /** The card's phones. */
    private var _phones: [Phone] = []
    
    /** The card's website. */
    private var _website: String = ""
    
    /** The card's avi. */
    private var _avi: UIImage
    
    /** The card's priority. */
    private var _priority: Int = 0
    
    // MARK: Initialization
    
    convenience init(user: DexUser, location: String, occupation: String,
                     email: String, phones: [Phone], web: String, avi: UIImage) {
        self.init(user: user, occupation: occupation,
                  email: email, phones: phones, web: web, avi: avi)
        _location = location
    }
    
    convenience init(user: DexUser, location: String, occupation: String,
                     email: String, phones: [Phone], avi: UIImage) {
        self.init(user: user, occupation: occupation, email: email, phones: phones, avi: avi)
        _location = location
    }
    
    convenience init(user: DexUser, occupation: String, email: String, phones: [Phone], web: String, avi: UIImage) {
        self.init(user: user, occupation: occupation, email: email, phones: phones, avi: avi)
        _website = web
    }
    
    init(user: DexUser, occupation: String, email: String, phones: [Phone], avi: UIImage) {
        _user = user
        _occupation = occupation
        _email = email
        _avi = avi
        
        for phone in phones {
            _phones.append(phone)
        }
        
        user.addCard(card: self)
    }
    
    init(name: String, occupation: String) {
        _user = DexUser(name: name, influence: 0.0)
        _occupation = occupation
        
        _avi = Utils.defaultImage
    }
    
    // MARK: - Methods
    
    /** Returns the decoded card from DECODEABLE. Returns nil if unparseable. */
    static func decode(decodeable: String) -> Card? {
        let components = decodeable.components(separatedBy: Utils.separator)
        var user: DexUser
        if let tmp = Utils.getUser(id: components[0]) {
            user = tmp
        } else {
            user = DexUser(name: components[1], influence: Double(components[2])!)
        }
        let occupation = components[3]
        let location = components[4]
        let email = components[5]
        let numPhones = Int(components[6])!
        var phones: [Phone] = []
        for i in 0..<numPhones {
            phones.append(Phone(number: components[7+i], kind: .other))
        }
        let website = components[8]
        let profilePictureData = components[9].data(using: .utf8)!
        
        let img = UIImage(data: profilePictureData)!
        
        var card: Card
        if website == "" && location == "" {
            card = Card(user: user, occupation: occupation, email: email, phones: phones, avi: img)
        } else if location == "" {
            card = Card(user: user, occupation: occupation, email: email, phones: phones, web: website, avi: img)
        } else if website == "" {
            card = Card(user: user, location: location, occupation: occupation, email: email, phones: phones, avi: img)
        } else {
            card = Card(user: user, location: location, occupation: occupation, email: email, phones: phones, web: website, avi: img)
        }
        
        user.addCard(card: card)
        
        print(user.hashValue == Int(components[0]))
        
        return card
    }
    
    /** Returns a unique decodeable string for this card. */
    func encode() -> String {
        let sep = Utils.separator
        var str = String(user().hashValue) + sep
        str += user().name() + sep
        str += String(user().influence()) + sep + occupation() + sep
        if hasLocation() {
            str += location() + sep
        } else {
            str += Utils.nullField
        }
        
        if hasEmail() {
            str += email() + sep
        } else {
            str += Utils.nullField
        }
        
        if _phones.count > 0 {
            str += String(_phones.count) + sep
            for phone in _phones {
                str += phone.number() + sep // TODO: include phone type
            }
        } else {
            str += Utils.nullField
        }
        
        if hasWebsite() {
            str += website() + sep
        } else {
            str += Utils.nullField
        }
        
        if hasProfilePicture() {
            str += profilePictureData() + sep
        } else {
            str += Utils.nullField
        }
        
        return str
    }
    
    /** Returns the user associated with this card. */
    func user() -> DexUser {
        return _user
    }
    
    /** Returns the occupation associated with this card. */
    func occupation() -> String {
        return _occupation
    }
    
    /** Sets the occupation for this card as OCC.
        Returns whether the contents were modified.
     */
    func setOccupation(occ: String) -> Bool {
        let o = _occupation
        _occupation = occ
        return o != occ
    }
    
    /** Returns whether the card contains a non-nil location. */
    func hasLocation() -> Bool {
        return _location != nil
    }
    
    /** Returns the location associated with this card. */
    func location() -> String {
        return _location!
    }
    
    /** Sets the location for this card as LOC.
     Returns whether the contents were modified.
     */
    func setLocation(loc: String) -> Bool {
        let l = _location
        _location = loc
        return l != nil && l != loc
    }
    
    /** Returns whether the card has an email. */
    func hasEmail() -> Bool {
        return _email != ""
    }
    
    /** Returns the optional email associated with this card. */
    func email() -> String {
        return _email
    }
    
    /** Sets the email for this card as EMAIL.
        Returns whether the email is valid.
     */
    func setEmail(email: String) -> Bool {
        if validEmail(email: email) {
            _email = email
            return true
        }
        
        return false
    }
    
    /** Returns whether EMAIL is a valid email. */
    func validEmail(email: String) -> Bool {
        return Utils.regex(pattern: Utils.EMAIL_REGEX, object: email)
    }
    
    /** Returns whether the card has a website. */
    func hasWebsite() -> Bool {
        return _website != ""
    }
    
    /** Returns the optional website associated with this card. */
    func website() -> String {
        return _website
    }
    
    /** Sets the website for this card, if valid.
        Returns whether the website was set.
     */
    func setWebsite(site: String) -> Bool {
        if validWebsite(site: site) {
            _website = site
            return true
        }
        
        return false
    }
    
    /** Returns whether SITE is a valid url. */
    func validWebsite(site: String) -> Bool {
        return Utils.regex(pattern: Utils.WEB_REGEX, object: site)
    }
    
    /** Returns whether the card has any phone numbers. */
    func hasPhoneNumbers() -> Bool {
        return _phones.count > 0
    }
    
    /** Returns an array of the phone numbers associated with this card. */
    func phones() -> [Phone] {
        return _phones
    }
    
    /** Returns this card's primary phone. */
    func primaryPhone() -> Phone {
        return _phones[0]
    }
    
    /** Adds PHONE to the phones associated with this card, if valid.
        Returns whether the phone was successfully added
     */
    func addPhone(phone: Phone) -> Bool {
        if phone.isValid() && !_phones.contains(phone) {
            _phones.append(phone)
            return true
        }
        
        return false
    }
    
    /** Removes PHONE from the phones associated with this card.
        Returns whether the phone was successfully removed.
     */
    func removePhone(phone: Phone) -> Bool {
        if _phones.contains(phone) {
            let ind = _phones.index(of: phone)
            _phones.remove(at: ind!)
            return true
        }
        
        return false
    }
    
    /** Returns whether the card has a profile picture. */
    func hasProfilePicture() -> Bool {
        return _avi != Utils.defaultImage
    }
    
    /** Returns the optional profile picture associated with this card. */
    func profilePicture() -> UIImage {
        return _avi
    }
    
    /** Returns a string of formatted data representing the profile picture
     associated with this card. */
    func profilePictureData() -> String {
        let imgData = UIImagePNGRepresentation(profilePicture())!
        return NSString(data: imgData, encoding: String.Encoding.utf8.rawValue) as String!
    }
    
    /** Sets the profile picture as NEW for this card.
        Returns whether the image contents changed.
     */
    func setProfilePicture(new: UIImage) -> Bool {
        let a = _avi
        _avi = new
        return a != new
    }
    
    /** Returns the card's priority integer value. */
    func priority() -> Int {
        return _priority
    }
    
    /** Sets the card's priority to NEW.
     Returns whether the priority was changed. */
    func setPriority(new: Int) -> Bool {
        let p = _priority
        _priority = new
        return p != new
    }
    
    // MARK: Protocols
    
    public static func ==(lhs: Card, rhs: Card) -> Bool {
        if lhs.phones().count != rhs.phones().count {
            return false
        }
        
        for phone in lhs.phones() {
            if !rhs.phones().contains(phone) {
                return false
            }
        }
        
        return lhs.user() == rhs.user() &&
            lhs.occupation() == rhs.occupation() &&
            lhs.email() == rhs.email() &&
            lhs.website() == rhs.website() &&
            lhs.profilePicture() == rhs.profilePicture()
    }
    
    public static func <(lhs: Card, rhs: Card) -> Bool {
        return lhs.priority() < rhs.priority()
    }
    
    /** Combines the hash value of each non-nil property
     multiplied by a prime constant. */
    public var hashValue: Int {
        var hash = _user.hashValue ^ _occupation.hashValue ^ _email.hashValue
        
        if self.hasLocation() {
            hash ^= _location!.hashValue
        }
        
        if _phones.count > 0 {
            for phone in _phones {
                hash ^= phone.hashValue
            }
        }
        
        hash ^= _website.hashValue
        hash ^= _avi.hashValue
        
        return hash &* Utils.HASH_PRIME
    }
}
