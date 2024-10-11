//
//  MSObstacleDotCircle.swift
//  moodswitch
//
//  Created by Sam Richard on 10/7/24.
//

import SpriteKit

class MSObstacleDotCircle: MSObstacle {
    private var smallCircles: [SKShapeNode] = []
        private var glowNodes: [SKShapeNode] = []
        
        override func createShape() {
            let outerRadius: CGFloat = (layoutInfo.maxObstacleWidth * 0.75) / 2 
            let moodSequence = MSMoodManager.shared.getRandomMoodSequence()
            let initialDuration = layoutInfo.rotationDuration
            
            let circumference = 2 * CGFloat.pi * outerRadius
            let gapFraction: CGFloat = 0.25
            let numberOfCircles = 25
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
            }
            
            rotate(duration: initialDuration)
            
            initialRotationDuration = initialDuration
            currentRotationDuration = initialDuration
            
            moods = moodSequence
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
}
