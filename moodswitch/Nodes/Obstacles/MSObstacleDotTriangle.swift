//
//  MSObstacleDotTriangle.swift
//  moodswitch
//
//  Created by Sam Richard on 10/7/24.
//

import SpriteKit

class MSObstacleDotTriangle: MSObstacle {
    private var smallCircles: [SKShapeNode] = []
    private var glowNodes: [SKShapeNode] = []
    private var trianglePath: CGPath!
    
    override func createShape() {
        let sideLength: CGFloat = layoutInfo.maxObstacleWidth
        let moodSequence = MSMoodManager.shared.getRandomMoodSequence()
        let initialDuration = layoutInfo.rotationDuration
        
        let halfSide = sideLength / 2
        let height = sideLength * sqrt(3) / 2
        
        let pointA = CGPoint(x: 0, y: height / 2)
        let pointB = CGPoint(x: -halfSide, y: -height / 2)
        let pointC = CGPoint(x: halfSide, y: -height / 2)
        
        let path = CGMutablePath()
        path.move(to: pointA)
        path.addLine(to: pointB)
        path.addLine(to: pointC)
        path.closeSubpath()
        trianglePath = path.copy()
        
        let side = sideLength
        let perimeter = 3 * side
        
        let circleSpacing: CGFloat = layoutInfo.obstacleThickness * 1.2
        let numberOfCircles = Int(perimeter / circleSpacing)
        
        var lastMoodIndex = -1
        
        for i in 0..<numberOfCircles {
            let fraction = CGFloat(i) / CGFloat(numberOfCircles)
            let position = pointAlongTrianglePath(fraction: fraction, pointA: pointA, pointB: pointB, pointC: pointC)
            
            let moodIndex = (i * moodSequence.count) / numberOfCircles
            let color = moodSequence[moodIndex].color
            
            let smallCircle = createSmallCircle(at: position, radius: layoutInfo.obstacleThickness / 2, color: color)
            addChild(smallCircle)
            smallCircles.append(smallCircle)
            
            let glowNode = createGlowNode(for: smallCircle, color: color)
            addChild(glowNode)
            glowNodes.append(glowNode)
            
            let moveAction = SKAction.follow(trianglePath, asOffset: false, orientToPath: false, duration: initialDuration)
            let repeatAction = SKAction.repeatForever(moveAction)
            
            let delay = (initialDuration / Double(numberOfCircles)) * Double(i)
            let actionSequence = SKAction.sequence([SKAction.wait(forDuration: delay), repeatAction])
            smallCircle.run(actionSequence)
            glowNode.run(actionSequence)
            
            if moodIndex != lastMoodIndex {
                moods.append(moodSequence[moodIndex])
                lastMoodIndex = moodIndex
            }
        }
        
        initialRotationDuration = initialDuration
        currentRotationDuration = initialDuration
    }
    
    override func updateRotationSpeed(to speedMultiplier: CGFloat) {
        for circle in smallCircles {
            circle.speed = speedMultiplier
        }
        for glowNode in glowNodes {
            glowNode.speed = speedMultiplier
        }
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
    
    private func pointAlongTrianglePath(fraction: CGFloat, pointA: CGPoint, pointB: CGPoint, pointC: CGPoint) -> CGPoint {
        let sideLength = distanceBetween(point1: pointA, point2: pointB)
        let perimeter = 3 * sideLength
        let distance = fraction * perimeter
        
        if distance <= sideLength {
            let t = distance / sideLength
            return CGPoint(x: pointA.x + t * (pointB.x - pointA.x),
                           y: pointA.y + t * (pointB.y - pointA.y))
        } else if distance <= 2 * sideLength {
            let t = (distance - sideLength) / sideLength
            return CGPoint(x: pointB.x + t * (pointC.x - pointB.x),
                           y: pointB.y + t * (pointC.y - pointB.y))
        } else {
            let t = (distance - 2 * sideLength) / sideLength
            return CGPoint(x: pointC.x + t * (pointA.x - pointC.x),
                           y: pointC.y + t * (pointA.y - pointC.y))
        }
    }
    
    private func distanceBetween(point1: CGPoint, point2: CGPoint) -> CGFloat {
        return hypot(point2.x - point1.x, point2.y - point1.y)
    }
}
