//
//  Skill.swift
//  Dex
//
//  Created by Felipe Campos on 1/11/18.
//  Copyright © 2018 Orange Inc. All rights reserved.
//

import Foundation

internal class Skill: Equatable, Comparable, Hashable {
    
    enum Variety {
        case business
        case consulting
        case design
        case engineering
        case entrepreneurship
        case software
        case sports
    }
    
    // MARK: Properties
    
    private var _name: String = ""
    
    private var _description: String = ""
    
    private var _type: Skill.Variety
    
    // MARK: Initialization
    
    init(type: Skill.Variety) {
        _type = type
        let variety = Skill.Variety.self
        
        switch type { // FIXME: brainstorm actual stuff
        case variety.software:
            _name = "Software"
            _description = "He who likes to code."
            break
        default:
            _name = "Any"
            _description = "The renaissance man."
        }
    }
    
    // MARK: Methods
    
    // MARK: Protocols
    
    static func ==(lhs: Skill, rhs: Skill) -> Bool {
        return false // FIXME:
    }
    
    static func <(lhs: Skill, rhs: Skill) -> Bool {
        return false // FIXME:
    }
    
    var hashValue: Int {
        let hash = _name.hashValue ^ _description.hashValue ^ _type.hashValue
        return hash &* Utils.HASH_PRIME
    }
    
}
