//
//  MSObstacleSquare.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import Foundation
import SpriteKit

class MSObstacleSquare: MSObstacle {
    override func createShape() {
        let hypotenuse: CGFloat = layoutInfo.maxObstacleWidth
        let sideLength: CGFloat = sqrt((hypotenuse * hypotenuse) / 2)
        let innerPadding: CGFloat = 30
        let gapSize: CGFloat = 15
        let moodSequence = MSMoodManager.shared.getRandomMoodSequence()
        let initialDuration = layoutInfo.rotationDuration
        
        let numberOfSections = 4
        
        for i in 0..<numberOfSections {
            let path = createSectionPath(sideLength: sideLength, innerPadding: innerPadding, gapSize: gapSize, section: i)
            
            let glowNode = createGlowNode(path: path, color: moodSequence[i].color)
            addChild(glowNode)
            
            let section = createSectionNode(path: path, color: moodSequence[i].color)
            addChild(section)
            
            moods.append(moodSequence[i])
        }
        
        rotate(duration: initialDuration)
        
        initialRotationDuration = initialDuration
        currentRotationDuration = initialDuration
    }
    
    override func updateRotationSpeed(to speedMultiplier: CGFloat) {
        self.speed = speedMultiplier
    }
    
    private func createSectionPath(sideLength: CGFloat, innerPadding: CGFloat, gapSize: CGFloat, section: Int) -> CGPath {
        let path = UIBezierPath()
        let halfSide = sideLength / 2
        let innerHalfSide = halfSide - innerPadding
        let gapHalf = gapSize / 2
        
        switch section {
        case 0: // Top
            path.move(to: CGPoint(x: -halfSide + gapHalf, y: halfSide))
            path.addLine(to: CGPoint(x: halfSide - gapHalf, y: halfSide))
            path.addLine(to: CGPoint(x: innerHalfSide - gapHalf, y: innerHalfSide))
            path.addLine(to: CGPoint(x: -innerHalfSide + gapHalf, y: innerHalfSide))
        case 1: // Right
            path.move(to: CGPoint(x: halfSide, y: halfSide - gapHalf))
            path.addLine(to: CGPoint(x: halfSide, y: -halfSide + gapHalf))
            path.addLine(to: CGPoint(x: innerHalfSide, y: -innerHalfSide + gapHalf))
            path.addLine(to: CGPoint(x: innerHalfSide, y: innerHalfSide - gapHalf))
        case 2: // Bottom
            path.move(to: CGPoint(x: halfSide - gapHalf, y: -halfSide))
            path.addLine(to: CGPoint(x: -halfSide + gapHalf, y: -halfSide))
            path.addLine(to: CGPoint(x: -innerHalfSide + gapHalf, y: -innerHalfSide))
            path.addLine(to: CGPoint(x: innerHalfSide - gapHalf, y: -innerHalfSide))
        case 3: // Left
            path.move(to: CGPoint(x: -halfSide, y: -halfSide + gapHalf))
            path.addLine(to: CGPoint(x: -halfSide, y: halfSide - gapHalf))
            path.addLine(to: CGPoint(x: -innerHalfSide, y: innerHalfSide - gapHalf))
            path.addLine(to: CGPoint(x: -innerHalfSide, y: -innerHalfSide + gapHalf))
        default:
            break
        }
        
        path.close()
        return path.cgPath
    }
    
    private func createSectionNode(path: CGPath, color: UIColor) -> SKShapeNode {
        let section = SKShapeNode(path: path)
        section.fillColor = color
        section.strokeColor = color
        section.lineWidth = 0
        
        section.physicsBody = SKPhysicsBody(polygonFrom: path)
        section.physicsBody?.categoryBitMask = MSPhysicsCategory.obstacle
        section.physicsBody?.contactTestBitMask = MSPhysicsCategory.ball
        section.physicsBody?.collisionBitMask = MSPhysicsCategory.none
        section.physicsBody?.affectedByGravity = false
        section.physicsBody?.isDynamic = false
        
        return section
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
