//
//  MSObstacleSquare.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//


import SpriteKit

class MSObstacleSquare: MSObstacle {
    override func createShape() {
        let sideLength: CGFloat = 215
        let innerPadding: CGFloat = 30
        let moodSequence = MSMoodManager.shared.getRandomMoodSequence()
        
        let numberOfSections = 4
        
        for i in 0..<numberOfSections {
            let path = UIBezierPath()
            
            switch i {
            case 0: // Top
                path.move(to: CGPoint(x: -sideLength/2, y: sideLength/2))
                path.addLine(to: CGPoint(x: sideLength/2, y: sideLength/2))
                path.addLine(to: CGPoint(x: sideLength/2 - innerPadding, y: sideLength/2 - innerPadding))
                path.addLine(to: CGPoint(x: -sideLength/2 + innerPadding, y: sideLength/2 - innerPadding))
            case 1: // Right
                path.move(to: CGPoint(x: sideLength/2, y: sideLength/2))
                path.addLine(to: CGPoint(x: sideLength/2, y: -sideLength/2))
                path.addLine(to: CGPoint(x: sideLength/2 - innerPadding, y: -sideLength/2 + innerPadding))
                path.addLine(to: CGPoint(x: sideLength/2 - innerPadding, y: sideLength/2 - innerPadding))
            case 2: // Bottom
                path.move(to: CGPoint(x: sideLength/2, y: -sideLength/2))
                path.addLine(to: CGPoint(x: -sideLength/2, y: -sideLength/2))
                path.addLine(to: CGPoint(x: -sideLength/2 + innerPadding, y: -sideLength/2 + innerPadding))
                path.addLine(to: CGPoint(x: sideLength/2 - innerPadding, y: -sideLength/2 + innerPadding))
            case 3: // Left
                path.move(to: CGPoint(x: -sideLength/2, y: -sideLength/2))
                path.addLine(to: CGPoint(x: -sideLength/2, y: sideLength/2))
                path.addLine(to: CGPoint(x: -sideLength/2 + innerPadding, y: sideLength/2 - innerPadding))
                path.addLine(to: CGPoint(x: -sideLength/2 + innerPadding, y: -sideLength/2 + innerPadding))
            default:
                break
            }
            
            path.close()
            
            let section = SKShapeNode(path: path.cgPath)
            section.fillColor = moodSequence[i].color
            section.strokeColor = moodSequence[i].color
            section.lineWidth = 0
            
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
