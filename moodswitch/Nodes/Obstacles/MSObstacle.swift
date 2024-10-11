//
//  MSObstacle.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import SpriteKit

class MSObstacle: SKNode {
    
    var moods: [MSMoodType] = []
    var layoutInfo: MSLayoutInfo
    
    var initialRotationDuration: TimeInterval = 0
    var currentRotationDuration: TimeInterval = 0
    let rotationActionKey = "rotation"
    
    required init(layoutInfo: MSLayoutInfo) {
        self.layoutInfo = layoutInfo
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setup(at position: CGPoint) {
        self.position = position
        createShape()
    }
    
    /// overridden by subclasses
    func createShape() {  }
    func updateRotationSpeed(to speedMultiplier: CGFloat) {  }
    
    func rotate(duration: TimeInterval) {
        removeAction(forKey: rotationActionKey)
        
        initialRotationDuration = duration
        currentRotationDuration = duration
        
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: duration)
        let repeatForever = SKAction.repeatForever(rotateAction)
        run(repeatForever, withKey: rotationActionKey)
    }
    
}
