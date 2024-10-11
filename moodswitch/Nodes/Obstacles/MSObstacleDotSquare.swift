//
//  MSObstacleDotSquare.swift
//  moodswitch
//
//  Created by Sam Richard on 10/7/24.
//

import SpriteKit

class MSObstacleDotSquare: MSObstacle {
    private var smallCircles: [SKShapeNode] = []
    private var glowNodes: [SKShapeNode] = []
    
    override func createShape() {
        let sideLength: CGFloat = layoutInfo.maxObstacleWidth * 0.65
        let moodSequence = MSMoodManager.shared.getRandomMoodSequence()
        let initialDuration = layoutInfo.rotationDuration * 0.85
        
        let halfSide = sideLength / 2
        
        let pointA = CGPoint(x: -halfSide, y: halfSide)
        let pointB = CGPoint(x: halfSide, y: halfSide)
        let pointC = CGPoint(x: halfSide, y: -halfSide)
        let pointD = CGPoint(x: -halfSide, y: -halfSide)
        
        let path = CGMutablePath()
        path.move(to: pointA)
        path.addLine(to: pointB)
        path.addLine(to: pointC)
        path.addLine(to: pointD)
        path.closeSubpath()
        
        let perimeter = 4 * sideLength
        
        let circleSpacing: CGFloat = layoutInfo.obstacleThickness * 1.2
        let numberOfCircles = Int(perimeter / circleSpacing)
        
        var lastMoodIndex = -1
        
        for i in 0..<numberOfCircles {
            let fraction = CGFloat(i) / CGFloat(numberOfCircles)
            let position = pointAlongSquarePath(fraction: fraction, pointA: pointA, pointB: pointB, pointC: pointC, pointD: pointD)
            
            let moodIndex = (i * moodSequence.count) / numberOfCircles
            let color = moodSequence[moodIndex].color
            
            let smallCircle = createSmallCircle(at: position, radius: layoutInfo.obstacleThickness / 2, color: color)
            addChild(smallCircle)
            smallCircles.append(smallCircle)  // Store reference to small circle
            
            let glowNode = createGlowNode(for: smallCircle, color: color)
            addChild(glowNode)
            glowNodes.append(glowNode)  // Store reference to glow node
            
            let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, duration: initialDuration)
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
    
    private func pointAlongSquarePath(fraction: CGFloat, pointA: CGPoint, pointB: CGPoint, pointC: CGPoint, pointD: CGPoint) -> CGPoint {
        let sideLength = distanceBetween(point1: pointA, point2: pointB)
        let perimeter = 4 * sideLength
        let distance = fraction * perimeter
        
        if distance <= sideLength {
            let t = distance / sideLength
            return CGPoint(x: pointA.x + t * (pointB.x - pointA.x),
                           y: pointA.y + t * (pointB.y - pointA.y))
        } else if distance <= 2 * sideLength {
            let t = (distance - sideLength) / sideLength
            return CGPoint(x: pointB.x + t * (pointC.x - pointB.x),
                           y: pointB.y + t * (pointC.y - pointB.y))
        } else if distance <= 3 * sideLength {
            let t = (distance - 2 * sideLength) / sideLength
            return CGPoint(x: pointC.x + t * (pointD.x - pointC.x),
                           y: pointC.y + t * (pointD.y - pointC.y))
        } else {
            let t = (distance - 3 * sideLength) / sideLength
            return CGPoint(x: pointD.x + t * (pointA.x - pointD.x),
                           y: pointD.y + t * (pointA.y - pointD.y))
        }
    }
    
    private func distanceBetween(point1: CGPoint, point2: CGPoint) -> CGFloat {
        return hypot(point2.x - point1.x, point2.y - point1.y)
    }
}
