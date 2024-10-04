//
//  MSMoodManager.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import SpriteKit

class MSMoodManager {
    static let shared = MSMoodManager()
    private init() {}
    
    private var activeMoods: [MSMoodType] = [.happy, .sad, .angry, .inlove]
    
    func getRandomMoodSequence() -> [MSMoodType] {
         return activeMoods.map { $0 }.shuffled()
     }

     func getRandomMood() -> MSMoodType {
         return activeMoods.map { $0 }.randomElement() ?? .happy
     }
    
    func isMoodMatch(ball: MSBall, obstacle: SKNode?) -> Bool {
        guard let obstacle = obstacle as? SKShapeNode else { return false }
        guard let ballMood = ball.mood else { return false }
        
//        print("isColorMatch: Ball Mood - \(ballMood.colorHex), Obstacle Color - \(obstacle.fillColor.hexString)")
        
        return ballMood.colorHex == obstacle.fillColor.hexString
    }
}


extension SKColor {

    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hexString.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // AARRGGBB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: CGFloat(a) / 255.0)
    }

    var hexString: String {
        guard let components = cgColor.components else { return "000000" }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let a = Float(components.count >= 4 ? components[3] : 1.0)
        
        if a < 1.0 {
            return String(format: "%02X%02X%02X%02X", Int(a * 255), Int(r * 255), Int(g * 255), Int(b * 255))
        } else {
            return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
    }
    
}
