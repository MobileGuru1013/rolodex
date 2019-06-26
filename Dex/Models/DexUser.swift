//
//  DexUser.swift
//  Dex
//
//  Created by Felipe Campos on 1/28/18.
//  Copyright © 2018 Orange Inc. All rights reserved.
//

import Foundation

//
//  DexUser.swift
//  Dex
//
//  Created by Felipe Campos on 12/19/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

/** A user class. */
internal class DexUser: Equatable, Comparable, Hashable {
    
    // MARK: Properties
    
    /** The user's name. */
    private var _name: String
    
    /** The user's influence. */
    private var _influence: Double = 0.0
    
    /** The user's cards. */
    private var _cards: [Card] = []
    
    /** The user's location. */
    private var _location: CLLocation?
    
    /** The user's interests. */
    private var _interests: [Interest] = []
    
    /** The user's skills. */
    private var _skills: [Skill] = []
    
    /** The user's connections. */
    private var _connections: [Connection] = []
    
    /** The user's connected users. */
    private lazy var _connectedUsers: [DexUser] = {
        var result: [DexUser] = []
        for connection in self.connections() {
            result.append(connection.getConnection(this: self)!)
        }
        
        return result
    }()
    
    // MARK: Initialization
    
    convenience init(name: String, cards: [Card], inf: Double, initPos: CLLocation, connections: [Connection], interests: [Interest]) {
        self.init(name: name, inf: inf, initPos: initPos, connections: connections, interests: interests)
        for card in cards {
            _cards.append(card)
        }
    }
    
    init(name: String, inf: Double, initPos: CLLocation, connections: [Connection], interests: [Interest]) {
        _name = name
        _influence = inf
        _location = initPos // TODO: have method that updates this every 10-20 min
        
        for connection in connections {
            _connections.append(connection)
        }
        
        for interest in interests {
            _interests.append(interest)
        }
        
        // TODO: other initializers, fetch from server or cache for most part
    }
    
    init(name: String, influence: Double) {
        _name = name
        _influence = influence
    }
    
    init(name: String, interests: [Interest]) {
        _name = name
        for interest in interests {
            _interests.append(interest)
        }
    }
    
    init(name: String, metadata: String, email: String?, phone: String?, avi: UIImage?) {
        // TODO: implement
        _name = name
        parseMetadata(metadata: metadata)
    }
    
    // MARK: - Methods
    
    func makeCard(name: String, email: String?, phone: Phone?, avi: UIImage?) {
        // TODO: implement
    }
    
    func parseMetadata(metadata: String) {
        // TODO: implement
    }
    
    /** Returns the user's name. */
    func name() -> String {
        return _name
    }
    
    /** Sets the name for this user as NAME.
     Returns whether it was modified.
     */
    func setName(name: String) -> Bool {
        let n = _name
        _name = name
        return n != name
    }
    
    /** Returns the user's influence. */
    func influence() -> Double {
        return _influence
    }
    
    /** Returns the user's card. */
    func cards() -> [Card] {
        return _cards
    }
    
    /** Returns the user's primary card. */
    func primaryCard() -> Card {
        return _cards[0]
    }
    
    /** Adds CARD to the user's cards. */
    func addCard(card: Card) {
        if _cards.contains(card) {
            print("Could not add card.")
            return
        }
        _cards.append(card)
    }
    
    /** Removes CARD from the user's cards.
     Returns whether the card was succesfully removed. */
    func removeCard(card: Card) -> Bool {
        if _cards.count <= 1 || !_cards.contains(card) {
            print("Could not remove card.")
            return false
        }
        
        let ind = _cards.index(of: card)!
        _cards.remove(at: ind)
        
        return true
    }
    
    /** Returns whether the user has an available location. */
    func hasLocation() -> Bool {
        return _location != nil
    }
    
    /** Returns the user's location. */
    func location() -> CLLocation {
        return _location!
    }
    
    /** Returns the user's interests. */
    func interests() -> [Interest] {
        return _interests
    }
    
    func connectWith(user: DexUser) {
        // FIXME: make connection
    }
    
    /** Returns the connection objects associated with this user. */
    func connections() -> [Connection] {
        return _connections
    }
    
    /** Returns the users connected to this user. */
    func connectedUsers() -> [DexUser] {
        return _connectedUsers
    }
    
    // MARK: Protocols
    
    public static func ==(lhs: DexUser, rhs: DexUser) -> Bool {
        return lhs.influence() == rhs.influence() &&
            lhs.location() == rhs.location() &&
            lhs.cards() == rhs.cards()
    }
    
    public static func <(lhs: DexUser, rhs: DexUser) -> Bool {
        return lhs.influence() < rhs.influence()
    }
    
    /** Combines the hash value of each property
     multiplied by a prime constant. */
    public var hashValue: Int {
        var hash = location().hashValue ^ influence().hashValue
        for card in cards() {
            hash ^= card.hashValue
        }
        
        return hash &* Utils.HASH_PRIME
    }
}
