//
//  Constants.swift
//  Petri
//
//  Created by Karolczyk, Maciej on 05/11/2020.
//

import Foundation
import UIKit

struct Constants {
    
    static let defaultSatiation:CGFloat = 500
    static let defaultMaxSatiation:CGFloat = 1000
    
    //tick in seconds indicating how often cell eats in food area
    static let eatingInterval:Double = 0.3
    
    static let energyDecreaseInterval:Double = 1
    
    static let energyDecreaseAmount:CGFloat = 1
    
    static let dyingDurationInSeconds = 10
    //Formula for energy spent by moving is cellSpeed * self.size.width / movingEfficiencyFactor. Default 10
    static let movingEfficiencyFactor:CGFloat = 10
    // default max age of cell in seconds
    static let defaultMaxAge:CGFloat = 150
    
    // default min age  for cell to be able to replicate
    static let defaultReplicationAgeFactor:CGFloat = 0.01
    
    // default amount of energy needed for cell to reproduce
    static let defaultReplicationEnergyFactor:CGFloat = 0.7
    
    //time in seconds for each replication frame. There are 16 frames in animation
    static let replicationTimePerFrame = 0.15
    
    //Determines the 'bounciness' of the physics body (0.0 - 1.0). Defaults to 0.2
    static let cellPhysicsRestitution = 0.7
    
    //default time cell waits when it decides to not move (in seconds)
    static let defaultCellWaitTime = 4
    
    //each time this time passes - gameScene informs DetailsScene with selected cell information, no need to go below eatingIntervalInSeconds
    static let gameSceneNotificationTick:Double = 0.5
    
    static let energyBarCriticalColor = UIColor.red
    static let energyBarLowColor = UIColor.orange
    static let energyBarMediumColor = UIColor.cyan
    static let energyBarHighColor = UIColor.green
    
    //values under which energy bar will turn color
    static let energyBarCriticalLevel:CGFloat = 0.25
    static let energyBarLowLevel:CGFloat = 0.5
    static let energyBarMediumLevel:CGFloat = 0.8
    
    static let ageBarInfantColor = UIColor.green
    static let ageBarYoungColor = UIColor.cyan
    static let ageBarAdultColor = UIColor.orange
    static let ageBarOldColor = UIColor.red
    
    //values under which age bar will turn color
    static let ageBarInfantLevel:CGFloat = 0.3
    static let ageBarYoungLevel:CGFloat = 0.5
    static let ageBarAdultLevel:CGFloat = 0.8
    
    static let radiationBarCriticalColor = UIColor.red
    static let radiationBarLowColor = UIColor.orange
    static let radiationBarMediumColor = UIColor.cyan
    static let radiationBarHighColor = UIColor.green
    
    //values under which radiation bar will turn color
    static let radiationBarlowLevel:CGFloat = 0.3
    static let radiationBarMediumLevel:CGFloat = 0.5
    static let radiationBarHighLevel:CGFloat = 0.8
}
