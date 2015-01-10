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
    
    var coins = NSUserDefaults.standardUserDefaults().integerForKey("coins")
    let startButton = SKSpriteNode(imageNamed: "otherButton")
    let shopButton = SKSpriteNode(imageNamed: "otherButton")
    let title = SKLabelNode(fontNamed: "CF Samurai Bob")
    var moving: SKNode!
    var highScoreText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let startText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let shopText = SKLabelNode(fontNamed: "CF Samurai Bob")
    var coinImage = SKSpriteNode(imageNamed: "coin")
    var highScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    var coinText = SKLabelNode(fontNamed: "CF Samurai Bob")
    
    override func didMoveToView(view: SKView) {
        moving = SKNode()
        self.addChild(moving)
        moving.speed = 0
        var skyColor = SKColor(red: 90.0/255.0, green: 192.0/255.0, blue: 231.0/255.0, alpha: 1.0)
        backgroundColor = skyColor
        
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
        
        coinText.fontSize = 50
        coinText.fontColor = UIColor.blackColor()
        coinText.text = String(coins)
        coinText.position = CGPointMake(CGRectGetMinX(frame) + (coinImage.size.width * 1.34), CGRectGetMaxY(frame) - (coinImage.size.height * 2.5))
        self.addChild(coinText)
        coinImage.setScale(0.5)
        coinImage.position = CGPointMake(CGRectGetMinX(frame) + (coinImage.size.width * 0.7), (CGRectGetMaxY(frame) - (coinImage.size.height * 4.5)))
        self.addChild(coinImage)
        
        //Text
        title.text = "BLOCK NINJA"
        title.fontSize = 130
        title.fontColor = UIColor.blackColor()
        title.position = CGPoint(x: frame.width/2, y: frame.height/1.35)
        self.addChild(title)
        
        //Probably delete all moving stuff later, unless title screen is going to be cooler
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
        
        //Set initial inventory value
        NSUserDefaults.standardUserDefaults().integerForKey("inventory")
        if (NSUserDefaults.standardUserDefaults().integerForKey("inventory") == 0) {
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "inventory")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        NSUserDefaults.standardUserDefaults().integerForKey("inventory")
        
        //Set initial throwing star recharge speed
        NSUserDefaults.standardUserDefaults().floatForKey("rechargeSpeed")
        if (NSUserDefaults.standardUserDefaults().floatForKey("rechargeSpeed") == 0) {
            NSUserDefaults.standardUserDefaults().setFloat(2.5, forKey: "rechargeSpeed")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        NSUserDefaults.standardUserDefaults().floatForKey("rechargeSpeed")
        
        //Display highscore
        if (highScore != 0) {
            highScoreText.text = ("HIGH SCORE: " + String(highScore))
            highScoreText.fontColor = UIColor.blackColor()
            highScoreText.fontSize = 55
            highScoreText.position = CGPoint(x: frame.width/2, y: frame.height/1.5)
            
            self.addChild(highScoreText)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
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
            if (self.nodeAtPoint(location) == self.shopButton) || (self.nodeAtPoint(location) == self.shopText) {
                var scene = ShopScene(size: self.size)
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

