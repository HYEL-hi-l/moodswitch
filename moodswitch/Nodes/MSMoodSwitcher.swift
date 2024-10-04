//
//  MSMoodSwitcher.swift
//  moodswitch
//
//  Created by Sam Richard on 10/3/24.
//

import SpriteKit

class MSMoodSwitcher: SKSpriteNode {
    
    var moods: [MSMoodType]

    init(size: CGSize, moods: [MSMoodType]) {
        self.moods = moods
        super.init(texture: nil, color: .white, size: CGSize(width: size.width * 4, height: size.height / 4))
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = MSPhysicsCategory.moodSwitch
        physicsBody?.contactTestBitMask = MSPhysicsCategory.ball
        physicsBody?.collisionBitMask = MSPhysicsCategory.none
    }
    
    func getRandomMood() -> MSMoodType {
        print("moods", moods)
        return moods.randomElement() ?? .happy
    }
}
