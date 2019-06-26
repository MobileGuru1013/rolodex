//
//  Group.swift
//  Dex
//
//  Created by Felipe Campos on 12/28/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

import Foundation

internal class Group: Equatable, Comparable, Hashable {
    
    // MARK: Properties
    
    private var _members: [DexUser] = []
    private var _totalInfluence: Double = 0.0 // TODO: connectivity field??
    
    // MARK: Initialization
    
    init(members: DexUser...) {
        for member in members {
            _members.append(member)
            _totalInfluence += member.influence()
        }
    }
    
    // MARK: - Methods
    
    func members() -> [DexUser] {
        return _members
    }
    
    func hasMember(user: DexUser) -> Bool {
        return _members.contains(user)
    }
    
    func influence() -> Double {
        return _totalInfluence
    }
    
    // MARK: Protocols
    
    static func ==(lhs: Group, rhs: Group) -> Bool {
        if lhs.members().count != rhs.members().count {
            return false
        }
        
        for member in lhs.members() {
            if !rhs.hasMember(user: member) {
                return false
            }
        }
        
        return lhs.influence() == rhs.influence()
    }
    
    static func <(lhs: Group, rhs: Group) -> Bool {
        return lhs.influence() < rhs.influence()
    }
    
    /** Combines the hash value of each property
     multiplied by a prime constant. */
    var hashValue: Int {
        var hash: Int = _totalInfluence.hashValue
        for member in members() {
            hash ^= member.hashValue
        }
        
        return hash &* Utils.HASH_PRIME
    }
}
