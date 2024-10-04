//
//  MSPhysicsCategory.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//


import Foundation

struct MSPhysicsCategory {
    static let none: UInt32        = 0
    static let ball: UInt32        = 0b1
    static let obstacle: UInt32    = 0b10
    static let ledge: UInt32       = 0b100
    static let moodSwitch: UInt32  = 0b1000
}
