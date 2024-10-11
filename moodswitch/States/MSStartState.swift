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
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {   }
}

class MSStartState: MSGameState {
    
    let titleNode = SKNode()
    let howLabel = SKLabelNode(text: "HOW")
    let youLabel = SKLabelNode(text: "YOU")
    let feelLabel = SKLabelNode(text: "FEEL?")
    let upArrowNode = SKShapeNode()

    private var lastTapTime: TimeInterval = 0
    private var tapCount = 0
    private let cooldownDuration: TimeInterval = 0.7
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is MSPlayState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        print("* Entered Start State *")
        
        resetState()
        setupUI()
    }
    
    override func willExit(to nextState: GKState) {
        titleNode.removeAllActions()
        titleNode.run(SKAction.fadeOut(withDuration: 1.0)) {
            self.titleNode.removeAllChildren()
            self.titleNode.removeFromParent()
            self.resetState()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentTime = CACurrentMediaTime()
        
        if tapCount < 5 {
            if currentTime - lastTapTime >= cooldownDuration {
                lastTapTime = currentTime
                handleTap()
            }
        } else {
            handleTap()
        }
    }
    
}


// MARK: Main
extension MSStartState {
    
    override func update(deltaTime: TimeInterval) {
        if let firstObstacle = gameScene.obstacleManager.obstacles.first {
            let distance = firstObstacle.position.y - gameScene.ball.position.y
            if distance < gameScene.size.height * 0.75 {
                gameScene.context.stateMachine?.enter(MSPlayState.self)
            }
        }
    }
    
    func resetState() {
        tapCount = 0
        lastTapTime = 0
        
        [howLabel, youLabel, feelLabel, upArrowNode].forEach { node in
            node.alpha = 0.0
            node.removeAllActions()
        }
        
        titleNode.removeAllChildren()
        titleNode.removeFromParent()
    }
    
}


// MARK: Setup
extension MSStartState {
    
    func setupUI() {
        setupTitleNode()
        gameScene.obstacleManager.updateObstacles(in: gameScene, ballPositionY: gameScene.ball.position.y, currentScore: gameScene.gameInfo?.score ?? 0)
        gameScene.obstacleManager.lastObstacleYPosition = gameScene.layoutInfo.firstObstacleYPosition
    }
    
    func setupTitleNode() {
        let labels = [howLabel, youLabel, feelLabel]
        let fontSize: CGFloat = 118

        for label in labels {
            label.fontSize = fontSize
            label.fontName = "SF-Pro-Rounded"
            label.alpha = 0.0
            label.position = CGPoint(x: 0, y: 0)
            
        }

        titleNode.position = CGPoint(x: gameScene.frame.midX, y: gameScene.frame.midY + gameScene.frame.height * 0)
        titleNode.zPosition = -1
        titleNode.alpha = 1.0
        gameScene.addChild(titleNode)
        
        setupUpArrow()

        titleNode.addChild(howLabel)
        titleNode.addChild(youLabel)
        titleNode.addChild(feelLabel)
        titleNode.addChild(upArrowNode)
    }
    
    func setupUpArrow() {
        let arrowHeight: CGFloat = 60
        let arrowWidth: CGFloat = 40
        let lineWidth: CGFloat = 4
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: arrowHeight))
        path.move(to: CGPoint(x: 0, y: arrowHeight))
        path.addLine(to: CGPoint(x: -arrowWidth / 2, y: arrowHeight - arrowWidth / 2))
        path.move(to: CGPoint(x: 0, y: arrowHeight))
        path.addLine(to: CGPoint(x: arrowWidth / 2, y: arrowHeight - arrowWidth / 2))
        
        upArrowNode.path = path
        upArrowNode.strokeColor = .white
        upArrowNode.lineWidth = lineWidth
        upArrowNode.lineCap = .round
        upArrowNode.alpha = 0.0
        upArrowNode.zPosition = -1

        
        upArrowNode.setScale(1.0)
        upArrowNode.position = CGPoint(x: 0, y: 50)
    }
    
}


// MARK: Helpers
extension MSStartState {
    
    func handleTap() {
        switch tapCount {
        case 0:
            animateLabel(howLabel)
            changeMood(to: .happy)
        case 1:
            animateLabel(youLabel)
            changeMood(to: .sad)
        case 2:
            animateLabel(feelLabel)
            changeMood(to: .angry)
        case 3:
            showUpArrow()
            gameScene.powerUpIndicator.isHidden = false
            changeMood(to: .inlove)
        default:
            break
        }
        
        jump()
        tapCount += 1
    }
    
    func animateLabel(_ label: SKLabelNode) {
        let fadeIn = SKAction.fadeIn(withDuration: cooldownDuration * 2/3)
        let fadeOut = SKAction.fadeOut(withDuration: cooldownDuration * 1/3)
        let sequence = SKAction.sequence([fadeIn, fadeOut])
        label.run(sequence)
    }
    
    func showUpArrow() {
        let fadeIn = SKAction.fadeIn(withDuration: cooldownDuration * 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: cooldownDuration * 2.5)
        let sequence = SKAction.sequence([fadeIn, fadeOut])
        let repeatAction = SKAction.repeatForever(sequence)
        
        upArrowNode.run(repeatAction)
    }
    
    func jump() {
        if tapCount < 4 {
            gameScene.ball.jump(.doubleJump)
        } else {
            gameScene.ball.jump(.normal)
        }
    }

    private func changeMoodRandomly() {
        guard let currentMood = gameScene.ball.mood else { return }
        
        var newMood = MSMoodManager.shared.getRandomMood()
        while newMood == currentMood {
            newMood = MSMoodManager.shared.getRandomMood()
        }
        
        gameScene.ball.changeMood(to: newMood)
        gameScene.background.flashTexture(with: newMood, for: cooldownDuration)
    }
    
    private func changeMood(to mood: MSMoodType) {
        guard let currentMood = gameScene.ball.mood else { return }
        
        gameScene.ball.changeMood(to: mood)
        gameScene.background.flashTexture(with: mood, for: cooldownDuration)
    }
    
}
