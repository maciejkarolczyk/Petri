//
//  Mutation.swift
//  Petri
//
//  Created by Karolczyk, Maciej on 10/11/2020.
//

import Foundation
import SpriteKit

enum MutationType {
    case mild
    case moderate
    case severe
}

enum MutatingStat {
    case maxEnergy
    case maxAge
    case minSpeed
    case maxSpeed
    case intelligence
    case swiftness
    case eatingSpeed
}

class Mutation {
    
    var maxEnergy: CGFloat
    var maxAge: CGFloat
    var minSpeed: CGFloat
    var maxSpeed: CGFloat
    var intelligence: CGFloat
    var swiftness: CGFloat
    var eatingSpeed: CGFloat
    
    internal init(maxEnergy: CGFloat, maxAge: CGFloat, minSpeed: CGFloat, maxSpeed: CGFloat, intelligence: CGFloat, swiftness: CGFloat, eatingSpeed: CGFloat) {
        self.maxEnergy = maxEnergy
        self.maxAge = maxAge
        self.minSpeed = minSpeed
        self.maxSpeed = maxSpeed
        self.intelligence = intelligence
        self.swiftness = swiftness
        self.eatingSpeed = eatingSpeed
    }
    
    static private func getChangeValue(stat:MutatingStat, type: MutationType) ->CGFloat {
        switch type {
        case .mild:
            switch stat {
            case .maxEnergy :
                return 10
            case .maxAge :
                return 10
            case .minSpeed :
                return 1
            case .maxSpeed :
                return 1
            case .intelligence :
                return 0
            case .swiftness :
                return 1
            case .eatingSpeed :
                return 1
            }
        case .moderate:
            switch stat {
            case .maxEnergy :
                return 25
            case .maxAge :
                return 20
            case .minSpeed :
                return 2
            case .maxSpeed :
                return 2
            case .intelligence :
                return 0
            case .swiftness :
                return 2
            case .eatingSpeed :
                return 2
            }
        case .severe:
            switch stat {
            case .maxEnergy :
                return 50
            case .maxAge :
                return 30
            case .minSpeed :
                return 3
            case .maxSpeed :
                return 3
            case .intelligence :
                return 0
            case .swiftness :
                return 4
            case .eatingSpeed :
                return 3
            }
        }
    }
    
    func combineMutations(_ newMutation: Mutation) -> Mutation {
        let netEnergy = maxEnergy + newMutation.maxEnergy
        let netAge = maxAge + newMutation.maxAge
        let netMinSpeed = minSpeed + newMutation.maxAge
        let netMaxSpeed = maxAge + newMutation.maxAge
        let netIntelligence = intelligence + newMutation.intelligence
        let netSwiftness = swiftness + newMutation.swiftness
        let netEatingSpeed = eatingSpeed + newMutation.eatingSpeed
        
        return Mutation(maxEnergy: netEnergy, maxAge: netAge, minSpeed: netMinSpeed, maxSpeed: netMaxSpeed, intelligence: netIntelligence, swiftness: netSwiftness, eatingSpeed: netEatingSpeed)
    }

    
    static private func getStatMutation(radiation:CGFloat, mutationStat:MutatingStat) -> CGFloat {
        let chance = CGFloat(GameLogic.shared.randomInt(150)) + radiation
        let willMutate = chance > 110
        if willMutate {
            let mutationType: MutationType = chance < 150 ? .mild : chance < 200 ? .moderate : .severe
            let changeValue = getChangeValue(stat: mutationStat, type: mutationType)
            return Bool.random() ? changeValue : changeValue * -1
        } else {
            return 0
        }
    }
    
    static func makeRandomMutation(radiation: CGFloat) -> Mutation {
        return Mutation(maxEnergy: getStatMutation(radiation: radiation, mutationStat: .maxEnergy), maxAge: getStatMutation(radiation: radiation, mutationStat: .maxAge), minSpeed: getStatMutation(radiation: radiation, mutationStat: .minSpeed), maxSpeed: getStatMutation(radiation: radiation, mutationStat: .maxSpeed), intelligence: getStatMutation(radiation: radiation, mutationStat: .intelligence), swiftness: getStatMutation(radiation: radiation, mutationStat: .swiftness), eatingSpeed: getStatMutation(radiation: radiation, mutationStat: .eatingSpeed))
    }
    
}
