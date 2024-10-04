//
//  MSBackground.swift
//  moodswitch
//
//  Created by Sam Richard on 10/3/24.
//

import SpriteKit

class MSBackground: SKSpriteNode {
    
    init() {
        let texture = SKTexture(imageNamed: "happy_bg")
        super.init(texture: texture, color: .clear, size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setup(screenSize: CGSize) {
        let bgRatio = screenSize.width / texture!.size().width
        let bgHeight = texture!.size().height * bgRatio
        size = CGSize(width: screenSize.width, height: bgHeight)
        
        position = CGPoint(x: 0, y: 0)
        zPosition = -1
    }
    
    func changeTexture(to moodType: MSMoodType) {
        let newTexture = SKTexture(imageNamed: moodType.bgTextureName)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let setTexture = SKAction.setTexture(newTexture)
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        let sequence = SKAction.sequence([fadeOut, setTexture, fadeIn])
        
        run(sequence)
    }
    
}
