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
    case invincible = "Invincible"
}

protocol MSPowerUpIndicatorDelegate: AnyObject {
    func powerUpActivated()
    func powerUpDeactivated()
}

class MSPowerUpIndicator: SKNode {
        
    private struct Constants {
        static let backgroundAlpha: CGFloat = 0.35
        static let animationDuration: TimeInterval = 0.5
        static let cornerRadius: CGFloat = 10.0
        static let circleLineWidth: CGFloat = 8.0
        static let powerUpCircleLineWidth: CGFloat = 12.0
//        static let moodSegmentIncrement: CGFloat = 90.0
        static let moodSegmentIncrement: CGFloat = 30.0
        static let powerUpDecrement: CGFloat = 72.0
        static let moodSwitcherSize: CGFloat = 50.0
        static let glowExpandFactor: CGFloat = 3.0
        static let glowDuration: TimeInterval = 0.5
    }
        
    weak var delegate: MSPowerUpIndicatorDelegate?
    
    private let layoutInfo: MSLayoutInfo
    private let mainWidth: CGFloat
    private var moodProgressSegments: [MSMoodType: CGFloat] = [:]
    
    private var isPowerUpActive = false
    private var powerUpProgress: CGFloat = 360.0 {
        didSet {
            updateGlowNodeScale()
            updatePowerUpCircle()
        }
    }
    
    private let backgroundNode: SKShapeNode = SKShapeNode()
    private let strokeNode: SKShapeNode = SKShapeNode()
    private let powerUpCircle: SKShapeNode = SKShapeNode()
    
    private var moodSegments: [MSMoodType: SKShapeNode] = [:]
    private let moodColors: [MSMoodType: UIColor] = {
        return [
            .angry: MSMoodType.angry.color,
            .happy: MSMoodType.happy.color,
            .sad: MSMoodType.sad.color,
            .inlove: MSMoodType.inlove.color
        ]
    }()
    
    private var moodSwitcherTexture: SKSpriteNode?
    private var glowNode: SKEffectNode?
    private var originalBackgroundSize: CGSize?
    
    
    init(layoutInfo: MSLayoutInfo) {
        self.layoutInfo = layoutInfo
        self.mainWidth = layoutInfo.powerUpIndicatorWidth * 0.95
        super.init()
        setupBackgroundNode()
        setupStrokeNode()
        setupMoodSegments()
        setupPowerUpCircle()
        setupMoodSwitcher()
        setUpLines()
        setupGlowNode()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: Setup
extension MSPowerUpIndicator {
    
    private func setupBackgroundNode() {
        let radius = mainWidth / 2
        let segmentAngle = 90.0
        let moods: [MSMoodType] = [.angry, .happy, .sad, .inlove]
        
        for (index, mood) in moods.enumerated() {
            let startAngle = CGFloat(index) * CGFloat(segmentAngle) * CGFloat.pi / 180
            let endAngle = startAngle + CGFloat(segmentAngle) * CGFloat.pi / 180
            
            let path = createSectorPath(radius: radius, startAngle: startAngle, endAngle: endAngle)
            
            let segment = SKShapeNode(path: path)
            segment.fillColor = moodColors[mood] ?? .white.withAlphaComponent(0.5)
            segment.strokeColor = .clear
            segment.zPosition = 3
            segment.alpha = Constants.backgroundAlpha
            
            backgroundNode.addChild(segment)
        }
        
        addChild(backgroundNode)
    }
    
    private func setupGlowNode() {
        let glowBaseNode = SKShapeNode()
        let radius = mainWidth / 4
        let segmentAngle = 90.0
        let moods: [MSMoodType] = [.angry, .happy, .sad, .inlove]
        
        for (index, mood) in moods.enumerated() {
            let startAngle = CGFloat(index) * CGFloat(segmentAngle) * CGFloat.pi / 180
            let endAngle = startAngle + CGFloat(segmentAngle) * CGFloat.pi / 180
            
            let path = createSectorPath(radius: radius, startAngle: startAngle, endAngle: endAngle)
            
            let segment = SKShapeNode(path: path)
            segment.fillColor = moodColors[mood] ?? .white.withAlphaComponent(0.5)
            segment.strokeColor = .clear
            segment.zPosition = 3
            
            glowBaseNode.addChild(segment)
        }
        
        glowNode = SKEffectNode()
        glowNode?.shouldRasterize = true
        glowNode?.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 2.5])
        glowNode?.zPosition = 1
        addChild(glowNode!)
        glowNode?.addChild(glowBaseNode)
    }
    
    private func setupStrokeNode() {
        let radius = layoutInfo.powerUpIndicatorWidth / 2
        strokeNode.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: 2*radius, height: 2*radius), transform: nil)
        strokeNode.fillColor = .black
        strokeNode.strokeColor = .black
        strokeNode.lineWidth = 2.0
        strokeNode.zPosition = 2
        addChild(strokeNode)
    }
    
    private func setupMoodSegments() {
        let radius = mainWidth / 2
        let segmentAngle = 90.0
        let moods: [MSMoodType] = [.angry, .happy, .sad, .inlove]
        
        for (index, mood) in moods.enumerated() {
            let startAngle = CGFloat(index) * CGFloat(segmentAngle) * CGFloat.pi / 180
            let initialProgress = 0.0
            let filledAngle = initialProgress * CGFloat.pi / 180
            let endAngle = startAngle + CGFloat(filledAngle)
            
            let path = createSectorPath(radius: radius, startAngle: startAngle, endAngle: endAngle)
            
            let segment = SKShapeNode(path: path)
            segment.fillColor = moodColors[mood] ?? .white.withAlphaComponent(0.5)
            segment.strokeColor = .clear
            segment.zPosition = 3
            segment.alpha = 1.0
            
            addChild(segment)
            moodSegments[mood] = segment
            moodProgressSegments[mood] = 0.0
        }
    }
    
    private func setupPowerUpCircle() {
        let radius = mainWidth / 2 + Constants.powerUpCircleLineWidth / 2 + 5.0
        let path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: 2*radius, height: 2*radius), transform: nil)
        powerUpCircle.path = path
        powerUpCircle.fillColor = .clear
        powerUpCircle.strokeColor = UIColor(hex: "#6D00F9")
//        powerUpCircle.lineWidth = Constants.powerUpCircleLineWidth
        powerUpCircle.zPosition = 5
        powerUpCircle.alpha = 0.0
//        addChild(powerUpCircle)

    }
    
    private func setUpLines() {
        let strokeSize = 1.0
        let lineLength = mainWidth
        
        let hline = SKSpriteNode(color: .black, size: .init(width: lineLength, height: strokeSize))
        let vline = SKSpriteNode(color: .black, size: .init(width: strokeSize, height: lineLength))
        hline.position = .init(x: 0, y: 0)
        vline.position = .init(x: 0, y: 0)
        hline.zPosition = 3
        vline.zPosition = 3

    
        addChild(hline)
        addChild(vline)
    }
    
    private func setupMoodSwitcher() {
        let texture = SKTexture(imageNamed: "ms_mood_switcher2")
        moodSwitcherTexture = SKSpriteNode(texture: texture)
        moodSwitcherTexture?.position = CGPoint.zero
        moodSwitcherTexture?.zPosition = 4
        addChild(moodSwitcherTexture!)
    }
    
    private func createSectorPath(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addArc(center: CGPoint.zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
    
}


//
extension MSPowerUpIndicator {
    
    func increaseProgress(for mood: MSMoodType) {
        guard !isPowerUpActive else { return }
        guard let currentProgress = moodProgressSegments[mood] else { return }
        let newProgress = min(currentProgress + Constants.moodSegmentIncrement, 90.0)
                
        animateProgress(for: mood, to: newProgress, duration: 0.1)  {
            if newProgress == 90.0 && self.checkIfAllSegmentsFull() {
                self.activatePowerUp()
            }
        }
    }
    
    private func animateProgress(for mood: MSMoodType, to newProgress: CGFloat, duration: TimeInterval, completion: @escaping () -> ()) {
        guard let currentProgress = moodProgressSegments[mood] else { return }
        let progressDifference = newProgress - currentProgress
        guard progressDifference > 0 else { return }

        let steps = 30
        let stepDuration = duration / Double(steps)
        let progressIncrement = progressDifference / CGFloat(steps)

        var actions: [SKAction] = []

        for _ in 0..<steps {
            let incrementAction = SKAction.run { [weak self] in
                guard let self = self else { return }
                if let current = self.moodProgressSegments[mood] {
                    let updatedProgress = min(current + progressIncrement, newProgress)
                    self.moodProgressSegments[mood] = updatedProgress
                    self.updateMoodSegment(mood: mood, progress: updatedProgress)
                }
            }
            let waitAction = SKAction.wait(forDuration: stepDuration)
            actions.append(incrementAction)
            actions.append(waitAction)
        }

        let sequence = SKAction.sequence(actions)
        let actionKey = "animateProgress_\(mood)"
        run(sequence) {
            completion()
        }
    }
    
    private func updateMoodSegment(mood: MSMoodType, progress: CGFloat) {
        guard let segment = moodSegments[mood] else { return }
        let segmentAngle = 90.0
        let filledAngle = progress * CGFloat.pi / 180
        let moods: [MSMoodType] = [.angry, .happy, .sad, .inlove]
        
        let index = moods.firstIndex(of: mood)
        let startAngle = CGFloat(index ?? 0) * CGFloat(segmentAngle) * CGFloat.pi / 180
        let endAngle = startAngle + CGFloat(filledAngle)
        
        let newPath = createPartialSectorPath(radius: mainWidth / 2, startAngle: startAngle, endAngle: endAngle)
        segment.path = newPath
    }
    
    private func createPartialSectorPath(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addArc(center: CGPoint.zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
    
    private func checkIfAllSegmentsFull() -> Bool {
        for (_, progress) in moodProgressSegments {
            if progress < 90.0 {
                return false
            }
        }
        return true
    }
    
    func decreasePowerUpProgress() {
        guard isPowerUpActive else { return }
        powerUpProgress -= Constants.powerUpDecrement
        if powerUpProgress <= 0.0 {
            powerUpProgress = 0.0
            deactivatePowerUp()
        }
    }
    
    private func updatePowerUpCircle() {
        let radius = mainWidth / 2 + Constants.powerUpCircleLineWidth / 2 + 5.0
        let startAngle = -CGFloat.pi / 2 
        let endAngle = startAngle + (powerUpProgress * CGFloat.pi / 180)
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint.zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        powerUpCircle.path = path
    }
    
    private func updateGlowNodeScale() {
        let maxProgress: CGFloat = 360.0
        let minScale: CGFloat = 1.0
        let maxScale: CGFloat = Constants.glowExpandFactor
        
        let progressRatio = powerUpProgress / maxProgress
        let newScale = minScale + (maxScale - minScale) * progressRatio
        
        let fadeKey = "glowFade"
        
        let fadeAction = SKAction.fadeAlpha(to: progressRatio, duration: 0.1)
        glowNode?.run(fadeAction, withKey: fadeKey)
    }
    

    private func activatePowerUp() {
        guard !isPowerUpActive else { return }
        isPowerUpActive = true
        
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: Constants.animationDuration)
        for segment in moodSegments.values {
            segment.run(fadeOut)
        }
        
        powerUpCircle.alpha = 1.0
        let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 5.0))
        powerUpCircle.run(rotateAction, withKey: "rotation")
        
        expandAndGlow()
        
        delegate?.powerUpActivated()
    }
    
    private func deactivatePowerUp() {
        guard isPowerUpActive else { return }
        isPowerUpActive = false
        
        powerUpCircle.removeAction(forKey: "rotation")
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: Constants.animationDuration)
        powerUpCircle.run(fadeOut)
        
        powerUpProgress = 360.0
        
        for (mood, _) in moodProgressSegments {
            moodProgressSegments[mood] = 0.0
            updateMoodSegment(mood: mood, progress: 0.0)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: Constants.animationDuration)
            moodSegments[mood]?.run(fadeIn)
        }
        
        contractAndRemoveGlow()
        
        delegate?.powerUpDeactivated()
    }
    
    private func expandAndGlow() {
        guard let glowNode = glowNode else { return }
        
        originalBackgroundSize = backgroundNode.frame.size
        let expandedSize = CGSize(width: originalBackgroundSize!.width * Constants.glowExpandFactor,
                                  height: originalBackgroundSize!.height * Constants.glowExpandFactor)
        
        let expandAction = SKAction.scale(to: Constants.glowExpandFactor, duration: Constants.glowDuration)
        let fadeInAction = SKAction.fadeAlpha(to: 1.0, duration: Constants.glowDuration)
        
        glowNode.run(SKAction.group([expandAction, fadeInAction]))
        
        // Add a subtle pulsing effect
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: Constants.glowExpandFactor * 1.05, duration: 0.5),
            SKAction.scale(to: Constants.glowExpandFactor, duration: 0.5)
        ])
        glowNode.run(SKAction.repeatForever(pulseAction))
    }

    private func contractAndRemoveGlow() {
        guard let glowNode = glowNode, let originalSize = originalBackgroundSize else { return }
        
        let contractAction = SKAction.scale(to: 1.0, duration: Constants.glowDuration)
        let fadeOutAction = SKAction.fadeAlpha(to: 0.0, duration: Constants.glowDuration)
        
        glowNode.removeAllActions() // Remove the pulsing effect
        
        glowNode.run(SKAction.group([contractAction, fadeOutAction])) { [weak self] in
            self?.glowNode?.setScale(1.0)
            self?.glowNode?.alpha = 0.0
        }
    }
    
    func resetMeter() {
        if isPowerUpActive {
            deactivatePowerUp()
        } else {
            for (mood, _) in moodProgressSegments {
                moodProgressSegments[mood] = 0.0
                updateMoodSegment(mood: mood, progress: 0.0)
            }
        }
    }
    
}
