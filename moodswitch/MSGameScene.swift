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
    
    var gameCamera: SKCameraNode?
    let scoreLabel = SKLabelNode()
    let background = MSBackground()

    let ball = MSBall()
    let obstacleManager = MSObstacleManager()

    
    init(context: MSGameContext, size: CGSize) {
        self.context = context
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -15)
        
        setupCamera()
        setupScene()
        context.stateMachine?.enter(MSStartState.self)
    }
    
    private func setupCamera() {
        gameCamera = SKCameraNode()
        if let gameCamera = gameCamera {
            gameCamera.position = CGPoint(x: size.width / 2, y: size.height / 2)
            self.camera = gameCamera
            addChild(gameCamera)
            
            scoreLabel.position = CGPoint(x: -size.width * 0.4, y: size.height * 0.35)
            scoreLabel.fontColor = .white
            scoreLabel.fontSize = 50
            scoreLabel.zPosition = 1000
            scoreLabel.text = "\(gameInfo?.score ?? 0)"
            gameCamera.addChild(scoreLabel)
            
            gameCamera.addChild(background)
            background.setup(screenSize: self.size)
        }
        

    }
    
    func setupScene() {
        backgroundColor = .gray
        addChild(ball)
        ball.position = CGPoint(x: frame.midX, y: frame.minY + 200)
        
        let ledge = SKNode()
        ledge.position = CGPoint(x: size.width/2, y: 160)
        let ledgeBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 10))
        ledgeBody.isDynamic = false
        ledgeBody.categoryBitMask = MSPhysicsCategory.ledge
        ledgeBody.collisionBitMask = MSPhysicsCategory.ball
        ledgeBody.contactTestBitMask = MSPhysicsCategory.ball
        ledge.physicsBody = ledgeBody
        addChild(ledge)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let state = context.stateMachine?.currentState as? MSGameState {
            state.touchesBegan(touches, with: event)
        }
    }
    
    func reset() {
        ball.changeMood(to: .happy)
        ball.physicsBody?.velocity.dy = 0
//        ball.removeFromParent()
        
        obstacleManager.reset()
        
        gameCamera?.position = CGPoint(x: size.width/2, y: size.height/2)
        gameInfo?.reset()
        scoreLabel.text = "\(gameInfo?.score ?? 0)"
    }

    override func update(_ currentTime: TimeInterval) {
        context.stateMachine?.update(deltaTime: currentTime)
        
        let playerPositionInCamera = gameCamera?.convert(ball.position, from: self)
        if playerPositionInCamera!.y > 0 {
            gameCamera?.position.y = ball.position.y
        }
        
        if playerPositionInCamera!.y < -size.height/2 {
            context.stateMachine?.enter(MSGameOverState.self)
        }
    }
}


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

        print("Mood Switch Collision")
        let newMood = moodSwitchNode.getRandomMood()
        print("newMood:", newMood)
        ballNode.changeMood(to: newMood)
        background.changeTexture(to: ballNode.mood!)
        moodSwitchNode.removeFromParent()
        
        if let index = obstacleManager.moodSwitches.firstIndex(of: moodSwitchNode) {
            print("removed", moodSwitchNode)
            obstacleManager.moodSwitches.remove(at: index)
        }
    }
}
