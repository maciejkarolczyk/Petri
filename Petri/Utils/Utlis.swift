//
//  Utlis.swift
//  Petri
//
//  Created by Karolczyk, Maciej on 29/10/2020.
//

import Foundation
import SpriteKit

enum ZPositions: Int {
    case background
    case cell
    case reproducingCell
    case food
}

class Utils {
    
    static func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }

    static func distanceBetweenPoints(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
}

extension CGPoint {
    func distance(_ point: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(point.x - self.x), Float(point.y - self.y)))
    }
}

extension SKScene {
    func closestCellFromPoint(point: CGPoint, maxDistance: CGFloat) -> Cell? {
        return self
            .children
            .filter { $0 is Cell }
            .filter { $0.position.distance(point) <= maxDistance }
            .min(by: { (node1, node2) -> Bool in
                node1.position.distance(point) < node2.position.distance(point)
            }) as? Cell
    }
}
