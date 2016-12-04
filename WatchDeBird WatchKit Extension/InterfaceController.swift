//
//  InterfaceController.swift
//  WatchDeBird WatchKit Extension
//
//  Created by Katsuya Kato on 2016/12/04.
//  Copyright © 2016年 CrossBridge. All rights reserved.
//

import WatchKit
import Foundation
import SpriteKit

class InterfaceController: WKInterfaceController {

    @IBOutlet var sceneInterface: WKInterfaceSKScene!
    
    var gameScene: GameScene?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setupGame()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func didTap(recognizer: WKTapGestureRecognizer) {
        gameScene?.didTap(recognizer)
    }
    func setupGame() {
        gameScene = GameScene(size: CGSize(width: contentFrame.size.width, height: contentFrame.size.height))
        
        if let scene = gameScene {
            sceneInterface.presentScene(scene)
        }
    }

}
