//
//  GameLogic.swift
//  Petri
//
//  Created by Karolczyk, Maciej on 03/11/2020.
//

import Foundation
import SpriteKit

class GameLogic {
    static let shared = GameLogic()
    var allSprites:[SKNode] = [];
    
    var allCells:[Cell] {
        return allSprites.compactMap { $0 as? Cell }
    }
    
    private init() {}
    
    func fillCellArray() {
        for i in 1..<15 {
            let cell = Cell.initDefaultCell(id: i, type: .redCell)
            cell.isUserInteractionEnabled = true
            GameLogic.shared.allSprites.append(cell)
        }
        for i in 1..<15 {
            let cell = Cell.initDefaultCell(id: i, type: .cyanCell)
            cell.isUserInteractionEnabled = true
            GameLogic.shared.allSprites.append(cell)
        }
        for i in 1..<15 {
            let cell = Cell.initDefaultCell(id: i, type: .blueCell)
            cell.isUserInteractionEnabled = true
            GameLogic.shared.allSprites.append(cell)
        }
        for i in 1..<15 {
            let cell = Cell.initDefaultCell(id: i, type: .purpleCell)
            cell.isUserInteractionEnabled = true
            GameLogic.shared.allSprites.append(cell)
        }
        for i in 1..<15 {
            let cell = Cell.initDefaultCell(id: i, type: .greenCell)
            cell.isUserInteractionEnabled = true
            GameLogic.shared.allSprites.append(cell)
        }
    }
    
    func randomInt(_ limit: Int) -> Int {
        return Int.random(in: 1..<limit)
    }

}

