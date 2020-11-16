//
//  GameViewController.swift
//  Petri
//
//  Created by Karolczyk, Maciej on 27/10/2020.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    
    @IBOutlet weak var gameView: SKView!
    @IBOutlet weak var hudView: SKView!
    
    @IBOutlet weak var SlideButton: SlideViewButton!
    @IBOutlet weak var hudConstraintZero: NSLayoutConstraint!
    @IBOutlet weak var hudConstraintMax: NSLayoutConstraint!
    
    var detailsScene:DetailsScene?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        cellDetailsView.delegate = self
        if let gameSceneView = gameView {
            let scene = GameScene(size: view.bounds.size)
            scene.gameSceneDelegate = self
            gameSceneView.showsFPS = true
            gameSceneView.showsNodeCount = true
            gameSceneView.ignoresSiblingOrder = true
            scene.scaleMode = .resizeFill
            gameSceneView.presentScene(scene)
        }
        
        detailsScene = DetailsScene(fileNamed:"DetailsScene")
        if let scene = detailsScene, let skView = hudView {
            skView.allowsTransparency = true
            scene.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.01)
            skView.presentScene(scene)
        }
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController : GameSceneDelegate {
    func didSelectCell(_ cell: Cell) {
        guard let detailsScene = detailsScene else {return}
        detailsScene.setupWithCellData(cell)
    }
    
    func didSendCellUpdate(_ cell: Cell) {
        if !cell.isDead {
            guard let detailsScene = detailsScene else {return}
            detailsScene.updateCellStatistics(cell)
        }
    }
}
