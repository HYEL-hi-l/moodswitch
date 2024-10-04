//
//  MSObstacleManager.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//


import SpriteKit

class MSObstacleManager {
    var obstacles: [MSObstacle] = []
    var moodSwitches: [MSMoodSwitcher] = []
    var lastObstacleYPosition: CGFloat = 0
    let obstacleSpacing: CGFloat = 475
    

    func reset() {
        obstacles.forEach { $0.removeFromParent() }
        obstacles.removeAll()
        moodSwitches.forEach { $0.removeFromParent() }
        moodSwitches.removeAll()
        
        lastObstacleYPosition = 0
    }

    func updateObstacles(in scene: SKScene, ballPositionY: CGFloat) {
        if ballPositionY > lastObstacleYPosition - obstacleSpacing * 2 {
            generateObstacle(in: scene)
        }

        obstacles = obstacles.filter { obstacle in
            if obstacle.position.y + 200 < ballPositionY - scene.frame.height {
                obstacle.removeFromParent()
                return false
            } else {
                return true
            }
        }
    }
    
    private func generateObstacle(in scene: SKScene) {

        let obstacleType: MSObstacle.Type
        let obstacle: MSObstacle
        
        if obstacles.count < 1 {
            obstacleType = MSObstacleCircle.self
        } else {
            let obstacleTypes: [MSObstacle.Type] = [MSObstacleCircle.self, MSObstacleSquare.self, MSObstacleTriangle.self]
            obstacleType = obstacleTypes.randomElement() ?? MSObstacleCircle.self
        }
        
        obstacle = obstacleType.init()
        
        let newYPosition = lastObstacleYPosition + obstacleSpacing
        obstacle.setup(at: CGPoint(x: scene.frame.midX, y: newYPosition))
        scene.addChild(obstacle)
        obstacles.append(obstacle)
        
        if obstacles.count > 1 {
            let moodSwitch = MSMoodSwitcher(size: CGSize(width: 40.0, height: 40.0), moods: obstacle.moods)
            moodSwitch.position = CGPoint(x: scene.frame.midX, y: lastObstacleYPosition + (obstacleSpacing / 2))
            scene.addChild(moodSwitch)
            moodSwitches.append(moodSwitch)
        }

        lastObstacleYPosition = newYPosition
    }

}
