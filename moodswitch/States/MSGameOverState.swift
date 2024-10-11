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
    
    private var canTap = false
    private let retryDelay: TimeInterval = 1.5

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is MSStartState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        print("* Entered GameOver State *")
        
        setupUI()
        scheduleRetryLabel()
    }
    
    override func willExit(to nextState: GKState) {
        gameOverLabel.removeFromParent()
        retryLabel.removeFromParent()
        
        gameScene.reset()
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canTap {
            gameScene.context.stateMachine?.enter(MSStartState.self)
        }
    }

}


// MARK: Helpers
extension MSGameOverState {
    
    func setupUI() {
        gameOverLabel.fontSize = 48
        gameOverLabel.fontName = "HelveticaNeue-Bold"
        gameOverLabel.position = CGPoint(x: gameScene.gameCamera!.frame.midX, y: gameScene.gameCamera!.frame.midY + 50)
        gameScene.addChild(gameOverLabel)

        retryLabel.fontSize = 24
        retryLabel.fontName = "HelveticaNeue"
        retryLabel.position = CGPoint(x: gameScene.gameCamera!.frame.midX, y: gameScene.gameCamera!.frame.midY - 50)
        retryLabel.alpha = 0 
    }
    
    private func scheduleRetryLabel() {
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) { [weak self] in
            guard let self = self else { return }
            self.showRetryLabel()
        }
    }
    
    private func showRetryLabel() {
        gameScene.addChild(retryLabel)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        retryLabel.run(fadeIn)
        canTap = true
    }
    
}
