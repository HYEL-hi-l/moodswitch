//
//  MSMoodType.swift
//  moodswitch
//
//  Created by Sam Richard on 10/3/24.
//

import SpriteKit

enum MSMoodType: CaseIterable {
    case happy
    case sad
    case angry
    case inlove
    
    var textureName: String {
        switch self {
        case .happy:
            return "happy"
        case .sad:
            return "sad"
        case .angry:
            return "angry"
        case .inlove:
            return "inlove"
        }
    }
    
    var bgTextureName: String {
        return "\(self.textureName)_bg"
    }
    
    var colorHex: String {
        switch self {
        case .happy:
            return "FFCF69"
        case .sad:
            return "65BAEE"
        case .angry:
            return "F3504C"
        case .inlove:
            return "FF5AA9"
        }
    }
    
    var color: SKColor {
        return SKColor(hex: self.colorHex)
    }
    
    static func random() -> MSMoodType {
        return MSMoodType.allCases.randomElement() ?? .happy
    }
}
