//
//  MSBackground.swift
//  moodswitch
//
//  Created by Sam Richard on 10/3/24.


import SpriteKit

class MSBackground: SKNode {
    
//    private var currentBackground: SKSpriteNode
//    private var nextBackground: SKSpriteNode
    private var mainBackground: SKSpriteNode!
    private var moodBackground: SKSpriteNode!
    private var screenSize: CGSize = .zero

    override init() {
        
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setup(screenSize: CGSize) {
        self.screenSize = screenSize
        setupMainBackground()
        updateBackgroundSize(node: mainBackground)
    }
    
}


// MARK: Helpers
extension MSBackground {
    
    private func setupMainBackground() {
        let topColor = UIColor(hex: "#111111")
        let bottomColor = UIColor(hex: "#111111")

        let gradientTexture = gradientTexture(from: bottomColor, to: topColor, size: screenSize)

        mainBackground = SKSpriteNode(texture: gradientTexture)
        mainBackground.size = screenSize
        mainBackground.position = CGPoint(x: 0, y: 0)
        mainBackground.zPosition = -2
        mainBackground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(mainBackground)
    }
    
    private func updateBackgroundSize(node: SKSpriteNode) {
        let bgRatio = screenSize.width / node.texture!.size().width
        let bgHeight = node.texture!.size().height * bgRatio
        node.size = CGSize(width: screenSize.width, height: bgHeight)
    }
    
    private func gradientTexture(from color1: UIColor, to color2: UIColor, size: CGSize) -> SKTexture {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return SKTexture()
        }

        return SKTexture(image: image)
    }
    
    func flashTexture(with moodType: MSMoodType, for duration: TimeInterval) {
        
        if moodBackground != nil {
            moodBackground.removeFromParent()
        }
        
        let newTexture = SKTexture(imageNamed: moodType.bgTextureName)
        
        moodBackground = SKSpriteNode(texture: newTexture)
        updateBackgroundSize(node: moodBackground)
        moodBackground.position = mainBackground.position
        moodBackground.alpha = 0.0
        addChild(moodBackground)
        let fadeIn = SKAction.fadeIn(withDuration: duration * 2/3)
        let fadeOut = SKAction.fadeOut(withDuration: duration * 1/3)
        let sequence = SKAction.sequence([fadeIn, fadeOut])
        moodBackground.run(sequence) {
            self.moodBackground.removeFromParent()
        }
    }
    
}




// MARK: Alternate "neon" background
//class MSBackground: SKNode {
//    
//    private var screenSize: CGSize = .zero
//    private var facialAssets: [SKSpriteNode] = []
//    private var gradientNode: SKSpriteNode!
//    
//    private let assetNames = ["angry_3d", "happy_3d", "sad_r", "inlove_vector"]
//    
//    private let horizontalSpacing: CGFloat = 30.0
//    private let verticalSpacing: CGFloat = 30.0
//
//    
//    override init() {
//        super.init()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func setup(screenSize: CGSize) {
//        self.screenSize = screenSize
//        
//        setupGradientBackground()
////        setupAssets()
//    }
//    
//    private func setupGradientBackground() {
//        let topColor = UIColor(hex: "#111111")
//        let bottomColor = UIColor(hex: "#111111")
//        
//        let gradientTexture = gradientTexture(from: bottomColor, to: topColor, size: screenSize)
//        
//        gradientNode = SKSpriteNode(texture: gradientTexture)
//        gradientNode.size = screenSize
//        gradientNode.position = CGPoint(x: 0, y: 0)
//        gradientNode.zPosition = -2
//        gradientNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        addChild(gradientNode)
//    }
//    
//    private func gradientTexture(from color1: UIColor, to color2: UIColor, size: CGSize) -> SKTexture {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [color1.cgColor, color2.cgColor]
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
//        gradientLayer.frame = CGRect(origin: .zero, size: size)
//        
//        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//        defer { UIGraphicsEndImageContext() }
//        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
//        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
//            return SKTexture()
//        }
//        
//        return SKTexture(image: image)
//    }
//    
//    private func setupAssets() {
//        let totalWidth = screenSize.width * 1.6
//        let totalHeight = screenSize.height * 2.5
//        let testTexture = SKTexture(imageNamed: "happy_vector")
//        let assetSize = testTexture.size()
//        
//        let columns = Int(ceil(totalWidth / (assetSize.width + horizontalSpacing))) + 4
//        let rows = Int(ceil(totalHeight / (assetSize.height + verticalSpacing))) + 4
//        
//        let fullRowWidth = CGFloat(columns) * (assetSize.width + horizontalSpacing)
//        let fullGridWidth = fullRowWidth + (assetSize.width / 2 + horizontalSpacing / 2)
//        let gridHeight = CGFloat(rows) * (assetSize.height + verticalSpacing)
//
//        let startX = -fullGridWidth / 2 + assetSize.width / 2
//        let startY = -gridHeight / 2 + assetSize.height / 2
//
//        
//        for row in 0..<rows {
//            for column in 0..<columns {
//                
//                let isOffset = row % 2 == 1
//                let xOffset: CGFloat = isOffset ? (assetSize.width / 2 + horizontalSpacing / 2) : 0.0
//
//                let assetName = assetNames.randomElement()!
//                let texture = SKTexture(imageNamed: assetName)
//                let sprite = SKSpriteNode(texture: texture)
//                
//                sprite.setScale(0.7)
//                
//                let xPosition = startX + CGFloat(column) * (assetSize.width + horizontalSpacing) + xOffset
//                let yPosition = startY + CGFloat(row) * (assetSize.height + verticalSpacing)
//                sprite.position = CGPoint(x: xPosition, y: yPosition)
//                
//                let rotationAngle = CGFloat.random(in: -CGFloat.pi/12...CGFloat.pi/12)
//                sprite.zRotation = rotationAngle
//                
//                sprite.color = .white
//                sprite.colorBlendFactor = 1.0
//                sprite.alpha = 0.5
//                
//                addChild(sprite)
//                facialAssets.append(sprite)
//            }
//        }
//    }
//    
//    func changeAssetColor(to mood: MSMoodType) {
//        return
//        for asset in facialAssets {
//            asset.run(SKAction.colorize(with: mood.color, colorBlendFactor: 1.0, duration: 0.3))
//        }
//        return
//
//        let topColor: UIColor
//        let bottomColor: UIColor
//        switch mood {
//        case .happy:
//            topColor = UIColor(hex: "#1A1201")
//            bottomColor = UIColor(hex: "#3F3217")
//        case .sad:
//            topColor = UIColor(hex: "#011522")
//            bottomColor = UIColor(hex: "#1B3545")
//        case .angry:
//            topColor = UIColor(hex: "#250201")
//            bottomColor = UIColor(hex: "#4E201F")
//        case .inlove:
//            topColor = UIColor(hex: "#210110")
//            bottomColor = UIColor(hex: "#461B2F")
//        }
//        
//        let newGradientTexture = gradientTexture(from: topColor, to: bottomColor, size: screenSize)
//        
//        let newGradientNode = SKSpriteNode(texture: newGradientTexture)
//        newGradientNode.position = gradientNode.position
//        newGradientNode.zPosition = gradientNode.zPosition - 1
//        newGradientNode.alpha = 0.0
//        addChild(newGradientNode)
//        
//        let fadeOutAction = SKAction.fadeOut(withDuration: 0.1)
//        let fadeInAction = SKAction.fadeIn(withDuration: 0.1)
//        
//        gradientNode.run(fadeOutAction)
//        newGradientNode.run(fadeInAction) {
//            self.gradientNode.removeFromParent()
//            self.gradientNode = newGradientNode
//        }
//    }
//}
