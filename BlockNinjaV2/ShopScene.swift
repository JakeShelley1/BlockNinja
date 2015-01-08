//
//  ShopScene.swift
//  BlockNinjaV2
//
//  Created by Jake on 1/7/15.
//  Copyright (c) 2015 Jake. All rights reserved.
//

import Foundation
import SpriteKit

class ShopScene: SKScene {

    var coins = NSUserDefaults.standardUserDefaults().integerForKey("coins")
    let coinImage = SKSpriteNode(imageNamed: "coin")
    let coinText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let startButton = SKSpriteNode(imageNamed: "otherButton")
    let shopButton = SKSpriteNode(imageNamed: "otherButton")
    let title = SKLabelNode(fontNamed: "CF Samurai Bob")
    var moving: SKNode!
    var highScoreText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let startText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let shopText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let buildings = SKSpriteNode(imageNamed: "buildings")
    
    override func didMoveToView(view: SKView) {
        
        var skyColor = SKColor(red: 25.0/255.0, green: 25.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        backgroundColor = skyColor
        buildings.setScale(0.5)
        buildings.position = CGPointMake(frame.size.width/2, buildings.size.height*0.5)
        self.addChild(buildings)
        showCoins()
        
        /*
        self.startButton.setScale(1.5)
        self.startButton.position = CGPointMake((self.frame.size.width/2) - ((self.frame.width/2) * 0.5), CGRectGetMidY(self.frame))
        self.shopButton.setScale(1.5)
        self.shopButton.position = CGPointMake((self.frame.size.width/2) + ((self.frame.width/2) * 0.5), CGRectGetMidY(self.frame))
        self.addChild(self.shopButton)
        self.addChild(self.startButton)
        self.startText.text = ("START")
        startText.fontColor = UIColor.blackColor()
        startText.fontSize = 50
        shopText.text = ("SHOP")
        shopText.fontColor = UIColor.blackColor()
        shopText.fontSize = 50
        startText.position = CGPointMake(0, -self.startButton.size.height / 8)
        shopText.position = CGPointMake(0, -self.shopButton.size.height / 8)
        self.startButton.addChild(startText)
        self.shopButton.addChild(shopText)
        */
        //Text
        title.text = "COMING SOON"
        title.fontSize = 60
        title.fontColor = UIColor.whiteColor()
        title.position = CGPoint(x: frame.width/2, y: frame.height/2)
        self.addChild(title)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
            if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
                let skView = self.view as SKView!
                skView.ignoresSiblingOrder = true
                scene.scaleMode = .AspectFill
                skView.presentScene(scene)
            }
        
        /*
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if (self.nodeAtPoint(location) == self.startButton) || (self.nodeAtPoint(location) == self.startText) {
                var scene = PlayScene(size: self.size)
                let skView = self.view as SKView!
                skView.ignoresSiblingOrder = true
                scene.scaleMode = .ResizeFill
                scene.size = skView.bounds.size
                self.removeAllChildren()
                skView.presentScene(scene)
                
            }
        }
        */
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    func showCoins() {
        
        coinText.fontSize = 50
        coinText.fontColor = UIColor.whiteColor()
        coinText.text = String(coins)
        coinText.position = CGPointMake(CGRectGetMinX(frame) + (coinImage.size.width * 1.34), CGRectGetMaxY(frame) - (coinImage.size.height/1.5))
        self.addChild(coinText)
        coinImage.setScale(0.5)
        coinImage.position = CGPointMake(CGRectGetMinX(frame) + (coinImage.size.width * 0.7), (CGRectGetMaxY(frame) - (coinImage.size.height * 0.7)))
        self.addChild(coinImage)
        
    }
}