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

    var rotationSpeedMultiplier: CGFloat = 1.0

    func reset() {
        obstacles.forEach { $0.removeFromParent() }
        obstacles.removeAll()
        moodSwitches.forEach { $0.removeFromParent() }
        moodSwitches.removeAll()
        
        lastObstacleYPosition = 0
        rotationSpeedMultiplier = 1.0
    }

    func updateObstacles(in scene: MSGameScene, ballPositionY: CGFloat, currentScore: Int) {
        if ballPositionY > lastObstacleYPosition - scene.layoutInfo.obstacleSpacing * 2 {
            generateObstacle(in: scene, score: currentScore)
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
    
    private func generateObstacle(in scene: MSGameScene, score: Int) {
        let obstacleType: MSObstacle.Type
        let obstacle: MSObstacle
        let yPosition: CGFloat

        let obstacleTypes = getAvailableObstacleTypes(for: score)
        
        if obstacles.count < 1 {
            obstacleType = MSObstacleCircle.self
            yPosition = scene.layoutInfo.firstObstacleYPosition
        } else {
            obstacleType = obstacleTypes.randomElement() ?? MSObstacleCircle.self
            yPosition = lastObstacleYPosition + scene.layoutInfo.obstacleSpacing
        }
        
        obstacle = obstacleType.init(layoutInfo: scene.layoutInfo)
        obstacle.setup(at: CGPoint(x: scene.frame.midX, y: yPosition))
        
        obstacle.updateRotationSpeed(to: rotationSpeedMultiplier)
        
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
    
    private func getAvailableObstacleTypes(for score: Int) -> [MSObstacle.Type] {
        var availableTypes: [MSObstacle.Type] = [MSObstacleCircle.self]

        if score >= 0 {
            availableTypes = [MSObstacleCircle.self]
        } else if score >= 7 {
            availableTypes = [MSObstacleCircle.self, MSObstacleSquare.self]
        } else if score >= 15 {
            availableTypes = [MSObstacleCircle.self, MSObstacleSquare.self, MSObstacleTriangle.self]
        } else if score >= 25 {
            availableTypes = [MSObstacleSquare.self, MSObstacleTriangle.self, MSObstacleDotCircle.self, MSObstacleDotTriangle.self, MSObstacleDotSquare.self]
        } else if score >= 35 {
            availableTypes = [MSObstacleTriangle.self, MSObstacleDotCircle.self, MSObstacleDotTriangle.self, MSObstacleDotSquare.self, MSObstacleDoubleCircle.self, MSObstacleExpandingDotCircle.self]
        }
        
        return availableTypes
    }
    
    // MARK: Rotation Speed Control Methods
    
    func speedUpRotation(by speedUpFactor: CGFloat) {
        rotationSpeedMultiplier *= speedUpFactor
        for obstacle in obstacles {
            obstacle.updateRotationSpeed(to: rotationSpeedMultiplier)
        }
    }

    func slowDownRotation(by slowDownFactor: CGFloat) {
        rotationSpeedMultiplier *= slowDownFactor
        for obstacle in obstacles {
            obstacle.updateRotationSpeed(to: rotationSpeedMultiplier)
        }
    }

    func resetRotationSpeed() {
        rotationSpeedMultiplier = 1.0
        for obstacle in obstacles {
            obstacle.updateRotationSpeed(to: rotationSpeedMultiplier)
        }
    }
}
