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
    var lastObstacleType: MSObstacle.Type = MSObstacleCircle.self
    var lastObstacleMoods: [MSMoodType] = MSMoodManager.shared.getActiveMoodSequence()
    var lastObstacleYPosition: CGFloat = 0

    func reset() {
        obstacles.forEach { $0.removeFromParent() }
        obstacles.removeAll()
        moodSwitches.forEach { $0.removeFromParent() }
        moodSwitches.removeAll()
        
        lastObstacleYPosition = 0
    }

    func updateObstacles(in scene: MSGameScene, ballPositionY: CGFloat) {
        if ballPositionY > lastObstacleYPosition - scene.layoutInfo.obstacleSpacing * 2 {
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
    
    private func generateObstacle(in scene: MSGameScene) {
        let obstacleTypes: [MSObstacle.Type]
        let obstacleType: MSObstacle.Type
        let obstacle: MSObstacle
        let yPosition: CGFloat

        if lastObstacleType == MSObstacleTriangle.self {
            obstacleTypes = [MSObstacleCircle.self, MSObstacleSquare.self]
        } else {
            obstacleTypes = [MSObstacleCircle.self, MSObstacleSquare.self, MSObstacleTriangle.self]
        }

        if obstacles.count < 1 {
            obstacleType = MSObstacleCircle.self
            yPosition = scene.layoutInfo.firstObstacleYPosition
        } else {
            obstacleType = obstacleTypes.randomElement() ?? MSObstacleCircle.self
            yPosition = lastObstacleYPosition + scene.layoutInfo.obstacleSpacing
        }
        
        obstacle = obstacleType.init(layoutInfo: scene.layoutInfo)
        obstacle.setup(at: CGPoint(x: scene.frame.midX, y: yPosition))
        scene.addChild(obstacle)
        obstacles.append(obstacle)
        
        if obstacles.count > 1 {
            let moodSwitcher = MSMoodSwitcher(radius: scene.layoutInfo.moodSwitcherRadius, moods: obstacle.moods, lastObstacleMoods: lastObstacleMoods)
            moodSwitcher.position = CGPoint(x: scene.frame.midX, y: lastObstacleYPosition)
            scene.addChild(moodSwitcher)
            moodSwitches.append(moodSwitcher)
        }
        
        lastObstacleYPosition = yPosition
        lastObstacleType = obstacleType
        lastObstacleMoods = obstacle.moods
    }

}
