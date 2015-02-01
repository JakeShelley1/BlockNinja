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
    let hiClaud = SKLabelNode(fontNamed: "CF Samurai Bob")
    var coinImage = SKSpriteNode(imageNamed: "coin")
    var cloudTexture = SKTexture(imageNamed: "Cloud")
    var cloudMoveAndRemove = SKAction()
    var highScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    var coinText = SKLabelNode(fontNamed: "CF Samurai Bob")
    var cheatCount = 0
    var isCheating = false
    let leftEndOfScreen = SKSpriteNode(imageNamed: "endOfScreen")
    let rightEndOfScreen = SKSpriteNode(imageNamed: "endOfScreen")
    let enemy1Category: UInt32 = 1 << 3
    let enemy2Category: UInt32 = 1 << 4
    let endOfScreenCategory: UInt32 = 1 << 8 //End of screen
    
    override func didMoveToView(view: SKView) {
    
        moving = SKNode()
        self.addChild(moving)
        moving.speed = 0
        createAndMoveClouds()
        var skyColor = SKColor(red: 90.0/255.0, green: 192.0/255.0, blue: 231.0/255.0, alpha: 1.0)
        backgroundColor = skyColor

        self.startButton.setScale(1.5)
        self.startButton.position = CGPointMake((self.frame.size.width/2), CGRectGetMidY(self.frame) + self.startButton.size.height * 0.6)
        self.shopButton.setScale(1.5)
        self.shopButton.position = CGPointMake((self.frame.size.width/2), CGRectGetMidY(self.frame) - self.startButton.size.height * 0.6)
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
        if (coins > 99999) {
            coinText.text = "99999"
        } else {
            coinText.text = String(coins)
        }
        coinText.position = CGPointMake(CGRectGetMinX(frame) + (coinImage.size.width * 1.5), CGRectGetMaxY(frame) - (coinImage.size.height * 2.5))
        self.addChild(coinText)
        coinImage.setScale(0.5)
        coinImage.position = CGPointMake(CGRectGetMinX(frame) + (coinImage.size.width * 0.7), (CGRectGetMaxY(frame) - (coinImage.size.height * 4.5)))
        self.addChild(coinImage)
        
        //Text
        title.text = "BLOCK NINJAS"
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
            
            if ((self.nodeAtPoint(location) == self.coinImage)) {
                cheatCount += 1
                if (cheatCount == 10) {
                    NSUserDefaults.standardUserDefaults().setInteger(99999, forKey: "coins")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    NSUserDefaults.standardUserDefaults().integerForKey("coins")
                    coins = NSUserDefaults.standardUserDefaults().integerForKey("coins")
                    coinText.text = String(coins)
                    isCheating = true
                } else if (cheatCount > 10) {
                    cheatCount = 0
                }
            }
            
            if ((self.nodeAtPoint(location) == self.title) && cheatCount >= 10) {
                cheatCount += 1
                if (cheatCount == 25) {
                    hiClaud.color = UIColor.blackColor()
                    hiClaud.position = CGPointMake(CGRectGetMidX(self.frame) - self.startButton.size.width, CGRectGetMidY(self.frame))
                    hiClaud.text = "LOVE YOU CLAUD"
                    self.addChild(hiClaud)
                }
            }
        }
    }
    
    func createAndMoveClouds() {
        //Cloud spawning
        let spawnACloud = SKAction.runBlock({self.spawnCloud()})
        let spawnThenDelayCloud = SKAction.sequence([spawnACloud, SKAction.waitForDuration(6.0)])
        let spawnThenDelayCloudForever = SKAction.repeatActionForever(spawnThenDelayCloud)
        self.runAction(spawnThenDelayCloudForever)
        let clouddistanceToMove = CGFloat(self.frame.width + 4.0 * cloudTexture.size().width)
        let cloudmovement = SKAction.moveByX(-clouddistanceToMove, y: 0.0, duration: NSTimeInterval(0.025 * clouddistanceToMove))
        let removeCloud = SKAction.removeFromParent()
        cloudMoveAndRemove = SKAction.sequence([cloudmovement, removeCloud])
    }
    
    //Spawn Cloud
    func spawnCloud() {
        let cloud = SKSpriteNode(imageNamed: "Cloud")
        let y = arc4random() % UInt32(frame.size.height)
        var randomSize = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) - 0.6
        if randomSize < 0.0 {
            randomSize = 0.2
        }
        cloud.zPosition = -11
        var randomHeight = UInt32(self.frame.size.height / 1.5) + (arc4random() % UInt32(self.frame.size.height / 2))
        cloud.setScale(randomSize)
        cloud.position = CGPointMake(self.frame.size.width + cloud.size.width, CGFloat(randomHeight))
        
        cloud.runAction(cloudMoveAndRemove)
        self.addChild(cloud)
    }
    
    override func update(currentTime: CFTimeInterval) {
    }
    
}

