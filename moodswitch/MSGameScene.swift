//
//  MSGameScene.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import SpriteKit

class MSGameScene: SKScene {
    
    unowned let context: MSGameContext
    var gameInfo: MSGameInfo? { context.gameInfo }
    var layoutInfo: MSLayoutInfo { context.layoutInfo }
    
    let obstacleManager = MSObstacleManager()

    var gameCamera: SKCameraNode?
    let scoreLabel = SKLabelNode()
    let background = MSBackground()
    var ball: MSBall!
    var powerUpIndicator: MSPowerUpIndicator!
    
    var activePowerUp: MSPowerUpType?
    let surgeRotationMultiplier: CGFloat = 0.5
    let slowRotationMultiplier: CGFloat = 1.5
    
    
    init(context: MSGameContext, size: CGSize) {
        self.context = context
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMove(to view: SKView) {
        setupScene()
        context.stateMachine?.enter(MSStartState.self)
    }

}


// MARK: Main Helpers
extension MSGameScene {
    
    func reset() {
        obstacleManager.reset()
        deactivatePowerUp()

        background.changeTexture(to: .happy)
        ball.changeMood(to: .happy)
        ball.position = layoutInfo.ballStartPosition
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        gameCamera?.position = CGPoint(x: size.width / 2, y: size.height / 2)

        gameInfo?.reset()
        scoreLabel.text = "\(gameInfo?.score ?? 0)"
        
        powerUpIndicator.resetMeter()
    }

    override func update(_ currentTime: TimeInterval) {
        context.stateMachine?.update(deltaTime: currentTime)
        
        let playerPositionInCamera = gameCamera?.convert(ball.position, from: self)
        if playerPositionInCamera!.y > 0 {
            gameCamera?.position.y = ball.position.y
        }
        if playerPositionInCamera!.y < -size.height / 2 {
            context.stateMachine?.enter(MSGameOverState.self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let state = context.stateMachine?.currentState as? MSGameState {
            state.touchesBegan(touches, with: event)
        }
    }
    
    func updateScore(with score: Int, mood: MSMoodType?) {
        gameInfo?.incrementScore(by: score)
        scoreLabel.text = "\(gameInfo?.score ?? 0)"
        
        if activePowerUp == nil {
            if let mood = mood {
                for _ in 0..<score {
                    powerUpIndicator.increaseProgress(for: mood)
                }
            }
        } else {
            for _ in 0..<score {
                powerUpIndicator.decreaseBigBarProgress()
            }
        }
    }
    
}


// MARK: Setup
extension MSGameScene {
    
    func setupScene() {
        setupEnvironment()
        setupCamera()
        setupBall()
        setupLedge()
        
//        setupPowerUpIndicator()
    }
    
    func setupEnvironment() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -17)
        backgroundColor = .gray
    }
    
    private func setupCamera() {
        gameCamera = SKCameraNode()
        if let gameCamera = gameCamera {
            gameCamera.position = CGPoint(x: size.width / 2, y: size.height / 2)
            self.camera = gameCamera
            addChild(gameCamera)
            
            scoreLabel.position = CGPoint(x: size.width * 0.4, y: size.height * 0.4)
            scoreLabel.fontColor = .white
            scoreLabel.fontSize = 50
            scoreLabel.zPosition = 1000
            scoreLabel.text = "\(gameInfo?.score ?? 0)"
            gameCamera.addChild(scoreLabel)
            
            gameCamera.addChild(background)
            background.setup(screenSize: self.size)
            
            
            powerUpIndicator = MSPowerUpIndicator(layoutInfo: layoutInfo)
            powerUpIndicator.delegate = self
            powerUpIndicator.position = CGPoint(x: -size.width * 0.4, y: -layoutInfo.powerUpIndicatorHeight / 2)
            gameCamera.addChild(powerUpIndicator)
        }
    }
    
    func setupBall() {
        ball = MSBall(radius: layoutInfo.ballRadius)
        ball.position = layoutInfo.ballStartPosition
        ball.physicsBody?.velocity = .zero
        ball.mood = .happy
        addChild(ball)
    }
    
    func setupLedge() {
        let ledge = SKNode()
        ledge.position = CGPoint(x: size.width / 2, y: layoutInfo.ledgeYPosition)
        let ledgeBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        ledgeBody.isDynamic = false
        ledgeBody.categoryBitMask = MSPhysicsCategory.ledge
        ledgeBody.collisionBitMask = MSPhysicsCategory.ball
        ledgeBody.contactTestBitMask = MSPhysicsCategory.ball
        ledge.physicsBody = ledgeBody
        addChild(ledge)
    }
    
}


// MARK: Power Ups
extension MSGameScene {
    
    func activatePowerUp(_ powerUp: MSPowerUpType) {
        activePowerUp = powerUp
        
        switch powerUp {
        case .surge: activateSurge()
        case .slow: activateSlow()
        }
    }
    
    func deactivatePowerUp() {
        switch activePowerUp {
        case .surge: deactivateSurge()
        case .slow: deactivateSlow()
        case .none: break
        }
        
        activePowerUp = nil
    }
    
    func activateSurge() {
        obstacleManager.obstacles.forEach { obstacle in
            obstacle.speedUpRotation(by: surgeRotationMultiplier)
        }
    }
    
    func deactivateSurge() {
        activePowerUp = nil
        obstacleManager.obstacles.forEach { obstacle in
            obstacle.resetRotationSpeed()
        }
    }
    
    func activateSlow() {
        obstacleManager.obstacles.forEach { obstacle in
            obstacle.slowDownRotation(by: slowRotationMultiplier)
        }
    }
    
    func deactivateSlow() {
        activePowerUp = nil
        obstacleManager.obstacles.forEach { obstacle in
            obstacle.resetRotationSpeed()
        }
    }
    
}


extension MSGameScene: MSPowerUpIndicatorDelegate {
    func powerUpActivated() {
        let powerUpTypes: [MSPowerUpType] = MSPowerUpType.allCases
        guard let selectedPowerUp = powerUpTypes.randomElement() else { return }
        
        activatePowerUp(selectedPowerUp)
    }
    
    func powerUpDeactivated() {
        deactivatePowerUp()
    }
}


// MARK: Contact Handling
extension MSGameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let categoryA = contact.bodyA.categoryBitMask
        let categoryB = contact.bodyB.categoryBitMask

        let collision = categoryA | categoryB

        if collision == (MSPhysicsCategory.ball | MSPhysicsCategory.obstacle) {
            handleBallObstacleCollision(contact: contact)
        } else if collision == (MSPhysicsCategory.ball | MSPhysicsCategory.moodSwitch) {
            handleBallMoodSwitchCollision(contact: contact)
        }
    }

    private func handleBallObstacleCollision(contact: SKPhysicsContact) {
        let ballNode = (contact.bodyA.categoryBitMask == MSPhysicsCategory.ball) ? contact.bodyA.node as? MSBall : contact.bodyB.node as? MSBall
        let obstacleNode = (contact.bodyA.categoryBitMask == MSPhysicsCategory.obstacle) ? contact.bodyA.node : contact.bodyB.node

        if let ball = ballNode, let obstacle = obstacleNode {
            if !MSMoodManager.shared.isMoodMatch(ball: ball, obstacle: obstacle) {
                context.stateMachine?.enter(MSGameOverState.self)
            }
        }
    }

    private func handleBallMoodSwitchCollision(contact: SKPhysicsContact) {
        guard let ballNode = (contact.bodyA.categoryBitMask == MSPhysicsCategory.ball) ? contact.bodyA.node as? MSBall : contact.bodyB.node as? MSBall else { return }
        guard let moodSwitchNode = (contact.bodyA.categoryBitMask == MSPhysicsCategory.moodSwitch) ? contact.bodyA.node as? MSMoodSwitcher : contact.bodyB.node as? MSMoodSwitcher else { return }

        let newMood = moodSwitchNode.getRandomMood(except: ballNode.mood ?? .happy)
        ballNode.changeMood(to: newMood)
        background.changeTexture(to: newMood)
        
        updateScore(with: 1, mood: newMood)
        
        if let index = obstacleManager.moodSwitches.firstIndex(of: moodSwitchNode) {
            obstacleManager.moodSwitches.remove(at: index)
        }
        moodSwitchNode.removeFromParent()
    }
}
