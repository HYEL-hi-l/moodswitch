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
        self.layoutInfo = MSLayoutInfo(screenSize: .zero)
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
//        let screenSize = UIScreen.main.bounds.size
    }
}
