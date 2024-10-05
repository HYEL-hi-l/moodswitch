//
//  MSLayoutInfo.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import UIKit

struct MSLayoutInfo {
    var screenSize: CGSize = .zero

    var obstacleSpacing: CGFloat = 475
    var maxObstacleWidth: CGFloat = 300
    var obstacleThickness: CGFloat = 30
    var firstObstacleYPosition: CGFloat = 0
    var firstObstacleYOffset: CGFloat = 0
    
    var rotationDuration: CGFloat = 4.0
    
    var ballStartPosition: CGPoint = .zero
    var ballYOffset: CGFloat = 200
    var ballRadius: CGFloat = 40
    
    var moodSwitcherRadius: CGFloat = 40
    
    var ledgeYPosition: CGFloat = 0
    
    var powerUpIndicatorWidth: CGFloat = 30.0
    var powerUpIndicatorHeight: CGFloat = 200.0
    var powerUpIndicatorCornerRadius: CGFloat = 15.0
}
