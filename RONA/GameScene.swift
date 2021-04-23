//
//  GameScene.swift
//  RONA
//
//  Created by Kirk LaMaire on 4/23/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var background: SKEmitterNode!
    var TCV_20: SKSpriteNode!
    
    let lifeLabel = SKLabelNode(fontNamed: "Courier-Bold")
    var lives: Int = 5 {
        didSet {
            lifeLabel.text = "Lives: \(lives)"
        }
    }
    
    let turnRecognizer = UIRotationGestureRecognizer()
    var rotationValue: CGFloat = 0.0
    var rotationOffset: CGFloat = 0.0
    
    let moveRecognizer = UITapGestureRecognizer()
    
    var virusTimer: Timer!
    
    enum Collision: UInt32 {
        case ship = 1
        case viral = 2
    }
    
    
    override func didMove(to view: SKView) {
        background = SKEmitterNode(fileNamed: "Background")
        background.position = CGPoint(x: 0, y: (1334/2))
        background.advanceSimulationTime(25)
        self.addChild(background)
        background.zPosition = -1 // Makes sure that teh background is behind all foreground objects
        
        self.physicsWorld.contactDelegate = self
        
        if let ship:SKSpriteNode = self.childNode(withName: "TCV_20") as? SKSpriteNode {
            TCV_20 = ship
        }
        
        lifeLabel.fontSize = 50
        lifeLabel.position = CGPoint(x: -((self.frame.size.width / 2 - 20)), y: (self.frame.size.height / 2) - 200)
        lifeLabel.text = "Lives: 5"
        lifeLabel.zPosition = 10
        lifeLabel.horizontalAlignmentMode = .left
        addChild(lifeLabel)
        lives = 5
        
        turnRecognizer.addTarget(self, action: #selector(GameScene.rotateView(_:) ))
        self.view!.addGestureRecognizer(turnRecognizer)
        
        moveRecognizer.addTarget(self, action: #selector(GameScene.moveTap))
        moveRecognizer.numberOfTapsRequired = 1
        moveRecognizer.numberOfTouchesRequired = 1
        self.view!.addGestureRecognizer(moveRecognizer)
        
        virusTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(addVirus), userInfo: nil, repeats: true)
        
        
        TCV_20.physicsBody = SKPhysicsBody(texture: TCV_20.texture!, size: (TCV_20.texture!.size()))
        TCV_20.physicsBody?.categoryBitMask = Collision.ship.rawValue
        TCV_20.physicsBody?.contactTestBitMask = Collision.viral.rawValue
        TCV_20.physicsBody?.affectedByGravity = false
        TCV_20.physicsBody?.isDynamic = true

    }
    
    @objc func rotateView(_ sender: UIRotationGestureRecognizer) {
        if (sender.state == .changed) {
            // Negative 1 ensures ship rotates the same direction the touch is moving
            rotationValue = (CGFloat(sender.rotation) + self.rotationOffset) * -1
            TCV_20.zRotation = rotationValue
        }
        if (sender.state == .ended) {
            // Negative 1 ensures ship does not flip when trying to turn an nth time
            self.rotationOffset = rotationValue * -1
        }
        
    }
    
    @objc func moveTap() {
        let xVec: CGFloat = sin(rotationValue) * -10
        let yVec: CGFloat = cos(rotationValue) * 10
        let theVector: CGVector = CGVector(dx: xVec, dy: yVec)
        
        TCV_20.physicsBody?.applyImpulse(theVector)
    }
    
    @objc func addVirus() {
        let virus = SKSpriteNode(imageNamed: "virus_red")
        virus.xScale = 0.1
        virus.yScale = 0.1
        
        let randomX = GKRandomDistribution(lowestValue: -350, highestValue: 350)
        let randomY = GKRandomDistribution(lowestValue: -650, highestValue: 800)
        let virusX = CGFloat(randomX.nextInt())
        let virusY = CGFloat(randomY.nextInt())
        virus.position = CGPoint(x: virusX, y: virusY)
        virus.physicsBody = SKPhysicsBody(rectangleOf: virus.size)
        virus.physicsBody?.isDynamic = true
        
        self.addChild(virus)
        
        let anDurr:TimeInterval = 6
        var actionArr = [SKAction]()
        actionArr.append(SKAction.move(to: CGPoint(x: CGFloat(randomX.nextInt()), y: CGFloat(randomY.nextInt())), duration: anDurr))
        actionArr.append(SKAction.removeFromParent())
        
        virus.run(SKAction.sequence(actionArr))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        // ensures first node is virus
        let nodeSort = [nodeA, nodeB].sorted {$0.name ?? "" < $1.name ?? ""}
        let firstNode = nodeSort[0]
        //let secondNode = nodeSort[1]
        
        lives -= 1
        firstNode.removeFromParent()

    }
    
    override func update(_ currentTime: TimeInterval) {
        if TCV_20.position.x + TCV_20.size.height > 550 {
            TCV_20.position.x = -450
        }
        else if TCV_20.position.x + TCV_20.size.width < -475 {
            TCV_20.position.x = 400
        }
        
        if TCV_20.position.y + TCV_20.size.height > 800 {
            TCV_20.position.y = -625
        }
        else if TCV_20.position.y + TCV_20.size.height < -650 {
            TCV_20.position.y = 600
        }
    }
}
