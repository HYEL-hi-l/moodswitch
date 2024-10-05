//
//  MSObstacleTriangle.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import SpriteKit
import Foundation

class MSObstacleTriangle: MSObstacle {
    override func createShape() {
        let sideLength: CGFloat = layoutInfo.maxObstacleWidth
        let thickness: CGFloat = layoutInfo.obstacleThickness * 0.75
        let gapSize: CGFloat = 7.5
        let moodSequence = MSMoodManager.shared.getRandomMoodSequence()
        
        let numberOfSections = 3
        let height = sideLength * sqrt(3) / 2
        
        for i in 0..<numberOfSections {
            let path = createSectionPath(sideLength: sideLength, height: height, thickness: thickness, gapSize: gapSize, section: i)
            
            let glowNode = createGlowNode(path: path, color: moodSequence[i].color)
            addChild(glowNode)
            
            let section = createSectionNode(path: path, color: moodSequence[i].color)
            addChild(section)
            
            moods.append(moodSequence[i])
        }
        
        rotate(duration: layoutInfo.rotationDuration)
    }
    
    private func createSectionPath(sideLength: CGFloat, height: CGFloat, thickness: CGFloat, gapSize: CGFloat, section: Int) -> CGPath {
        let path = UIBezierPath()
        let halfSide = sideLength / 2
        let gapHalf = gapSize / 2
        let innerSideHypot = thickness * 2
        let innerSideOffset = sqrt((innerSideHypot * innerSideHypot) - (thickness * thickness))
        let gapTriangleHeight = sqrt((gapSize * gapSize) - (gapHalf * gapHalf))
        
        switch section {
        case 0: // Bottom side
            path.move(to: CGPoint(x: -halfSide + gapSize, y: -height / 3))
            path.addLine(to: CGPoint(x: halfSide - gapSize, y: -height / 3))
            path.addLine(to: CGPoint(x: halfSide - gapSize - innerSideOffset, y: -height / 3 + thickness))
            path.addLine(to: CGPoint(x: -halfSide + gapSize + innerSideOffset, y: -height / 3 + thickness))
        case 1: // Right side
            path.move(to: CGPoint(x: halfSide - gapHalf, y: -height / 3 + gapTriangleHeight))
            path.addLine(to: CGPoint(x: gapHalf, y: 2 * height / 3 - (2 * gapHalf / 3)))
            path.addLine(to: CGPoint(x: gapHalf, y: 2 * height / 3 - innerSideHypot))
            path.addLine(to: CGPoint(x: halfSide - gapHalf - innerSideOffset, y: -height / 3 + thickness + gapTriangleHeight))
        case 2: // Left side
            path.move(to: CGPoint(x: -halfSide + gapHalf, y: -height / 3 + gapTriangleHeight))
            path.addLine(to: CGPoint(x: -gapHalf, y: 2 * height / 3 - (2 * gapHalf / 3)))
            path.addLine(to: CGPoint(x: -gapHalf, y: 2 * height / 3 - innerSideHypot))
            path.addLine(to: CGPoint(x: -halfSide + gapHalf + innerSideOffset, y: -height / 3 + thickness + gapTriangleHeight))
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
