//
//  Cell.swift
//  Petri
//
//  Created by Karolczyk, Maciej on 27/10/2020.
//

import Foundation
import SpriteKit

class Cell: SKSpriteNode {
    var id: Int
    var alias: String
    var type: CellType
    var birthDate: Date
    var age:CGFloat = 0
    var maxAge: CGFloat
    var minSpeed: CGFloat
    var maxSpeed: CGFloat
    var currentSpeed: CGFloat
    var intelligence: CGFloat
    var isMoving: Bool
    var swiftness: CGFloat
    var energy: CGFloat {
        willSet {
            if newValue <= 0 {
                die()
            } else if newValue > 0 && newValue <= energyMax * Constants.energyBarCriticalLevel && !isEating {
                self.pulseColor(.lightGray)
            } else {
                stopPulsing()
            }
        }
    }
    var energyMax: CGFloat
    var eatingSpeed: CGFloat
    var replicationAgeFactor:CGFloat
    var replicationEnergyFactor:CGFloat
    var isEating:Bool = false
    var isDead: Bool = false {
        willSet {
            if newValue == true {
                stopPulsing()
                ageTimer.invalidate()
                energyTimer.invalidate()
            }
        }
    }
    
    var mutationHistory:Mutation?
    var energyTimer:Timer = Timer()
    var ageTimer:Timer = Timer()
    var dyingTimer:Timer = Timer()
    
    init(id: Int, alias: String = Names.namesArray.randomElement() ?? "", type: CellType, ageTimestamp: Date = Date(), maxAge: CGFloat = Constants.defaultMaxAge, size: CGSize, minSpeed: CGFloat, maxSpeed:CGFloat, currentSpeed:CGFloat = 0, intelligence: CGFloat = 0, isMoving:Bool = false, swiftness:CGFloat = 0, satiation:CGFloat = Constants.defaultSatiation, satiationMax: CGFloat = Constants.defaultMaxSatiation, eatingSpeed: CGFloat = 20, replicationAge:CGFloat = Constants.defaultReplicationAgeFactor, replicationEnergyFactor:CGFloat = Constants.defaultReplicationEnergyFactor) {
        let texture = SKTexture(imageNamed: type.rawValue)
        self.id = id
        self.alias = alias
        self.type = type
        self.birthDate = ageTimestamp
        self.maxAge = maxAge
        self.minSpeed = minSpeed
        self.maxSpeed = maxSpeed
        self.currentSpeed = currentSpeed
        self.intelligence = intelligence
        self.isMoving = isMoving
        self.swiftness = swiftness
        self.energy = satiation
        self.energyMax = satiationMax
        self.eatingSpeed = eatingSpeed
        self.replicationAgeFactor = replicationAge
        self.replicationEnergyFactor = replicationEnergyFactor
        super.init(texture: texture, color: .clear, size: size)
        startEnergyDrain()
        startAging()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = Cell(id: id, alias: Names.namesArray.randomElement() ?? "", type: type, ageTimestamp: Date(), maxAge: maxAge, size: size, minSpeed: minSpeed, maxSpeed: maxSpeed, currentSpeed: currentSpeed, intelligence: intelligence, isMoving: isMoving, swiftness: swiftness, satiation: energy, satiationMax: energyMax, eatingSpeed: eatingSpeed)
            return copy
        }
    
    func startEnergyDrain() {
        self.energyTimer = Timer.scheduledTimer(timeInterval: Constants.energyDecreaseInterval, target: self, selector: #selector(self.decreaseSatiationOverTime), userInfo: nil, repeats: true)
    }
    
    func startAging() {
        self.ageTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.addAge), userInfo: nil, repeats: true)
    }
    
    func beingEating() {
        isEating = true
        energyTimer.invalidate()
        self.energyTimer = Timer.scheduledTimer(timeInterval: Constants.eatingInterval, target: self, selector: #selector(self.increaseSatiationFromEating), userInfo: nil, repeats: true)
    }
    
    func endEating() {
        isEating = false
        energyTimer.invalidate()
        startEnergyDrain()
    }
    
    func willMove() -> Bool {
        let moveChance = CGFloat(GameLogic.shared.randomInt(100))
        return moveChance < swiftness
    }
    
    func willReplicate() -> Bool {
        let diffComponents = Calendar.current.dateComponents([.second], from: birthDate, to: Date())
        if let seconds = diffComponents.second {
            let floatSeconds = CGFloat(seconds)
            return floatSeconds >= replicationAgeFactor * maxAge && hasEnergyForReplication() && Bool.random()
        } else {
            return false
        }
    }
    
    func hasAnySatiation() -> Bool {
        return energy > 0
    }
    
    func hasCriticalSatiation() -> Bool {
        return energy > 0 && energy <= energyMax * Constants.energyBarCriticalLevel
    }
    
    func hasNormalSatiation() -> Bool {
        return energy > 0 && energy < energyMax * Constants.energyBarMediumLevel && energy > energyMax * Constants.energyBarCriticalLevel
    }
    
    func hasHighSatiation() -> Bool {
        return energy > energyMax * Constants.energyBarMediumLevel
    }
    
    func hasEnergyForReplication() -> Bool {
        return energy > energyMax * replicationEnergyFactor
    }
    
    func increaseSatiation(_ amount:CGFloat) {
        if (energy + amount > energyMax) {
            energy = energyMax
        } else {
            energy += amount
        }
    }
    
    @objc func increaseSatiationFromEating(){
        if isDead != true {
            stopPulsing()
            increaseSatiation(eatingSpeed)
        }
    }
    
    func decreaseSatiation(_ amount:CGFloat) {
        if amount > energy {
            energy = 0
        } else {
            energy = energy - amount
        }
    }
    
    @objc private func decreaseSatiationOverTime() {
        decreaseSatiation(Constants.energyDecreaseAmount)
    }
    
    func decreaseSatiationFromMoving(cellSpeed:CGFloat) {
        let amountToSpend = cellSpeed / Constants.movingEfficiencyFactor * self.size.width
        decreaseSatiation(amountToSpend)
    }
    
    @objc func addAge() {
        if age < maxAge {
            age += 1
        } else {
            die()
        }
    }
    
    func die() {
        isDead = true
        self.blendMode = .alpha
        run(SKAction.colorize(with: .brown, colorBlendFactor: 1.0, duration: 5))
        self.dyingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Constants.dyingDurationInSeconds), target: self, selector: #selector(self.decompose), userInfo: nil, repeats: false)
    }
    
    @objc func decompose() {
        self.dyingTimer.invalidate()
        self.energyTimer.invalidate()
        removeAllActions()
        let removeAction = SKAction.run({[unowned self] in self.removeFromParent()})
        run(SKAction.sequence([SKAction.scale (to: 0.1, duration: 3),
                               removeAction
            ]))
    }
    
    func applyMutation(_ mutation: Mutation) {
        if let mutationHistory = mutationHistory {
            self.mutationHistory = mutationHistory.combineMutations(mutation)
        } else {
            self.mutationHistory = mutation
        }
        maxAge += mutation.maxAge
        minSpeed += mutation.minSpeed
        maxSpeed += mutation.maxSpeed
        intelligence += mutation.intelligence
        swiftness += mutation.swiftness
        energyMax += mutation.maxEnergy
        eatingSpeed += mutation.eatingSpeed
    }
    
    func pulseColor(_ color: UIColor) {
        let pulse = SKAction.repeatForever(
            SKAction.sequence([
                                SKAction.colorize(with: color, colorBlendFactor: 0.7, duration: 0.15),
                                SKAction.wait(forDuration: 0.2),
                                SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.15)]))
        self.run(pulse,withKey: "pulsingColor")
    }
    
    func stopPulsing() {
        self.colorBlendFactor = 0.0
        self.removeAction(forKey: "pulsingColor")
    }
    
    static func initDefaultCell(id: Int, type:CellType) -> Cell {
        switch type {
        case .cyanCell:
            return Cell(id: id, type: .cyanCell, size: type.size, minSpeed: 5, maxSpeed: 40, swiftness:60, satiation:500, satiationMax: 1000, eatingSpeed:7)
        case .redCell:
            return Cell(id: id, type: .redCell, size: type.size, minSpeed: 10, maxSpeed: 70, swiftness:90, satiation:300, satiationMax: 700, eatingSpeed:2)
        case .blueCell:
            return Cell(id: id, type: .blueCell, size: type.size, minSpeed: 7, maxSpeed: 50, swiftness:50, satiation:400, satiationMax: 900, eatingSpeed:8)
        case .purpleCell:
            return Cell(id: id, type: .purpleCell, size: type.size, minSpeed: 2, maxSpeed: 30, swiftness:40, satiation:700, satiationMax: 1500, eatingSpeed:23)
        case .greenCell:
            return Cell(id: id, type: .greenCell, size: type.size, minSpeed: 2, maxSpeed: 50, swiftness:30, satiation:1200, satiationMax: 1200, eatingSpeed:10)
        }
    }
}

enum CellType : String {
    case cyanCell, blueCell, redCell, purpleCell, greenCell
    
    var size : CGSize {
        switch self {
        case .cyanCell: return CGSize(width: 15, height: 15)
        case .blueCell: return CGSize(width: 16, height: 16)
        case .redCell: return CGSize(width: 12, height: 12)
        case .purpleCell: return CGSize(width: 18, height: 18)
        case .greenCell: return CGSize(width: 14, height: 14)
        }
    }
}
