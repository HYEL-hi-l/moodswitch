//
//  MSGameContext.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//


import GameplayKit
import SwiftUI

class MSGameContext {

    private(set) var scene: MSGameScene!
    private(set) var stateMachine: GKStateMachine?

    var layoutInfo: MSLayoutInfo
    var gameInfo: MSGameInfo

    init() {
        self.layoutInfo = MSLayoutInfo()
        self.gameInfo = MSGameInfo()
        self.scene = MSGameScene(context: self, size: UIScreen.main.bounds.size)
        
        configureStates()
        configureLayoutInfo()
    }
    
    func configureStates() {
        stateMachine = GKStateMachine(
            states: [
                MSStartState(gameScene: scene),
                MSPlayState(gameScene: scene),
                MSGameOverState(gameScene: scene)
            ]
        )
    }
    
    func configureLayoutInfo() {
        let screenSize = UIScreen.main.bounds.size
        
        layoutInfo.ballRadius = screenSize.width / 20
        layoutInfo.moodSwitcherRadius = layoutInfo.ballRadius - 5
        layoutInfo.ballYOffset = screenSize.height * 0.15
        layoutInfo.ballStartPosition = CGPoint(x: screenSize.width / 2, y: layoutInfo.ballYOffset)
        
        layoutInfo.ledgeYPosition = layoutInfo.ballStartPosition.y - (layoutInfo.ballRadius * 1.05)
    
        layoutInfo.firstObstacleYOffset = screenSize.height * 0.8
        layoutInfo.firstObstacleYPosition = (screenSize.height / 2) + layoutInfo.firstObstacleYOffset
//        layoutInfo.firstObstacleYPosition = (screenSize.height / 2)
        layoutInfo.maxObstacleWidth = screenSize.width * 0.8
        layoutInfo.obstacleThickness = screenSize.width / 14
        layoutInfo.obstacleSpacing = layoutInfo.maxObstacleWidth * 1.75
        
        layoutInfo.powerUpIndicatorWidth = screenSize.width * 0.04
        layoutInfo.powerUpIndicatorHeight = screenSize.height * 0.35
        layoutInfo.powerUpIndicatorCornerRadius = 15
    }
}
