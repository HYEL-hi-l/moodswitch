//
//  MSObstacleTriangle.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//


import SpriteKit

class MSObstacleTriangle: MSObstacle {
    override func createShape() {
        let sideLength: CGFloat = 300
        let innerPadding: CGFloat = 30
        let moodSequence = MSMoodManager.shared.getRandomMoodSequence()
        
        let numberOfSections = 3
        
        let height = sideLength * sqrt(3) / 2
        
        let vertices = [
            CGPoint(x: -sideLength / 2, y: -height / 3),  // Bottom-left vertex
            CGPoint(x: sideLength / 2, y: -height / 3),   // Bottom-right vertex
            CGPoint(x: 0, y: 2 * height / 3)              // Top vertex
        ]
        
        let innerVertices = [
            CGPoint(x: -sideLength / 2 + innerPadding, y: -height / 3 + innerPadding * sqrt(3) / 3),  // Inner bottom-left
            CGPoint(x: sideLength / 2 - innerPadding, y: -height / 3 + innerPadding * sqrt(3) / 3),   // Inner bottom-right
            CGPoint(x: 0, y: 2 * height / 3 - innerPadding)                                          // Inner top
        ]
        
        for i in 0..<numberOfSections {
            let path = UIBezierPath()
            
            // Create triangle sections by connecting outer vertices and corresponding inner vertices
            path.move(to: vertices[i])
            path.addLine(to: vertices[(i + 1) % 3])
            path.addLine(to: innerVertices[(i + 1) % 3])
            path.addLine(to: innerVertices[i])
            
            path.close()
            
            let section = SKShapeNode(path: path.cgPath)
            section.fillColor = moodSequence[i].color
            section.strokeColor = moodSequence[i].color
            section.lineWidth = 0
            
            // Set up physics body for the section
            section.physicsBody = SKPhysicsBody(polygonFrom: path.cgPath)
            section.physicsBody?.categoryBitMask = MSPhysicsCategory.obstacle
            section.physicsBody?.contactTestBitMask = MSPhysicsCategory.ball
            section.physicsBody?.collisionBitMask = MSPhysicsCategory.none
            section.physicsBody?.affectedByGravity = false
            section.physicsBody?.isDynamic = false
            
            moods.append(moodSequence[i])
            addChild(section)
        }
        
        rotate(duration: 4.0)
    }
}
