//
//  MSBackground.swift
//  moodswitch
//
//  Created by Sam Richard on 10/3/24.
//

import SpriteKit

class MSBackground: SKNode {
    
    private var currentBackground: SKSpriteNode
    private var nextBackground: SKSpriteNode
    private var screenSize: CGSize = .zero

    override init() {
        let texture = SKTexture(imageNamed: "happy_bg")
        currentBackground = SKSpriteNode(texture: texture)
        nextBackground = currentBackground
        super.init()
        addChild(currentBackground)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setup(screenSize: CGSize) {
        self.screenSize = screenSize
        updateBackgroundSize(node: currentBackground)
        
        currentBackground.position = .zero
        zPosition = -1
    }
    
    private func updateBackgroundSize(node: SKSpriteNode) {
        let bgRatio = screenSize.width / node.texture!.size().width
        let bgHeight = node.texture!.size().height * bgRatio
        node.size = CGSize(width: screenSize.width, height: bgHeight)
    }
    
    func changeTexture(to moodType: MSMoodType) {
        nextBackground.removeAllActions()
        currentBackground.removeAllActions()
        
        let newTexture = SKTexture(imageNamed: moodType.bgTextureName)
        
        nextBackground = SKSpriteNode(texture: newTexture)
        updateBackgroundSize(node: nextBackground)
        nextBackground.position = currentBackground.position
        nextBackground.alpha = 0.0
        addChild(nextBackground)
        
        let fadeOutCurrent = SKAction.fadeOut(withDuration: 0.2)
        let fadeInNext = SKAction.fadeIn(withDuration: 0.2)
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        
        let currentAnimation = SKAction.group([fadeOutCurrent, scaleUp])
        let nextAnimation = SKAction.group([fadeInNext, scaleDown])
        
        currentBackground.run(currentAnimation)
        nextBackground.run(nextAnimation) {
            self.currentBackground.removeFromParent()
            self.currentBackground = self.nextBackground
        }
    }
}
