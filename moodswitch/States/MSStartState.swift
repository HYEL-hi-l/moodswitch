//
//  MSStartState.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import GameplayKit
import SpriteKit

class MSGameState: GKState  {
    
    unowned let gameScene: MSGameScene
    
    init(gameScene: MSGameScene) {
        self.gameScene = gameScene
        super.init()
    }
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
}


class MSStartState: MSGameState {
    
    let titleLabel = SKLabelNode(text: "Color Switch")

    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is MSPlayState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        print("* Entered Start State *")

        setupUI()
    }
    
    override func willExit(to nextState: GKState) {
        titleLabel.removeFromParent()
    }
    
    func setupUI() {
        titleLabel.fontSize = 48
        titleLabel.fontName = "HelveticaNeue-Bold"
        titleLabel.position = CGPoint(x: gameScene.frame.midX, y: gameScene.frame.midY)
        gameScene.addChild(titleLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameScene.context.stateMachine?.enter(MSPlayState.self)
    }
}
