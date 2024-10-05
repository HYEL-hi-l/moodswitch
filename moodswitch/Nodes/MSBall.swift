//
//  MSBall.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//


import SpriteKit

enum MSJumpEffect {
    case normal
    case doubleJump
}

class MSBall: SKSpriteNode {
    let radius: CGFloat
    var mood: MSMoodType?
    private var isChangingMood = false
    
    init(radius: CGFloat) {
        self.radius = radius

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
        physicsBody?.affectedByGravity = true
        physicsBody?.mass = 2.5
    }
    
    func jump(_ effect: MSJumpEffect) {
        physicsBody?.velocity = .zero

        switch effect {
            case .normal:
                physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1800))
            case .doubleJump:
                physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2300))
        }
    }
    
    func changeMood(to newMood: MSMoodType? = nil) {
        guard !isChangingMood else { return }
        
        let targetMood: MSMoodType
        if let newMood = newMood {
            targetMood = newMood
        } else {
            var randomMood = MSMoodManager.shared.getRandomMood()
            while randomMood == mood {
                randomMood = MSMoodManager.shared.getRandomMood()
            }
            targetMood = randomMood
        }
        
        isChangingMood = true
        
        let newTexture = SKTexture(imageNamed: targetMood.textureName)

        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.05)
        let textureChange = SKAction.setTexture(newTexture)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        let shrink = SKAction.scale(to: 0.8, duration: 0.05)
        let scaleToNormal = SKAction.scale(to: 1.0, duration: 0.05)

        let group1 = SKAction.group([fadeOut, shrink])
        let group2 = SKAction.group([fadeIn, scaleToNormal])
        let sequence = SKAction.sequence([group1, textureChange, group2])
        
        run(sequence) { [weak self] in
            self?.mood = targetMood
            self?.isChangingMood = false
        }
    }
}
