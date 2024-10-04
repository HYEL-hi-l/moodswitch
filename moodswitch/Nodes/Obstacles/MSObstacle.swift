//
//  MSObstacle.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//


import SpriteKit

class MSObstacle: SKNode {
    
    var moods: [MSMoodType] = []
    
    required override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setup(at position: CGPoint) {
        self.position = position
        createShape()
    }

    func createShape() {
        // Override in subclasses
    }

    func rotate(duration: TimeInterval) {
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: duration)
        run(SKAction.repeatForever(rotateAction))
    }
}
