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

        let initialMood = MSMoodType.moodless
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
    
}


// MARK: Helpers
extension MSBall {
    
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

        let sequence = SKAction.sequence([shrink, textureChange, scaleToNormal])
        
        run(sequence) { [weak self] in
            self?.mood = targetMood
            self?.isChangingMood = false
        }
        
        
        let particleEmitter = SKEmitterNode(fileNamed: "MoodFlashFaces") ?? SKEmitterNode()
        particleEmitter.particleTexture = SKTexture(imageNamed: targetMood.textureName)
        particleEmitter.position = CGPoint(x: 0, y: 0)
        particleEmitter.zPosition = -1
        addChild(particleEmitter)
        
        let removeEmitter = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ])
        particleEmitter.run(removeEmitter)
    }
    
}
