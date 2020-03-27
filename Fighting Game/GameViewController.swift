//
//  GameViewController.swift
//  Fighting Game
//
//  Created by Dylan Martin on 6/29/19.
//  Copyright © 2019 Dylan Martin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = view as? SKView {
			// Load the SKScene from 'GameScene.sks'
			if let scene = SKScene(fileNamed: "Arena.sks") {
				// Set the scale mode to scale to fit the window
				scene.scaleMode = .aspectFill
				
				// Present the scene
				view.presentScene(scene)
				
			}
			
			view.ignoresSiblingOrder = true
			
			view.showsFPS = true
			view.showsNodeCount = true
            // Create the scene programmatically
//            let scene = GameScene(size: view.bounds.size)
//            scene.scaleMode = .resizeFill
//            view.ignoresSiblingOrder = true
//            view.showsFPS = true
//            view.showsNodeCount = true
//            view.presentScene(scene)
			
        }
		
		
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
