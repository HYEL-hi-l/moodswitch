//
//  MSStartState.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import GameplayKit
import SpriteKit


class MSGameOverState: MSGameState {
    
    let gameOverLabel = SKLabelNode(text: "Game Over")
    let retryLabel = SKLabelNode(text: "Tap to Retry")

    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is MSStartState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        print("* Entered GameOver State *")
        setupUI()
    }
    
    override func willExit(to nextState: GKState) {
        gameOverLabel.removeFromParent()
        retryLabel.removeFromParent()
        gameScene.ball.position = CGPoint(x: gameScene.frame.midX, y: gameScene.frame.minY)
        gameScene.ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        gameScene.ball.physicsBody?.affectedByGravity = false
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("game over touch")
        gameScene.context.stateMachine?.enter(MSStartState.self)
    }

    func setupUI() {
        gameOverLabel.fontSize = 48
        gameOverLabel.fontName = "HelveticaNeue-Bold"
        gameOverLabel.position = CGPoint(x: gameScene.gameCamera!.frame.midX, y: gameScene.gameCamera!.frame.midY + 50)
        gameScene.addChild(gameOverLabel)

        retryLabel.fontSize = 24
        retryLabel.fontName = "HelveticaNeue"
        retryLabel.position = CGPoint(x: gameScene.gameCamera!.frame.midX, y: gameScene.gameCamera!.frame.midY - 50)
        gameScene.addChild(retryLabel)
    }
    
}
