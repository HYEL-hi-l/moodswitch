//
//  MSStartState.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import GameplayKit
import SpriteKit


class MSPlayState: MSGameState {
    
    private var happyFallingEmitter: SKEmitterNode?
    private var sadFallingEmitter: SKEmitterNode?
    private var angryFallingEmitter: SKEmitterNode?
    private var inLoveFallingEmitter: SKEmitterNode?
    private var offScreenPosition: CGPoint?
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is MSGameOverState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        print("* Entered Play State *")
        
        showFallingParticlesInScene()
        let spacing = 30.0  + gameScene.layoutInfo.powerUpIndicatorHeight / 2
        let offset = 200.0
        offScreenPosition = CGPoint(x: -gameScene.size.width * 0.5 + spacing - offset , y: -gameScene.size.height * 0.5 + spacing)
        let startPosition = CGPoint(x: -gameScene.size.width * 0.5 + spacing, y: -gameScene.size.height * 0.5 + spacing)
        gameScene.powerUpIndicator.run(SKAction.move(to: startPosition, duration: 0.5))
        gameScene.scoreLabel.run(SKAction.fadeIn(withDuration: 0.5))
        
        gameScene.ball.position.x = gameScene.size.width * 0.5
    }
    
    override func willExit(to nextState: GKState) {
        gameScene.obstacleManager.reset()
        gameScene.powerUpIndicator.run(SKAction.move(to: offScreenPosition!, duration: 0.5))
        hideFallingParticlesFromScene()
    }
    
    override func update(deltaTime: TimeInterval) {
        gameScene.obstacleManager.updateObstacles(in: gameScene, ballPositionY: gameScene.ball.position.y, currentScore: gameScene.gameInfo?.score ?? 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameScene.ball.jump(.normal)
    }

}


// MARK: Helpers
extension MSPlayState {
    
    func showFallingParticlesInScene() {
        let emitterAlpha: CGFloat = 0.8
        let emitterBirthRate: CGFloat = 10.0

        gameScene.happyFallingEmitter?.alpha = emitterAlpha
        gameScene.sadFallingEmitter?.alpha = emitterAlpha
        gameScene.angryFallingEmitter?.alpha = emitterAlpha
        gameScene.inLoveFallingEmitter?.alpha = emitterAlpha
        
        gameScene.happyFallingEmitter?.particleBirthRate = emitterBirthRate
        gameScene.sadFallingEmitter?.particleBirthRate = emitterBirthRate
        gameScene.angryFallingEmitter?.particleBirthRate = emitterBirthRate
        gameScene.inLoveFallingEmitter?.particleBirthRate = emitterBirthRate
    }
    
    func hideFallingParticlesFromScene() {
        let emitterAlpha: CGFloat = 0.0
        let emitterBirthRate: CGFloat = 0.0

        gameScene.happyFallingEmitter?.alpha = emitterAlpha
        gameScene.sadFallingEmitter?.alpha = emitterAlpha
        gameScene.angryFallingEmitter?.alpha = emitterAlpha
        gameScene.inLoveFallingEmitter?.alpha = emitterAlpha
        
        gameScene.happyFallingEmitter?.particleBirthRate = emitterBirthRate
        gameScene.sadFallingEmitter?.particleBirthRate = emitterBirthRate
        gameScene.angryFallingEmitter?.particleBirthRate = emitterBirthRate
        gameScene.inLoveFallingEmitter?.particleBirthRate = emitterBirthRate
    }
    
}
