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
    }
    
    override func willExit(to nextState: GKState) {
        gameScene.obstacleManager.reset()
    }
    
    override func update(deltaTime: TimeInterval) {
        gameScene.obstacleManager.updateObstacles(in: gameScene, ballPositionY: gameScene.ball.position.y)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameScene.ball.jump(.normal)
        
    }
}
