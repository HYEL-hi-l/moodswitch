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
    
    private var activePowerUpSprite: SKSpriteNode?
    private var powerUpAccentCircle = SKShapeNode()
    var activePowerUp: MSPowerUpType?
    let surgeRotationMultiplier: CGFloat = 1.5
    let slowRotationMultiplier: CGFloat = 0.5
    var isInvincible = true
    private var isDead = false
    
    var happyFallingEmitter: SKEmitterNode?
    var sadFallingEmitter: SKEmitterNode?
    var angryFallingEmitter: SKEmitterNode?
    var inLoveFallingEmitter: SKEmitterNode?
    
    private let moodColors: [MSMoodType: UIColor] = {
        return [
            .angry: MSMoodType.angry.color,
            .happy: MSMoodType.happy.color,
            .sad: MSMoodType.sad.color,
            .inlove: MSMoodType.inlove.color
        ]
    }()
    
    
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

        isDead = false
        children.filter { $0.name == "deathParticle" }.forEach { $0.removeFromParent() }
        ball.changeMood(to: .moodless)
        ball.alpha = 1.0
        ball.position = layoutInfo.ballStartPosition
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.zRotation = 0.0
        
        gameCamera?.position = CGPoint(x: size.width / 2, y: size.height / 2)

        gameInfo?.reset()
        scoreLabel.text = "\(gameInfo?.score ?? 0)"
        scoreLabel.alpha = 0.0
        
        powerUpIndicator.resetMeter()
        let spacing = 30.0
        let offset = 200.0
        powerUpIndicator.position = CGPoint(x: -size.width * 0.5 + layoutInfo.powerUpIndicatorHeight / 2 + spacing - offset, y: -size.height * 0.5 + layoutInfo.powerUpIndicatorHeight / 2 + spacing)
        
        activePowerUpSprite?.texture = nil
        activePowerUpSprite?.alpha = 0.0
        powerUpAccentCircle.alpha = 0.0
        powerUpAccentCircle.removeAllActions()
    }

    override func update(_ currentTime: TimeInterval) {
        context.stateMachine?.update(deltaTime: currentTime)
        
        let playerPositionInCamera = gameCamera?.convert(ball.position, from: self)
        if playerPositionInCamera!.y > 0 {
            gameCamera?.position.y = ball.position.y
        }
        if playerPositionInCamera!.y < -size.height / 2 {
            if !isDead {
                isDead = true
                deathEffect(at: ball.position)
            }
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
                powerUpIndicator.decreasePowerUpProgress()
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
    }
    
    func setupEnvironment() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -17)
        backgroundColor = .black
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
            scoreLabel.alpha = 0.0
            gameCamera.addChild(scoreLabel)
            
            gameCamera.addChild(background)
            background.setup(screenSize: self.size)
            
            
            powerUpIndicator = MSPowerUpIndicator(layoutInfo: layoutInfo)
            powerUpIndicator.delegate = self
            let spacing = 30.0
            let offset = 200.0
            powerUpIndicator.position = CGPoint(x: -size.width * 0.5 + layoutInfo.powerUpIndicatorHeight / 2 + spacing - offset, y: -size.height * 0.5 + layoutInfo.powerUpIndicatorHeight / 2 + spacing)
            gameCamera.addChild(powerUpIndicator)
            
            activePowerUpSprite = SKSpriteNode(texture: SKTexture(imageNamed: "invincible"))
            activePowerUpSprite?.position = CGPoint(x: 0, y: size.height * 0.3)
            activePowerUpSprite?.zPosition = 1000
            activePowerUpSprite?.alpha = 0.0
            gameCamera.addChild(activePowerUpSprite!)
            
            let radius = ((activePowerUpSprite?.size.width ?? size.height * 0.10) * 0.725) * 1.15
            let segmentAngle = 90.0
            let moods: [MSMoodType] = [.angry, .happy, .sad, .inlove]
            
            for (index, mood) in moods.enumerated() {
                let startAngle = CGFloat(index) * CGFloat(segmentAngle) * CGFloat.pi / 180
                let endAngle = startAngle + CGFloat(segmentAngle) * CGFloat.pi / 180
                
                let path = createSectorPath(radius: radius, startAngle: startAngle, endAngle: endAngle)
                
                let segment = SKShapeNode(path: path)
                segment.fillColor = moodColors[mood] ?? .white.withAlphaComponent(0.5)
                segment.strokeColor = .clear
                segment.zPosition = 0
                
                powerUpAccentCircle.addChild(segment)
            }
            
            powerUpAccentCircle.position = CGPoint(x: 0, y: size.height * 0.3)
            powerUpAccentCircle.zPosition = 950
            powerUpAccentCircle.alpha = 0.0
            
            let powerUpAccentCircleFill = SKShapeNode(circleOfRadius: (activePowerUpSprite?.size.width ?? size.height * 0.10) * 0.725)
            powerUpAccentCircleFill.fillColor = .black
            powerUpAccentCircleFill.strokeColor = .clear
            powerUpAccentCircleFill.position = CGPoint(x: 0, y: 0)
            powerUpAccentCircleFill.zPosition = 1
            powerUpAccentCircle.addChild(powerUpAccentCircleFill)
            gameCamera.addChild(powerUpAccentCircle)
            
            
            let xPosition = size.width / 2
            let yPosition = size.height * 1.2
            let emitterFileName = "FallingFaces"
            let emitterZPosition: CGFloat = -1.0
            let emitterAlpha: CGFloat = 0.0
                    
            happyFallingEmitter = SKEmitterNode(fileNamed: emitterFileName) ?? SKEmitterNode()
            happyFallingEmitter?.particleTexture = SKTexture(imageNamed: MSMoodType.happy.textureName)
            happyFallingEmitter?.position = CGPoint(x: xPosition, y: yPosition)
            happyFallingEmitter?.zPosition = emitterZPosition
            happyFallingEmitter?.alpha = emitterAlpha

            sadFallingEmitter = SKEmitterNode(fileNamed: emitterFileName) ?? SKEmitterNode()
            sadFallingEmitter?.particleTexture = SKTexture(imageNamed: MSMoodType.sad.textureName)
            sadFallingEmitter?.position = CGPoint(x: xPosition, y: yPosition)
            sadFallingEmitter?.zPosition = emitterZPosition
            sadFallingEmitter?.alpha = emitterAlpha
            
            angryFallingEmitter = SKEmitterNode(fileNamed: emitterFileName) ?? SKEmitterNode()
            angryFallingEmitter?.particleTexture = SKTexture(imageNamed: MSMoodType.angry.textureName)
            angryFallingEmitter?.position = CGPoint(x: xPosition, y: yPosition)
            angryFallingEmitter?.zPosition = emitterZPosition
            angryFallingEmitter?.alpha = emitterAlpha
            
            inLoveFallingEmitter = SKEmitterNode(fileNamed: emitterFileName) ?? SKEmitterNode()
            inLoveFallingEmitter?.particleTexture = SKTexture(imageNamed: MSMoodType.inlove.textureName)
            inLoveFallingEmitter?.position = CGPoint(x: xPosition, y: yPosition)
            inLoveFallingEmitter?.zPosition = emitterZPosition
            inLoveFallingEmitter?.alpha = emitterAlpha
            
            gameCamera.addChild(happyFallingEmitter!)
            gameCamera.addChild(sadFallingEmitter!)
            gameCamera.addChild(angryFallingEmitter!)
            gameCamera.addChild(inLoveFallingEmitter!)
        }
    }
    
    private func createSectorPath(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addArc(center: CGPoint.zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
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
        case .invincible: activateInvincible()
        }
    }
    
    func deactivatePowerUp() {
        switch activePowerUp {
        case .surge: deactivateSurge()
        case .slow: deactivateSlow()
        case .invincible: deactivateInvincible()
        case .none: break
        }
        
        activePowerUp = nil
    }
    
    func activateSurge() {
        obstacleManager.speedUpRotation(by: surgeRotationMultiplier)
    }
    
    func deactivateSurge() {
        obstacleManager.resetRotationSpeed()
    }
    
    func activateSlow() {
        obstacleManager.slowDownRotation(by: slowRotationMultiplier)
    }
    
    func deactivateSlow() {
        obstacleManager.resetRotationSpeed()
    }
    
    func activateInvincible() {
        isInvincible = true
    }
    
    func deactivateInvincible() {
        isInvincible = false
    }
    
}


extension MSGameScene: MSPowerUpIndicatorDelegate {
    func powerUpActivated() {
        let powerUpTypes: [MSPowerUpType] = MSPowerUpType.allCases
        guard let selectedPowerUp = powerUpTypes.randomElement() else { return }
//        let selectedPowerUp = MSPowerUpType.invincible
        
        activatePowerUp(selectedPowerUp)
        
        switch selectedPowerUp {
        case .surge:
            let texture = SKTexture(imageNamed: "surge")
            activePowerUpSprite?.texture = texture
            activePowerUpSprite?.size = texture.size()
        case .slow:
            let texture = SKTexture(imageNamed: "slow")
            activePowerUpSprite?.texture = texture
            activePowerUpSprite?.size = texture.size()
        case .invincible:
            let texture = SKTexture(imageNamed: "invincible")
            activePowerUpSprite?.texture = texture
            activePowerUpSprite?.size = texture.size()
        }
        
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let wait = SKAction.wait(forDuration: 1.0)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown, wait])
        let repeatScale = SKAction.repeatForever(scaleSequence)
        let group = SKAction.group([fadeIn, repeatScale])
        activePowerUpSprite?.run(group)
        
        let spinAction = SKAction.rotate(byAngle: .pi * 2, duration: 4.0)
        let repeatSpin = SKAction.repeatForever(spinAction)
        let showAndSpin = SKAction.group([fadeIn, repeatSpin])
        powerUpAccentCircle.run(showAndSpin)

    }
    
    func powerUpDeactivated() {
        deactivatePowerUp()
        
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        powerUpAccentCircle.run(fadeOut) {
            self.powerUpAccentCircle.removeAllActions()
        }
        activePowerUpSprite?.run(fadeOut) {
            self.activePowerUpSprite?.removeAllActions()
        }
    }
    
    func deathEffect(at position: CGPoint) {
        ball.alpha = 0.0
        
        let numberOfParticles = 30
        
        guard let ballTexture = ball.texture else { return }
        
        for _ in 0..<numberOfParticles {
            let particle = SKSpriteNode(texture: ballTexture)
            particle.size = ball.size
            particle.alpha = 0.75
            particle.setScale(0.5)
            particle.position = position
            
            particle.name = "deathParticle"
            
            particle.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
            particle.physicsBody?.velocity = CGVector(dx: CGFloat.random(in: -500...500), dy: CGFloat.random(in: -500...500))
            particle.physicsBody?.affectedByGravity = true
            particle.physicsBody?.restitution = 0.8
            particle.physicsBody?.friction = 0.2
            particle.physicsBody?.linearDamping = 0.1
            particle.physicsBody?.collisionBitMask = 0
            particle.physicsBody?.contactTestBitMask = 0
            
            addChild(particle)
        }
        
        let wait = SKAction.wait(forDuration: 1.25)
        let resetAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.context.stateMachine?.enter(MSGameOverState.self)
        }
        run(SKAction.sequence([wait, resetAction]))
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

        if isInvincible { return }
        
        if let ball = ballNode, let obstacle = obstacleNode {
            if !MSMoodManager.shared.isMoodMatch(ball: ball, obstacle: obstacle) {
                if !isDead {
                    isDead = true
                    deathEffect(at: ball.position)
                }
            }
        }
    }

    private func handleBallMoodSwitchCollision(contact: SKPhysicsContact) {
        guard let ballNode = (contact.bodyA.categoryBitMask == MSPhysicsCategory.ball) ? contact.bodyA.node as? MSBall : contact.bodyB.node as? MSBall else { return }
        guard let moodSwitchNode = (contact.bodyA.categoryBitMask == MSPhysicsCategory.moodSwitch) ? contact.bodyA.node as? MSMoodSwitcher : contact.bodyB.node as? MSMoodSwitcher else { return }


        
        let newMood = moodSwitchNode.getRandomMood(except: ballNode.mood ?? .happy)
        
        updateScore(with: 1, mood: newMood)

        if isInvincible {
            ballNode.changeMood(to: .moodless)
        } else {
            ballNode.changeMood(to: newMood)
        }

        
        if let index = obstacleManager.moodSwitches.firstIndex(of: moodSwitchNode) {
            obstacleManager.moodSwitches.remove(at: index)
        }
        moodSwitchNode.removeFromParent()
    }
}
