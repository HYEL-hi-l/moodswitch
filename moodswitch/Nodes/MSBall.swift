//
//  MSBall.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//


import SpriteKit

class MSBall: SKSpriteNode {
    let radius: CGFloat = 20.0
    var mood: MSMoodType?
    
    init() {
        let initialMood = MSMoodType.happy
        self.mood = initialMood
        let texture = SKTexture(imageNamed: initialMood.textureName)
        super.init(texture: texture, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.categoryBitMask = MSPhysicsCategory.ball
        physicsBody?.contactTestBitMask = MSPhysicsCategory.obstacle | MSPhysicsCategory.ledge
        physicsBody?.collisionBitMask = MSPhysicsCategory.ledge
        physicsBody?.affectedByGravity = false
        physicsBody?.mass = 2.5
    }
    
    func jump() {
        physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1500))
    }
    
    func changeMood(to newMood: MSMoodType? = nil) {
        if newMood == nil {
             var randomMood = MSMoodManager.shared.getRandomMood()
             while randomMood == mood {
                 randomMood = MSMoodManager.shared.getRandomMood()
             }
             mood = randomMood
         } else {
             mood = newMood
         }
        
        if let selectedMood = mood {
            let newTexture = SKTexture(imageNamed: selectedMood.textureName)
            let textureChange = SKAction.setTexture(newTexture)
            run(textureChange)
        }
    }
}
