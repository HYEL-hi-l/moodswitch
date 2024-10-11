//
//  MSObstacleDoubleCircle.swift
//  moodswitch
//
//  Created by Sam Richard on 10/9/24.
//

import SpriteKit

class MSObstacleDoubleCircle: MSObstacle {
    
    private var outerCircleNode: SKNode!
    private var innerCircleNode: SKNode!
    
    override func createShape() {
        let outerRadius: CGFloat = layoutInfo.maxObstacleWidth / 2
        let thickness = layoutInfo.obstacleThickness
        let innerRadius: CGFloat = outerRadius - (thickness * 1.3)
        
        let moodSequence = MSMoodManager.shared.getRandomMoodSequenceForDoubleCircle()
        
        // Create outer circle node
        outerCircleNode = SKNode()
        createCircle(on: outerCircleNode, radius: outerRadius, thickness: thickness, moodSequence: moodSequence)
        addChild(outerCircleNode)
        
        innerCircleNode = SKNode()
        createCircle(on: innerCircleNode, radius: innerRadius, thickness: thickness * 0.75, moodSequence: moodSequence)
        addChild(innerCircleNode)
        
        moods.append(moodSequence[0])
        moods.append(moodSequence[2])
        
        let initialRotationAngle: CGFloat = CGFloat.pi / 4
        outerCircleNode.zRotation = initialRotationAngle
        innerCircleNode.zRotation = initialRotationAngle
        
        rotate(node: outerCircleNode, duration: layoutInfo.rotationDuration, clockwise: true)
        rotate(node: innerCircleNode, duration: layoutInfo.rotationDuration, clockwise: false)
        
        initialRotationDuration = layoutInfo.rotationDuration
        currentRotationDuration = layoutInfo.rotationDuration
    }
    
    private func createCircle(on parentNode: SKNode, radius: CGFloat, thickness: CGFloat, moodSequence: [MSMoodType]) {
        let outerRadius: CGFloat = radius
        let innerRadius: CGFloat = radius - thickness
        
        let numberOfSections = 4
        let gapAngle: CGFloat = (.pi / 36) * 0.75
        let totalGapAngle = gapAngle * CGFloat(numberOfSections)
        let anglePerSection = (2.0 * CGFloat.pi - totalGapAngle) / CGFloat(numberOfSections)
        
        for i in 0..<numberOfSections {
            let startAngle = CGFloat(i) * (anglePerSection + gapAngle) + gapAngle / 2
            let endAngle = startAngle + anglePerSection
            
            let path = createArcPath(outerRadius: outerRadius, innerRadius: innerRadius, startAngle: startAngle, endAngle: endAngle)
            
            let mood = moodSequence[i]
            
            let glowNode = createGlowNode(path: path, color: mood.color)
            parentNode.addChild(glowNode)
            
            let arc = createArcNode(path: path, color: mood.color)
            parentNode.addChild(arc)
        }
    }
    
    private func rotate(node: SKNode, duration: TimeInterval, clockwise: Bool) {
        let angle: CGFloat = clockwise ? CGFloat.pi * 2 : -CGFloat.pi * 2
        let rotateAction = SKAction.rotate(byAngle: angle, duration: duration)
        let repeatForever = SKAction.repeatForever(rotateAction)
        node.run(repeatForever, withKey: rotationActionKey)
    }
    
    override func updateRotationSpeed(to speedMultiplier: CGFloat) {
        outerCircleNode.speed = speedMultiplier
        innerCircleNode.speed = speedMultiplier
    }
    
    private func createArcPath(outerRadius: CGFloat, innerRadius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> CGPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: outerRadius * cos(startAngle), y: outerRadius * sin(startAngle)))
        path.addArc(withCenter: .zero, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.addLine(to: CGPoint(x: innerRadius * cos(endAngle), y: innerRadius * sin(endAngle)))
        path.addArc(withCenter: .zero, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        path.close()
        
        return path.cgPath
    }
    
    private func createArcNode(path: CGPath, color: UIColor) -> SKShapeNode {
        let arc = SKShapeNode(path: path)
        arc.fillColor = color
        arc.strokeColor = color
        arc.lineWidth = 0
        
        arc.physicsBody = SKPhysicsBody(polygonFrom: path)
        arc.physicsBody?.categoryBitMask = MSPhysicsCategory.obstacle
        arc.physicsBody?.contactTestBitMask = MSPhysicsCategory.ball
        arc.physicsBody?.collisionBitMask = MSPhysicsCategory.none
        arc.physicsBody?.affectedByGravity = false
        arc.physicsBody?.isDynamic = false
        
        return arc
    }
    
    private func createGlowNode(path: CGPath, color: UIColor) -> SKShapeNode {
        let glowPath = path.copy(strokingWithWidth: 1, lineCap: .round, lineJoin: .round, miterLimit: 0)
        let glowNode = SKShapeNode(path: glowPath)
        glowNode.fillColor = .clear
        glowNode.strokeColor = .black
        glowNode.lineWidth = 1
        glowNode.glowWidth = 1
        glowNode.zPosition = -1
        
        return glowNode
    }
}
