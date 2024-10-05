//
//  MSPowerUpIndicator.swift
//  moodswitch
//
//  Created by Sam Richard on 10/4/24.
//

import SpriteKit
import Foundation

enum MSPowerUpType: String, CaseIterable {
    case surge = "Surge"
    case slow = "Slow"
}

protocol MSPowerUpIndicatorDelegate: AnyObject {
    func powerUpActivated()
    func powerUpDeactivated()
}

class MSPowerUpIndicator: SKNode {
    
    // MARK: - Constants
    
    private struct Constants {
        static let backgroundAlpha: CGFloat = 0.2
        static let animationDuration: TimeInterval = 0.5
        static let cornerRadius: CGFloat = 10.0
        static let squareSize: CGFloat = 35.0
        static let squareCornerRadius: CGFloat = 8.0
    }
    
    // MARK: - Properties
    
    weak var delegate: MSPowerUpIndicatorDelegate?
    
    private var roundedSquare: SKShapeNode?
    private var moodSwitcherTexture: SKSpriteNode?
    
    private let layoutInfo: MSLayoutInfo
    private var moodProgressBars: [MSMoodType: ProgressBar] = [:]
    
    private var isPowerUpActive = false
    private var bigBar: SKShapeNode?
    private var bigBarProgress: CGFloat = 1.0 {
        didSet {
            updateBigBar()
        }
    }
    
    private let backgroundNode: SKShapeNode = SKShapeNode()
    private let strokeNode: SKShapeNode = SKShapeNode()

    // MARK: - Initializer
    
    init(layoutInfo: MSLayoutInfo) {
        self.layoutInfo = layoutInfo
        super.init()
        setupBackgroundNode()
        setupStrokeNode()
        setupProgressBars()
        setupBigBar()
        setupRoundedSquare()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ProgressBar Class
    
    private class ProgressBar {
        let mood: MSMoodType
        let node: SKNode
        let fillNode: SKShapeNode
        let size: CGSize

        private var _progress: CGFloat
        var progress: CGFloat {
            get {
                return _progress
            }
            set {
                _progress = min(max(newValue, 0.03), 1.0)
                updateProgress()
            }
        }

        init(mood: MSMoodType, position: CGPoint, size: CGSize, cornerRadius: CGFloat) {
            // Initialize stored properties first
            self.mood = mood
            self.size = size
            self.node = SKNode()
            self.node.position = position
            self._progress = 0.03

            // Now, create the fillNode without using 'self' methods
            let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height * 0.03)
            let path = ProgressBar.createTopRoundedRectPath(rect: rect, cornerRadius: cornerRadius)
            self.fillNode = SKShapeNode(path: path)
            self.fillNode.fillColor = mood.color
            self.fillNode.strokeColor = .clear
            self.fillNode.alpha = 1.0
            self.fillNode.zPosition = 1
            self.fillNode.position = CGPoint(x: 0, y: 0)
            self.node.addChild(self.fillNode)

            // Now that all properties are initialized, we can use 'self'
            self.progress = 0.03
        }

        private func updateProgress() {
//            fillNode.yScale = progress
            let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height * progress)
            let path = ProgressBar.createTopRoundedRectPath(rect: rect, cornerRadius: 8.0)
            fillNode.path = path
            // No need to adjust position since anchor point is at center
        }

        // Make this method static so it doesn't require 'self'
        private static func createTopRoundedRectPath(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
            let path = CGMutablePath()
            let radius = min(cornerRadius, rect.width / 2, rect.height / 2)
            
            let topLeft = CGPoint(x: rect.minX, y: rect.maxY)
            let topRight = CGPoint(x: rect.maxX, y: rect.maxY)
            let bottomRight = CGPoint(x: rect.maxX, y: rect.minY)
            let bottomLeft = CGPoint(x: rect.minX, y: rect.minY)
            
            path.move(to: bottomLeft)
            path.addLine(to: bottomRight)
            path.addLine(to: CGPoint(x: topRight.x, y: topRight.y - radius))
            path.addQuadCurve(to: CGPoint(x: topRight.x - radius, y: topRight.y), control: topRight)
            path.addLine(to: CGPoint(x: topLeft.x + radius, y: topLeft.y))
            path.addQuadCurve(to: CGPoint(x: topLeft.x, y: topLeft.y - radius), control: topLeft)
            path.addLine(to: bottomLeft)
            path.closeSubpath()
            
            return path
        }
    }


    
    // MARK: - Setup Methods
    
    private func setupBackgroundNode() {
        let size = CGSize(width: layoutInfo.powerUpIndicatorWidth, height: layoutInfo.powerUpIndicatorHeight)
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        let path = createTopRoundedRectPath(rect: rect, cornerRadius: Constants.cornerRadius)
        backgroundNode.path = path
        backgroundNode.fillColor = .darkGray
        backgroundNode.strokeColor = .clear
//        backgroundNode.alpha = Constants.backgroundAlpha
        backgroundNode.zPosition = 1
        addChild(backgroundNode)
    }
    
    private func setupStrokeNode() {
        let size = CGSize(width: layoutInfo.powerUpIndicatorWidth + 2.0, height: layoutInfo.powerUpIndicatorHeight + 2.0)
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        let path = createTopRoundedRectPath(rect: rect, cornerRadius: Constants.cornerRadius)
        strokeNode.path = path
        strokeNode.fillColor = .white
        strokeNode.strokeColor = .black
        strokeNode.lineWidth = 0.5
//        strokeNode.alpha = Constants.backgroundAlpha
        strokeNode.zPosition = 0
        addChild(strokeNode)
    }
    
    private func setupProgressBars() {
        let barWidth = layoutInfo.powerUpIndicatorWidth / 4
        let barHeight = layoutInfo.powerUpIndicatorHeight
        let startX = -layoutInfo.powerUpIndicatorWidth / 2 + barWidth / 2
        let moods = MSMoodManager.shared.getActiveMoodSequence()
        for (index, mood) in moods.enumerated() {
            let xPosition = startX + CGFloat(index) * barWidth
            let position = CGPoint(x: xPosition, y: 0)
            let size = CGSize(width: barWidth, height: barHeight)
            let progressBar = ProgressBar(mood: mood, position: position, size: CGSize(width: size.width, height: size.height - 5.0), cornerRadius: Constants.cornerRadius)
            moodProgressBars[mood] = progressBar
            addChild(progressBar.node)
        }
    }
    
    private func setupBigBar() {
        let size = CGSize(width: layoutInfo.powerUpIndicatorWidth, height: layoutInfo.powerUpIndicatorHeight)
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        let path = createTopRoundedRectPath(rect: rect, cornerRadius: Constants.cornerRadius)
        bigBar = SKShapeNode(path: path)
        bigBar?.fillColor = .green
        bigBar?.strokeColor = .clear
        bigBar?.alpha = 0.0
        bigBar?.position = CGPoint(x: 0, y: 0)
        bigBar?.zPosition = 2
        bigBar?.yScale = 1.0
        addChild(bigBar!)
    }
    
    private func setupRoundedSquare() {
        let squareSize = Constants.squareSize
        let cornerRadius = Constants.squareCornerRadius
        
        let rect = CGRect(x: -squareSize/2, y: -squareSize/2, width: squareSize, height: squareSize)
        let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        
        roundedSquare = SKShapeNode(path: path)
        roundedSquare?.fillColor = .clear
        roundedSquare?.strokeColor = .clear
        roundedSquare?.lineWidth = 2
        roundedSquare?.position = CGPoint(x: 0, y: -layoutInfo.powerUpIndicatorHeight / 2 - squareSize / 3)
        roundedSquare?.zPosition = 3
        addChild(roundedSquare!)
        
        let texture = SKTexture(imageNamed: "ms_mood_switcher")
        moodSwitcherTexture = SKSpriteNode(texture: texture, size: CGSize(width: squareSize, height: squareSize))
        moodSwitcherTexture?.position = CGPoint.zero
        roundedSquare?.addChild(moodSwitcherTexture!)
        
    }
    
    private func createTopRoundedRectPath(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let radius = min(cornerRadius, rect.width / 2, rect.height / 2)
        
        let topLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let topRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.minY)
        
        path.move(to: bottomLeft)
        path.addLine(to: bottomRight)
        path.addLine(to: CGPoint(x: topRight.x, y: topRight.y - radius))
        path.addQuadCurve(to: CGPoint(x: topRight.x - radius, y: topRight.y), control: topRight)
        path.addLine(to: CGPoint(x: topLeft.x + radius, y: topLeft.y))
        path.addQuadCurve(to: CGPoint(x: topLeft.x, y: topLeft.y - radius), control: topLeft)
        path.addLine(to: bottomLeft)
        path.closeSubpath()
        
        return path
    }
    
    // MARK: - Progress Management
    
    func increaseProgress(for mood: MSMoodType) {
        guard !isPowerUpActive else { return }
        if let progressBar = moodProgressBars[mood] {
            let newProgress = min(progressBar.progress + (1.0), 1.0)
            progressBar.progress = newProgress
            if checkIfAllBarsFull() {
                activatePowerUp()
            }
        }
    }
    
    private func checkIfAllBarsFull() -> Bool {
        for progressBar in moodProgressBars.values {
            if progressBar.progress < 1.0 {
                return false
            }
        }
        return true
    }
    
    func decreaseBigBarProgress() {
        guard isPowerUpActive else { return }
        bigBarProgress -= 0.2
        if bigBarProgress <= 0.0 {
            deactivatePowerUp()
        }
    }
    
    private func updateBigBar() {
        bigBarProgress = min(max(bigBarProgress, 0.0), 1.0)
        bigBar?.yScale = bigBarProgress
        // No need to adjust position since anchor point is at center
    }
    
    // MARK: - Power-Up Management
    
    private func activatePowerUp() {
        guard !isPowerUpActive else { return }
        isPowerUpActive = true
        
        // Fade out mood progress bars
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        for progressBar in moodProgressBars.values {
            progressBar.node.run(fadeOut)
        }
        
        // Fade in bigBar
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        bigBar?.run(fadeIn)
        
        // Start glowing effect
        let glowAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        bigBar?.run(SKAction.repeatForever(glowAction))
        
        // Notify delegate
        delegate?.powerUpActivated()
    }
    
    private func deactivatePowerUp() {
        isPowerUpActive = false
        bigBar?.removeAllActions()
        
        // Fade out bigBar
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        bigBar?.run(fadeOut)
        
        // Reset mood progress bars and fade in
        for progressBar in moodProgressBars.values {
            progressBar.progress = 0.0
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
            progressBar.node.run(fadeIn)
        }
        
        // Notify delegate
        delegate?.powerUpDeactivated()
    }
    
    /// Resets the meter and deactivates any active power-up.
    func resetMeter() {
        if isPowerUpActive {
            deactivatePowerUp()
        } else {
            for progressBar in moodProgressBars.values {
                progressBar.progress = 0.0
            }
        }
    }
}
