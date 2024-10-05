//
//  MSMoodSwitcher.swift
//  moodswitch
//
//  Created by Sam Richard on 10/3/24.
//

import SpriteKit

class MSMoodSwitcher: SKSpriteNode {
    
    let radius: CGFloat
    var moods: [MSMoodType]
    var lastObstacleMoods: [MSMoodType]

    init(radius: CGFloat, moods: [MSMoodType], lastObstacleMoods: [MSMoodType]) {
        self.moods = moods
        self.radius = radius
        self.lastObstacleMoods = lastObstacleMoods
        let texture = SKTexture(imageNamed: "ms_mood_switcher")
        super.init(texture: texture, color: .black, size: texture.size())
        setupPhysics()
        startPulsingAnimation() 
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = MSPhysicsCategory.moodSwitch
        physicsBody?.contactTestBitMask = MSPhysicsCategory.ball
        physicsBody?.collisionBitMask = MSPhysicsCategory.none
    }
    
    func getRandomMood(except currentMood: MSMoodType) -> MSMoodType {
        let validMoods = moods.filter { lastObstacleMoods.contains($0) }
        
        var newMood = validMoods.randomElement() ?? validMoods.first
        while newMood == currentMood {
            newMood = validMoods.randomElement() ?? validMoods.first
        }
        return newMood ?? currentMood
    }
    
    func startPulsingAnimation() {
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.5)
        
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }
}
