//
//  Interest.swift
//  Dex
//
//  Created by Felipe Campos on 12/23/17.
//  Copyright © 2017 Orange Inc. All rights reserved.
//

import Foundation

/** An interest class defining an instance of a user's interest or skill. */
internal class Interest: Equatable, Hashable {
    
    enum Variety {
        case reading
        case tennis
        case golf
        case hunting
        case fishing
        case other
        // TODO: refine and add cases
    }
    
    // MARK: Properties
    
    /** The interest name. */
    private var _name: String
    
    /** The interest description. */
    private var _description: String
    
    /** The interest type. */
    private var _type: Interest.Variety
    
    // MARK: Initialization
    
    init(type: Interest.Variety) {
        _type = type
        let variety = Interest.Variety.self
        
        switch type {
        case variety.reading:
            _name = "Reading"
            _description = "n/a"
        default:
            _name = "Other"
            _description = "n/a"
        }
    }
    
    // MARK: - Methods
    
    /** Returns the interest name. */
    func name() -> String {
        return _name
    }
    
    /** Return's the interest description. */
    func description() -> String {
        return _description
    }
    
    /** Return's the interest type (business, software, entrepreneurship, etc.). */
    func type() -> Interest.Variety {
        return _type
    }
    
    // MARK: Protocols
    
    static func ==(lhs: Interest, rhs: Interest) -> Bool {
        return lhs.name() == rhs.name() && lhs.description() == rhs.description()
        && lhs.type() == rhs.type()
    }
    
    /** Combines the hash value of each property
     multiplied by a prime constant. */
    var hashValue: Int {
        return _name.hashValue ^ _description.hashValue ^ _type.hashValue &* Utils.HASH_PRIME
    }
}
