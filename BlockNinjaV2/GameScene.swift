//
//  GameScene.swift
//  BlockNinjaV2
//
//  Created by Jake on 11/4/14.
//  Copyright (c) 2014 Jake. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let start = SKSpriteNode(imageNamed: "title")
    let displayPanel = SKSpriteNode(imageNamed: "brownPanel")
    override func didMoveToView(view: SKView) {
        displayPanel.setScale(5.0)
        start.setScale(2.0)
        self.start.position = CGPointMake(self.frame.size.width/2, CGRectGetMidY(self.frame))
        displayPanel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        self.addChild(displayPanel)
        self.addChild(start)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.start {
                var scene = PlayScene(size: self.size)
                let skView = self.view as SKView!
                skView.ignoresSiblingOrder = true
                scene.scaleMode = .ResizeFill
                scene.size = skView.bounds.size
                skView.presentScene(scene)
                
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
