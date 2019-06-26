//
//  Connection.swift
//  Dex
//
//  Created by Felipe Campos on 12/20/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

import Foundation
import CoreLocation

/** A connection class defining a relationship between two users. */
internal class Connection: Equatable, Comparable, Hashable {
    
    enum Form {
        case personal
        case recommended
        case online
        case other
    }
    
    // MARK: Properties
    
    /** A dictionary of the users making up this connection. */
    private var _users: [String : DexUser] = [:]
    
    /** The connection's type. */
    private var _type: Form
    
    /** The connection's weight. */
    private var _weight: Double = -1.0
    
    /** The place in which the connection was made. */
    private var _location: CLLocation
    
    /** A string ID indicating one of the users in this connection. */
    private static let first = "USER1"
    
    /** A string ID indicating one of the users in this connection. */
    private static let second = "USER2"
 
    // MARK: Initialization
    
    init(user1: DexUser, user2: DexUser, location: CLLocation, form: Connection.Form) {
        _users.updateValue(user1, forKey: Connection.first)
        _users.updateValue(user2, forKey: Connection.second)
        
        _location = location
        
        switch form {
        case .personal:
            _weight = 2
            break
        case .recommended:
            _weight = 1
            break
        case .online:
            _weight = 0.25
            break
        default:
            _weight = 0.0
            break
        }
        
        _type = form
    }
    
    // MARK: - Methods
    
    /** Gets the user associated with this connection
     that is not THIS user. */
    func getConnection(this: DexUser) -> DexUser? {
        if !_users.values.contains(this) {
            return nil
        }
        
        let key = (_users as NSDictionary).allKeys(for: this) as! [String]
        if key[0] == Connection.first {
            return getUser(id: Connection.second)
        } else {
            return getUser(id: Connection.first)
        }
    }
    
    /** Returns the users associated with this connection. */
    func users() -> [DexUser] {
        return [_users[Connection.first]!, _users[Connection.second]!]
    }
    
    /** Returns the user given by ID. */
    private func getUser(id: String) -> DexUser? {
        return _users[id]
    }
    
    /** Returns the connection type. */
    func type() -> Form {
        return _type
    }
    
    /** Returns the place the connection was made. */
    func place() -> CLLocation {
        return _location
    }
    
    /** Returns the connection weight. */
    func weight() -> Double {
        return _weight
    }
    
    // MARK: Protocols
    
    static func ==(lhs: Connection, rhs: Connection) -> Bool {
        return lhs.type() == rhs.type() && lhs.weight() == rhs.weight() &&
                lhs.users() == rhs.users()
    }
    
    static func <(lhs: Connection, rhs: Connection) -> Bool {
        return lhs.weight() < rhs.weight()
    }
    
    /** Combines the hash value of each property multiplied by a prime constant. */
    var hashValue: Int {
        var hash: Int = weight().hashValue
        hash ^= type().hashValue
        for user in users() {
            hash ^= user.hashValue
        }
        
        return hash &* Utils.HASH_PRIME
    }
}
