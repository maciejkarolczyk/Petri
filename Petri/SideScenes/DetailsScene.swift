//
//  DetailsScene.swift
//  Petri
//
//  Created by Karolczyk, Maciej on 02/11/2020.
//

import UIKit
import SpriteKit

class DetailsScene: SKScene {
    
    var energyBar: ProgressBar?
    var energyValue: SKLabelNode?
    var energyLabel: SKLabelNode?
    var energyMax: SKLabelNode?
    var energyDivider: SKLabelNode?
    var energyChange: SKLabelNode?
    
    var cellImage: SKSpriteNode?
    var cellAlias: SKLabelNode?
    
    var ageLabel: SKLabelNode?
    var ageBar: ProgressBar?
    var ageDivider: SKLabelNode?
    var ageValue: SKLabelNode?
    var ageMax: SKLabelNode?
    var ageChange: SKLabelNode?
    
    var radiationLabel: SKLabelNode?
    var radiationValue: SKLabelNode?
    var radiationBar: ProgressBar?
    var radiationDivider: SKLabelNode?
    var radiationMax: SKLabelNode?
    var radiationChange: SKLabelNode?
    
    var maxSpeedLabel:SKLabelNode?
    var maxSpeedChange: SKLabelNode?
    var minSpeedLabel:SKLabelNode?
    var minSpeedChange: SKLabelNode?
    var sizeLabel: SKLabelNode?
    var sizeChange: SKLabelNode?
    var swiftnessLabel:SKLabelNode?
    var swiftnessChange: SKLabelNode?
    var eatingLabel: SKLabelNode?
    var eatingChange: SKLabelNode?
    
    
    override func didMove(to view: SKView) {
        cellImage = childNode(withName: "cellImage") as? SKSpriteNode
        cellAlias = childNode(withName: "cellAlias") as? SKLabelNode
        
        energyValue = childNode(withName: "energyValue") as? SKLabelNode
        energyLabel = childNode(withName: "energyLabel") as? SKLabelNode
        energyMax = childNode(withName: "energyMax") as? SKLabelNode
        energyDivider = childNode(withName: "energyDivider") as? SKLabelNode
        energyChange = childNode(withName: "energyChange") as? SKLabelNode
        
        ageLabel = childNode(withName: "ageLabel") as? SKLabelNode
        ageDivider = childNode(withName: "ageDivider") as? SKLabelNode
        ageValue = childNode(withName: "ageValue") as? SKLabelNode
        ageMax = childNode(withName: "ageMax") as? SKLabelNode
        ageMax = childNode(withName: "ageMax") as? SKLabelNode
        ageChange = childNode(withName: "ageChange") as? SKLabelNode
        
        radiationLabel = childNode(withName: "radiationLabel") as? SKLabelNode
        radiationValue = childNode(withName: "radiationValue") as? SKLabelNode
        radiationMax = childNode(withName: "radiationMax") as? SKLabelNode
        radiationDivider = childNode(withName: "radiationDivider") as? SKLabelNode
        radiationChange = childNode(withName: "radiationChange") as? SKLabelNode
        
        maxSpeedLabel = childNode(withName: "maxSpeedLabel") as? SKLabelNode
        maxSpeedChange = childNode(withName: "maxSpeedChange") as? SKLabelNode
        minSpeedLabel = childNode(withName: "minSpeedLabel") as? SKLabelNode
        minSpeedChange = childNode(withName: "minSpeedChange") as? SKLabelNode
        sizeLabel = childNode(withName: "sizeLabel") as? SKLabelNode
        sizeChange = childNode(withName: "sizeChange") as? SKLabelNode
        swiftnessLabel = childNode(withName: "swiftnessLabel") as? SKLabelNode
        swiftnessChange = childNode(withName: "swiftnessChange") as? SKLabelNode
        eatingLabel = childNode(withName: "eatingLabel") as? SKLabelNode
        eatingChange = childNode(withName: "eatingChange") as? SKLabelNode
        
        setupProgressBars()
    }
    
    func setupWithCellData(_ cell: Cell) {
        cellImage?.size = CGSize(width: cell.size.width * 2, height: cell.size.width * 2)
        cellImage?.texture = SKTexture(imageNamed: cell.type.rawValue)
        cellAlias?.text = cell.alias
        ageMax?.text = String(format: "%.0f", cell.maxAge)
        energyMax?.text = String(format: "%.0f", cell.energyMax)
        maxSpeedLabel?.text = String(format: "%.0f", cell.maxSpeed)
        minSpeedLabel?.text = String(format: "%.0f", cell.minSpeed)
        sizeLabel?.text = String(format: "%.0f", cell.size.width)
        swiftnessLabel?.text = String(format: "%.0f", cell.swiftness)
        eatingLabel?.text = String(format: "%.0f", cell.eatingSpeed)
        
        toggleHistory(isHidden: false)
        
        if let history = cell.mutationHistory {
            energyChange?.text = history.maxEnergy != 0 ? String(format: "%.0f", history.maxEnergy) : ""
            energyChange?.color = history.maxEnergy > 0 ? .green : .red
            ageChange?.text = history.maxAge != 0 ? String(format: "%.0f", history.maxAge) : ""
            ageChange?.color =  history.maxAge > 0 ? .green : .red
            maxSpeedChange?.text = history.maxSpeed != 0 ? String(format: "%.0f", history.maxSpeed) : ""
            maxSpeedChange?.color =  history.maxSpeed > 0 ? .green : .red
            minSpeedChange?.text = history.minSpeed != 0 ? String(format: "%.0f", history.minSpeed) : ""
            minSpeedChange?.color =  history.minSpeed > 0 ? .green : .red
//            sizeChange?.text = String(format: "%.0f", history.)
            swiftnessChange?.text = history.swiftness != 0 ? String(format: "%.0f", history.swiftness) : ""
            swiftnessChange?.color =  history.swiftness > 0 ? .green : .red
            eatingChange?.text = history.eatingSpeed != 0 ? String(format: "%.0f", history.eatingSpeed) : ""
            eatingChange?.color =  history.eatingSpeed > 0 ? .green : .red
        } else {
            toggleHistory(isHidden: true)
        }
        
        
        updateCellStatistics(cell)
    }
    
    private func toggleHistory(isHidden:Bool) {
        energyChange?.isHidden = isHidden
        ageChange?.isHidden = isHidden
        maxSpeedChange?.isHidden = isHidden
        ageChange?.isHidden = isHidden
        minSpeedChange?.isHidden = isHidden
        swiftnessChange?.isHidden = isHidden
        eatingChange?.isHidden = isHidden
    }
    
    func updateCellStatistics(_ cell: Cell) {
        setEnergyBarProgress(progress: cell.energy / cell.energyMax)
        energyValue?.text = String(format: "%.0f", cell.energy)
       
        let diffComponents = Calendar.current.dateComponents([.second], from: cell.birthDate, to: Date())
        if let seconds = diffComponents.second {
            let floatSeconds = CGFloat(seconds)
            ageValue?.text = String(format: "%.0f", floatSeconds)
            setAgeBarProgress(progress: (floatSeconds / cell.maxAge))
        }
        
        
    }
    
    func setupProgressBars() {
        guard let energyLabel = energyLabel else {return}
        let barSize = CGSize(width:size.width - 30 - energyLabel.frame.width, height:energyLabel.frame.height/2)
        
        energyBar = ProgressBar(color:.white, size: barSize, type: .energy)
        guard let energyBar = energyBar else {return}
        energyBar.position = CGPoint(x: energyDivider?.position.x ?? 0, y: energyLabel.position.y)
        addChild(energyBar)
        
        ageBar = ProgressBar(color:.white, size: barSize, type: .age)
        guard let ageBar = ageBar, let xAgeBarPosition = ageDivider?.position.x else {return}
        ageBar.position = CGPoint(x: xAgeBarPosition, y: ageLabel?.position.y ?? 0)
        addChild(ageBar)
        
        radiationBar = ProgressBar(color:.white, size: barSize, type: .radiation)
        guard let radiationBar = radiationBar, let xRadiationBarPosition = radiationDivider?.position.x else {return}
        radiationBar.position = CGPoint(x: xRadiationBarPosition, y: radiationLabel?.position.y ?? 0)
        addChild(radiationBar)
    }
    
    func setEnergyBarProgress(progress:CGFloat) {
        guard let energyBar = energyBar else {return}
        energyBar.progress = progress
    }
    
    func setAgeBarProgress(progress:CGFloat) {
        guard let ageBar = ageBar else {return}
        ageBar.progress = progress
    }
    
    
    

}
