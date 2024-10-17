//
//  MSObstacleExpandingDotCircle.swift
//  moodswitch
//
//  Created by Sam Richard on 10/9/24.
//

import SpriteKit

class MSObstacleExpandingDotCircle: MSObstacle {
    
    private var smallCircles: [SKShapeNode] = []
    private var glowNodes: [SKShapeNode] = []
    
    private let gapMovementDistance: CGFloat = 80.0
    private let gapAnimationDuration: TimeInterval = 2.5
    
    override func createShape() {
        let outerRadius: CGFloat = layoutInfo.maxObstacleWidth * 0.35
        let moodSequence = MSMoodManager.shared.getRandomMoodSequence()
        
        let circumference = 2 * CGFloat.pi * outerRadius
        let gapFraction: CGFloat = 0.25
        let numberOfCircles = 20
        let smallCircleRadius = (circumference / CGFloat(numberOfCircles)) * (1 - gapFraction) / 2
        
        let angleStep = (2.0 * CGFloat.pi) / CGFloat(numberOfCircles)
        
        var lastMoodIndex = -1
        
        for i in 0..<numberOfCircles {
            let angle = CGFloat(i) * angleStep
            let x = (outerRadius - smallCircleRadius) * cos(angle)
            let y = (outerRadius - smallCircleRadius) * sin(angle)
            
            let moodIndex = (i * moodSequence.count) / numberOfCircles
            let color = moodSequence[moodIndex].color
            
            let smallCircle = createSmallCircle(at: CGPoint(x: x, y: y), radius: smallCircleRadius, color: color)
            addChild(smallCircle)
            smallCircles.append(smallCircle)
            
            let glowNode = createGlowNode(for: smallCircle, color: color)
            addChild(glowNode)
            glowNodes.append(glowNode)
            
            animateGap(for: smallCircle, glowNode: glowNode)
            
            if moodIndex != lastMoodIndex {
                moods.append(moodSequence[moodIndex])
                lastMoodIndex = moodIndex
            }
        }
        
        rotateObstacle()
    }
    
    override func updateRotationSpeed(to speedMultiplier: CGFloat) {
        self.speed = speedMultiplier
    }
    
    private func createSmallCircle(at position: CGPoint, radius: CGFloat, color: UIColor) -> SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.position = position
        circle.fillColor = color
        circle.strokeColor = color
        circle.lineWidth = 0
        
        circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        circle.physicsBody?.categoryBitMask = MSPhysicsCategory.obstacle
        circle.physicsBody?.contactTestBitMask = MSPhysicsCategory.ball
        circle.physicsBody?.collisionBitMask = MSPhysicsCategory.none
        circle.physicsBody?.affectedByGravity = false
        circle.physicsBody?.isDynamic = false
        
        return circle
    }
    
    private func createGlowNode(for circle: SKShapeNode, color: UIColor) -> SKShapeNode {
        let glowNode = SKShapeNode(circleOfRadius: circle.frame.width / 2 + 1)
        glowNode.position = circle.position
        glowNode.fillColor = .clear
        glowNode.strokeColor = .black
        glowNode.lineWidth = 1
        glowNode.glowWidth = 1
        glowNode.zPosition = -1
        
        return glowNode
    }
    
    private func animateGap(for circle: SKShapeNode, glowNode: SKShapeNode) {
        let direction = CGPoint(x: circle.position.x, y: circle.position.y).normalized()
        
        let moveOut = SKAction.move(by: CGVector(dx: direction.x * gapMovementDistance, dy: direction.y * gapMovementDistance), duration: gapAnimationDuration / 2)
        let moveIn = SKAction.move(by: CGVector(dx: -direction.x * gapMovementDistance, dy: -direction.y * gapMovementDistance), duration: gapAnimationDuration / 2)
        
        let sequence = SKAction.sequence([moveOut, moveIn])
        
        let repeatForever = SKAction.repeatForever(sequence)
        
        circle.run(repeatForever)
        glowNode.run(repeatForever)
    }
    
    private func rotateObstacle() {
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: layoutInfo.rotationDuration)
        let repeatForever = SKAction.repeatForever(rotateAction)
        self.run(repeatForever, withKey: rotationActionKey)
    }
}

extension CGPoint {
    func normalized() -> CGPoint {
        let length = sqrt(x * x + y * y)
        guard length != 0 else { return CGPoint.zero }
        return CGPoint(x: x / length, y: y / length)
    }
}
