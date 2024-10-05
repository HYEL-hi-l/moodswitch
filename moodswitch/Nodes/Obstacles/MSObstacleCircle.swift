//
//  MSObstacleCircle.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import SpriteKit

class MSObstacleCircle: MSObstacle {
    override func createShape() {
        let outerRadius: CGFloat = layoutInfo.maxObstacleWidth / 2
        let innerRadius: CGFloat = (layoutInfo.maxObstacleWidth / 2) - layoutInfo.obstacleThickness
        let moodSequence = MSMoodManager.shared.getRandomMoodSequence()
        
        let numberOfSections = 4
        let gapAngle: CGFloat = (.pi / 36) * 0.75
        let totalGapAngle = gapAngle * CGFloat(numberOfSections)
        let anglePerSection = (2.0 * CGFloat.pi - totalGapAngle) / CGFloat(numberOfSections)
        
        for i in 0..<numberOfSections {
            let startAngle = CGFloat(i) * (anglePerSection + gapAngle) + gapAngle / 2
            let endAngle = startAngle + anglePerSection
            
            let path = createArcPath(outerRadius: outerRadius, innerRadius: innerRadius, startAngle: startAngle, endAngle: endAngle)
            
            let glowNode = createGlowNode(path: path, color: moodSequence[i].color)
            addChild(glowNode)

            let arc = createArcNode(path: path, color: moodSequence[i].color)
            addChild(arc)
            
            moods.append(moodSequence[i])
        }
        
        rotate(duration: layoutInfo.rotationDuration)
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
