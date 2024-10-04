//
//  MSObstacleCircle.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import SpriteKit

class MSObstacleCircle: MSObstacle {
    override func createShape() {
        let innerRadius: CGFloat = 120
        let outerRadius: CGFloat = 150
        var moodSequence = MSMoodManager.shared.getRandomMoodSequence()
        
        let numberOfSections = 4
        let anglePerSection = (2.0 * CGFloat.pi) / CGFloat(numberOfSections)
        
        for i in 0..<numberOfSections {
            let startAngle = CGFloat(i) * anglePerSection
            let endAngle = startAngle + anglePerSection
            
            let path = UIBezierPath()
            
            path.move(to: CGPoint(x: outerRadius * cos(startAngle), y: outerRadius * sin(startAngle)))
            path.addArc(withCenter: .zero,
                        radius: outerRadius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true)
            
            path.addArc(withCenter: .zero,
                        radius: innerRadius,
                        startAngle: endAngle,
                        endAngle: startAngle,
                        clockwise: false)
            
            path.close()
            
            let arc = SKShapeNode(path: path.cgPath)
            arc.fillColor = moodSequence[i].color
            arc.strokeColor = moodSequence[i].color
            arc.lineWidth = 0
            
            arc.physicsBody = SKPhysicsBody(polygonFrom: path.cgPath)
            arc.physicsBody?.categoryBitMask = MSPhysicsCategory.obstacle
            arc.physicsBody?.contactTestBitMask = MSPhysicsCategory.ball
            arc.physicsBody?.collisionBitMask = MSPhysicsCategory.none
            arc.physicsBody?.affectedByGravity = false
            arc.physicsBody?.isDynamic = false
            
            moods.append(moodSequence[i])
            addChild(arc)
        }
        
        rotate(duration: 4.0)
    }
}
