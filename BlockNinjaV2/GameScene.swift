//
//  GameScene.swift
//  BlockNinjaV2
//
//  Created by Jake on 11/4/14.
//  Copyright (c) 2014 Jake. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    
    let start = SKSpriteNode(imageNamed: "title")
    let displayPanel = SKSpriteNode(imageNamed: "brownPanel")
    var moving: SKNode!

    override func didMoveToView(view: SKView) {
        moving = SKNode()
        self.addChild(moving)
        moving.speed = 0
        var skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        backgroundColor = skyColor
        
        start.setScale(2.0)
        self.start.position = CGPointMake(self.frame.size.width/2, CGRectGetMidY(self.frame) + start.size.height)
        
        moving.addChild(start)
        let groundTexture = SKTexture(imageNamed: "Ground")
        groundTexture.filteringMode = .Nearest
        
        let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.006 * groundTexture.size().width * 2.0))
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        //Move Ground
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( groundTexture.size().width * 0.5 ); ++i {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(1.0)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height)
            sprite.runAction(moveGroundSpritesForever, withKey: "moveGroundSprite")
            sprite.physicsBody?.dynamic = false
            moving.addChild(sprite)
            
            
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.moving {
                var scene = PlayScene(size: self.size)
                let skView = self.view as SKView!
                skView.ignoresSiblingOrder = true
                scene.scaleMode = .ResizeFill
                scene.size = skView.bounds.size
                self.removeAllChildren()
                skView.presentScene(scene)
                
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}

