//
//  ProgressBar.swift
//  Petri
//
//  Created by Karolczyk, Maciej on 02/11/2020.
//

import Foundation
import SpriteKit

enum ProgressBarType {
    case energy
    case age
    case radiation
}

class ProgressBar:SKNode {
    var background:SKSpriteNode?
    var bar:SKSpriteNode?
    var progressBarType:ProgressBarType?
    var _progress:CGFloat = 0
    var progress:CGFloat {
        get {
            return _progress
        }
        set {
            let value = max(min(newValue,1.0),0.0)
            if let bar = bar {
                bar.xScale = value
                _progress = value
                bar.color = getBarColor(barType: progressBarType, progress: value)
            }
        }
    }
    
    convenience init(color:SKColor, size:CGSize, type:ProgressBarType) {
        self.init()
        progressBarType = type
        background = SKSpriteNode(color:SKColor.white,size:size)
        bar = SKSpriteNode(color:color,size:size)
        
        if let bar = bar, let background = background {
            bar.xScale = 0.0
            bar.zPosition = 1.0
            bar.position = CGPoint(x:-size.width/2,y:0)
            bar.anchorPoint = CGPoint(x:0.0,y:0.5)
            addChild(background)
            addChild(bar)
        }
    }
    
    func getBarColor(barType:ProgressBarType?, progress: CGFloat) -> UIColor {
        if let barType = barType {
            switch barType {
            case .energy:
                return progress < Constants.energyBarCriticalLevel ? Constants.energyBarCriticalColor : progress < Constants.energyBarLowLevel ? Constants.energyBarLowColor : progress < Constants.energyBarMediumLevel ? Constants.energyBarMediumColor : Constants.energyBarHighColor
            case .age:
                return progress < Constants.ageBarInfantLevel ? Constants.ageBarInfantColor : progress < Constants.ageBarYoungLevel ? Constants.ageBarYoungColor : progress < Constants.ageBarAdultLevel ? Constants.ageBarAdultColor : Constants.ageBarOldColor
            case .radiation:
                return progress < Constants.radiationBarlowLevel ? Constants.radiationBarLowColor : progress < Constants.radiationBarMediumLevel ? Constants.radiationBarMediumColor : progress < Constants.radiationBarHighLevel ? Constants.radiationBarHighColor : Constants.radiationBarCriticalColor
            }
        } else {
            return .black
        }
        
    }
}
