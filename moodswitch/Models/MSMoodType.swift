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
    case moodless
    
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
        case .moodless:
            return "moodless"
        }
    }
    
    var bgTextureName: String {
        return "\(self.textureName)_bg_old"
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
        case .moodless:
            return "B3B3B3"
        }
    }
    
    var color: SKColor {
        return SKColor(hex: self.colorHex)
    }
    
    static func random() -> MSMoodType {
        let selectableMoods = MSMoodType.allCases.filter { $0 != .moodless }
        return selectableMoods.randomElement() ?? .happy
    }
}
