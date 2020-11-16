//
//  GameScene.swift
//  Petri
//
//  Created by Karolczyk, Maciej on 27/10/2020.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none         : UInt32 = 0
    static let all          : UInt32 = UInt32.max
    static let cell         : UInt32 = 0b1
    static let food         : UInt32 = 0b10
}

protocol GameSceneDelegate: AnyObject {
    func didSelectCell(_ cell:Cell)
    func didSendCellUpdate(_ cell:Cell)
}

class GameScene: SKScene {

    var previousCameraScale = CGFloat()
    let cameraNode = SKCameraNode()
    var prevCalcTime:TimeInterval = 0
    
    var selectedCell:Cell?
    
    weak var gameSceneDelegate: GameSceneDelegate?
    
    override func didMove(to view: SKView) {
        addChild(cameraNode)
        camera = cameraNode
        camera?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        camera?.setScale(1.0)
        
        let pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.addTarget(self, action: #selector(pinchGestureAction(_:)))
        view.addGestureRecognizer(pinchGesture)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        setBackgroundGradient()
        run(SKAction.run(setupFood))
        run(SKAction.run(setupBubbles))
        GameLogic.shared.fillCellArray()
        run(SKAction.run(addBasicCells))
    }
    
    func setupBubbles() {
        let emitter = SKEmitterNode(fileNamed: "bubbles.sks")!
        emitter.position = CGPoint(x: size.width/2, y: 0)
        emitter.advanceSimulationTime(5.0)
        emitter.zPosition = CGFloat(ZPositions.cell.rawValue)
        addChild(emitter)
    }
    
    func setupFood() {
        let invisibleSprite = SKSpriteNode(imageNamed: "orange")
        invisibleSprite.position = CGPoint(x: size.width/2, y: size.height/2)
        invisibleSprite.zPosition =  CGFloat(ZPositions.cell.rawValue)
        invisibleSprite.size = CGSize(width: 200, height: 200)
        invisibleSprite.alpha = 0.0
        invisibleSprite.physicsBody = SKPhysicsBody(rectangleOf: invisibleSprite.size)
        invisibleSprite.physicsBody?.isDynamic = false
        invisibleSprite.physicsBody?.categoryBitMask = PhysicsCategory.food
        invisibleSprite.isUserInteractionEnabled = false
        invisibleSprite.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(invisibleSprite)
        
        let emitter = SKEmitterNode(fileNamed: "food.sks")!
        emitter.position = invisibleSprite.position
        emitter.advanceSimulationTime(5.0)
        emitter.zPosition = CGFloat(ZPositions.food.rawValue)
        emitter.isUserInteractionEnabled = false
        addChild(emitter)
    }
    
    func setBackgroundGradient() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: size.width, height: size.height)
        addChild(background)
    }
    
    
    func addBasicCells() {
        for cell in GameLogic.shared.allCells {
            cell.position = getRandomPositionForSprite(sprite: cell)
            cell.zPosition = CGFloat(ZPositions.cell.rawValue)
            cell.physicsBody = SKPhysicsBody(circleOfRadius: cell.size.width/2)
            cell.physicsBody?.restitution = 0.7
            cell.physicsBody?.isDynamic = true
            cell.physicsBody?.categoryBitMask = PhysicsCategory.cell
            cell.physicsBody?.contactTestBitMask = PhysicsCategory.food | PhysicsCategory.cell
            cell.physicsBody?.collisionBitMask = PhysicsCategory.cell
            cellLifecycleRecursive(cell)
            addChild(cell)
        }
        
    }
    
    func cellLifecycleRecursive(_ cell:Cell){
        cell.stopPulsing()
        let repeatAction = SKAction.run({[unowned self] in self.cellLifecycleRecursive(cell)})
        var sequence:SKAction
        if cell.willReplicate() {
                replicate(cell)
        } else if cell.hasAnySatiation() {
            if cell.willMove() {
                let cellSpeed = random(min: CGFloat(cell.minSpeed) , max: CGFloat(cell.maxSpeed))
                cell.currentSpeed = cellSpeed
                let destination = self.getRandomPositionForSprite(sprite: cell)
                let moveDifference = CGPoint(x: destination.x - cell.position.x, y: destination.y - cell.position.y)
                let distanceToMove = sqrt(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y)
                let moveDuration = distanceToMove / cellSpeed
                let moveAction = SKAction.move(to: destination, duration: TimeInterval(moveDuration))
                if cell.energy < 0 {
                    print("what the hell men?")
                }
                cell.decreaseSatiationFromMoving(cellSpeed: cellSpeed)
                sequence = SKAction.sequence([moveAction,repeatAction])
            } else {
                let waitAction = SKAction.wait(forDuration: TimeInterval(Constants.defaultCellWaitTime))
                sequence = SKAction.sequence([waitAction,repeatAction])
            }
            cell.run(sequence, withKey: "recursiveLoop")
        } else {
            let waitAction = SKAction.wait(forDuration: TimeInterval(Constants.defaultCellWaitTime))
            sequence = SKAction.sequence([waitAction,repeatAction])
            cell.run(sequence, withKey: "recursiveLoop")
        }
    }
    
    func replicate(_ cell:Cell) {
        let cellReproduceAtlas = SKTextureAtlas(named: "\(cell.type)Reproduce")
        var frames: [SKTexture] = []
        
        let numImages = cellReproduceAtlas.textureNames.count
        for i in 1...numImages {
            let textureName = "\(cell.type.rawValue)\(i)"
            frames.append(cellReproduceAtlas.textureNamed(textureName))
        }
        
        let firstFrameTexture = frames[0]
        let reproducingSprite = SKSpriteNode(texture: firstFrameTexture)
        reproducingSprite.position = cell.position
        reproducingSprite.zPosition = CGFloat(ZPositions.reproducingCell.rawValue)
        reproducingSprite.size = CGSize(width: cell.size.width * 2, height: cell.size.height)
        addChild(reproducingSprite)
        
        let animateAction = SKAction.animate(with: frames,
                                             timePerFrame: Constants.replicationTimePerFrame,
                                         resize: false,
                                         restore: true)
        let spawnAction = SKAction.run { () -> Void in
            let newRightCell = cell.copy() as! Cell
            let mutation = Mutation.makeRandomMutation(radiation: 40)
            newRightCell.applyMutation(mutation)
            newRightCell.energy = cell.energy / 2
            newRightCell.position = CGPoint(x: cell.position.x + cell.size.width / 2, y: cell.position.y)
            newRightCell.zPosition = CGFloat(ZPositions.cell.rawValue)
            newRightCell.isUserInteractionEnabled = true
            newRightCell.physicsBody = SKPhysicsBody(circleOfRadius: newRightCell.size.width/2)
            newRightCell.physicsBody?.restitution = 0.7
            newRightCell.physicsBody?.isDynamic = true
            newRightCell.physicsBody?.categoryBitMask = PhysicsCategory.cell
            newRightCell.physicsBody?.contactTestBitMask = PhysicsCategory.food | PhysicsCategory.cell
            newRightCell.physicsBody?.collisionBitMask = PhysicsCategory.cell
            GameLogic.shared.allSprites.append(newRightCell)
            self.addChildAndAnimate(newRightCell)
            }
        let removeAction = SKAction.removeFromParent()
        
        cell.energy = cell.energy / 2
        reproducingSprite.run(SKAction.sequence([animateAction,spawnAction,removeAction]))
        
        //move original cell aside to the left
        let leftDestination = CGPoint(x: cell.position.x - cell.size.width / 2, y: cell.position.y)
        
        let moveLeftAction = SKAction.move(to: leftDestination, duration: TimeInterval(Constants.replicationTimePerFrame * Double(numImages)))
        let repeatAction = SKAction.run({[unowned self] in self.cellLifecycleRecursive(cell)})
        cell.run(SKAction.sequence([moveLeftAction,repeatAction]))
        
    }
    
    func getRandomPositionForSprite(sprite:SKSpriteNode) -> CGPoint {
        let positionX = random(min: sprite.size.width/2, max: size.width - sprite.size.width)
        let positionY = random(min: sprite.size.height/2, max: size.height - sprite.size.height)
        return CGPoint(x: positionX, y: positionY)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random(in: 0.0...1.0) * (max - min) + min
    }
    
    
    // MARK: camera handling
    
    @objc func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        guard let camera = camera else {
            return
        }
        if sender.state == .began {
            previousCameraScale = camera.xScale
        }
        if previousCameraScale <= 1.0 {
            camera.setScale(min(previousCameraScale * 1 / sender.scale, 1.0) )
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            let deltaY = location.y - previousLocation.y
            let deltaX = location.x - previousLocation.x
            camera!.position.y -= deltaY
            camera!.position.x -= deltaX
        }
    }
    
    func cellIsInFoodArea(cell: Cell, foodSprite: SKSpriteNode) {
        cell.beingEating()
    }
    
    func didCellLeftFoodArea(cell: Cell, foodSprite: SKSpriteNode) {
        cell.endEating()
    }
    
    func energySteal(_ cellOne:Cell, _ cellTwo:Cell) {
        if !cellOne.isDead && !cellTwo.isDead {
            let cellOneStealAmount = cellOne.size.width * cellOne.currentSpeed
            let cellTwoStealAmount = cellTwo.size.width * cellTwo.currentSpeed
            let difference = cellOneStealAmount - cellTwoStealAmount
            if difference > 0 {
                cellOne.increaseSatiation(abs(difference))
                cellTwo.decreaseSatiation(abs(difference))
            } else {
                cellOne.decreaseSatiation(abs(difference))
                cellTwo.increaseSatiation(abs(difference))
            }
        }
    }
    
    func contactCellWithCell(_ cellOne:Cell, _ cellTwo:Cell) {
        energySteal(cellOne, cellTwo)
    }
    
    func addChildAndAnimate(_ child: Cell) {
        addChild(child)
        cellLifecycleRecursive(child)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in:self)
            let closestCell = closestCellFromPoint(point: location, maxDistance: 20)
            if let delegate = gameSceneDelegate, let cell = closestCell {
                selectedCell = cell
                delegate.didSelectCell(cell)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if currentTime - prevCalcTime > Constants.gameSceneNotificationTick, let selectedCell = selectedCell {
            prevCalcTime = currentTime
            if let delegate = gameSceneDelegate {
                delegate.didSendCellUpdate(selectedCell)
            }
        }
    }
    

}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // 1
        var bodyOne: SKPhysicsBody
        var bodyTwo: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyOne = contact.bodyA
            bodyTwo = contact.bodyB
        } else {
            bodyOne = contact.bodyB
            bodyTwo = contact.bodyA
        }
        
        // 2
        if ((bodyOne.categoryBitMask & PhysicsCategory.cell != 0) &&
                (bodyTwo.categoryBitMask & PhysicsCategory.food != 0)) {
            if let cell = bodyOne.node as? Cell, let food = bodyTwo.node as? SKSpriteNode {
                cellIsInFoodArea(cell: cell, foodSprite: food)
            }
        } else if (bodyOne.categoryBitMask == bodyTwo.categoryBitMask) {
            if let cellOne = bodyOne.node as? Cell, let cellTwo = bodyTwo.node as? Cell, cellOne.energy > 0, cellTwo.energy > 0 {
                contactCellWithCell(cellOne, cellTwo)
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        var cellBody: SKPhysicsBody
        var foodBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
          cellBody = contact.bodyA
          foodBody = contact.bodyB
        } else {
          cellBody = contact.bodyB
          foodBody = contact.bodyA
        }
        
        if (cellBody.categoryBitMask & PhysicsCategory.cell != 0) &&
            (foodBody.categoryBitMask & PhysicsCategory.food != 0) {
          if let cell = cellBody.node as? Cell, let food = foodBody.node as? SKSpriteNode {
            didCellLeftFoodArea(cell: cell, foodSprite: food)
          }
        }
    }
}
