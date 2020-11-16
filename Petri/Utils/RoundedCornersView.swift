//
//  RoundedCornersView.swift
//  Petri
//
//  Created by Karolczyk, Maciej on 02/11/2020.
//

import Foundation


import UIKit
import SpriteKit

@IBDesignable
class RoundedCornersView: SKView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
}
