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
    
    let titleNode = SKNode()
    let inLabel = SKLabelNode(text: "in")
    let theLabel = SKLabelNode(text: "the")
    let moodLabel = SKLabelNode(text: "mood?")
    
    var willDoubleJump = true
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is MSPlayState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        print("* Entered Start State *")
        setupUI()
    }
    
    override func willExit(to nextState: GKState) {
        titleNode.removeAllChildren()
        titleNode.removeFromParent()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if willDoubleJump {
            gameScene.ball.jump(.doubleJump)
            willDoubleJump = false
        } else {
            gameScene.ball.jump(.normal)
        }

        changeMoodRandomly()
    }
    
    override func update(deltaTime: TimeInterval) {
        if let firstObstacle = gameScene.obstacleManager.obstacles.first {
            let distance = firstObstacle.position.y - gameScene.ball.position.y
            if distance < gameScene.size.height / 2 {
                gameScene.context.stateMachine?.enter(MSPlayState.self)
            }
        }
    }
    
}


// MARK: Helpers
extension MSStartState {
    
    func setupUI() {
        setupTitleNode()
        animateTitleNode()
        
        gameScene.obstacleManager.updateObstacles(in: gameScene, ballPositionY: gameScene.ball.position.y)
        gameScene.obstacleManager.lastObstacleYPosition = gameScene.layoutInfo.firstObstacleYPosition
    }
    
    func setupTitleNode() {
        let labels = [inLabel, theLabel, moodLabel]

        let fontSize: CGFloat = 48

        for label in labels {
            label.fontSize = fontSize
            label.fontName = "SF-Pro-Rounded"
            label.alpha = 0.0
        }

        titleNode.position = CGPoint(x: gameScene.frame.midX, y: gameScene.size.height / 2)
        gameScene.addChild(titleNode)

        inLabel.position = CGPoint(x: gameScene.size.width * 0.5, y: gameScene.size.height * 0.3)
        theLabel.position = CGPoint(x: gameScene.size.width * 0.5, y: gameScene.size.height * 0.15)
        moodLabel.position = CGPoint(x: gameScene.size.width * 0.5, y: 0)
        
        titleNode.addChild(inLabel)
        titleNode.addChild(theLabel)
        titleNode.addChild(moodLabel)

    }
    
    func animateTitleNode() {
        let labels = [inLabel, theLabel, moodLabel]

//        let targetXPositions: [CGFloat] = [0, -gameScene.size.width * 0.2, gameScene.size.width * 0.2]
        let targetXPositions: [CGFloat] = [-gameScene.size.width * 0.2, 0, gameScene.size.width * 0.2]

        
        for (index, label) in labels.enumerated() {
            let delay = SKAction.wait(forDuration: 0.5 * Double(index))
            let moveAction = SKAction.moveTo(x: targetXPositions[index], duration: 0.5)
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let group = SKAction.group([moveAction, fadeIn])
            let sequence = SKAction.sequence([delay, group])
            label.run(sequence)
        }
    }

    
    func addSpinAnimation() {
        let spinAction = SKAction.rotate(byAngle: .pi * 2, duration: gameScene.layoutInfo.rotationDuration)
        let repeatForever = SKAction.repeatForever(spinAction)
        titleNode.run(repeatForever)
    }

    private func changeMoodRandomly() {
        guard let currentMood = gameScene.ball.mood else { return }
        
        var newMood = MSMoodManager.shared.getRandomMood()
        while newMood == currentMood {
            newMood = MSMoodManager.shared.getRandomMood()
        }
        
        gameScene.ball.changeMood(to: newMood)
        gameScene.background.changeTexture(to: newMood)
    }
    
}
