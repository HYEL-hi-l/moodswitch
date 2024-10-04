//
//  MSStartState.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import GameplayKit
import SpriteKit


class MSPlayState: MSGameState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is MSGameOverState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        print("* Entered Play State *")
        
        gameScene.ball.physicsBody?.affectedByGravity = true
        gameScene.ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        gameScene.ball.position = CGPoint(x: gameScene.frame.midX, y: gameScene.frame.minY + 200)
        gameScene.reset()
        gameScene.obstacleManager.lastObstacleYPosition = gameScene.ball.position.y - 100
        gameScene.obstacleManager.updateObstacles(in: gameScene, ballPositionY: gameScene.ball.position.y)
        gameScene.ball.mood = .happy
    }
    
    override func willExit(to nextState: GKState) {
        gameScene.obstacleManager.reset()
    }
    
    override func update(deltaTime: TimeInterval) {
        gameScene.obstacleManager.updateObstacles(in: gameScene, ballPositionY: gameScene.ball.position.y)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameScene.ball.jump()
    }
}
