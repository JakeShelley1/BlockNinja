//
//  PlayScene.swift
//  BlockNinjaV2
//
//  Created by Jake on 11/4/14.
//  Copyright (c) 2014 Jake. All rights reserved.
//

import Foundation
import SpriteKit

class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    var cloudTexture = SKTexture(imageNamed: "Cloud")
    var cloudMoveAndRemove = SKAction()
    var moving: SKNode!
    var enemyImage = SKSpriteNode(imageNamed: "enemyIdle")
    var skyColor: SKColor!
    let jumpButton = SKSpriteNode(imageNamed: "JumpAttackButton")
    let attackButton = SKSpriteNode(imageNamed: "JumpAttackButton")
    
    let hero = Hero(health: 1)
    let enemy1 = Enemy(health: 1)
    let enemy2 = Enemy(health: 1)
    let enemy3 = Enemy(health: 3)
    
    let playButton = SKSpriteNode(imageNamed: "button")
    let pressedPlayButton = SKSpriteNode(imageNamed: "pressedButton")
    let menuButton = SKSpriteNode(imageNamed: "button")
    let pressedMenuButton = SKSpriteNode(imageNamed: "pressedButton")
    let displayPanel = SKSpriteNode(imageNamed: "brownPanel")
    
    var shuriken: SKSpriteNode!
    
    //Colliders
    let groundCategory: UInt32 = 1 << 0
    let ninjaCategory: UInt32 = 1 << 1
    let weaponCategory: UInt32 = 1 << 2 //Ninja's weapons
    let enemy1Category: UInt32 = 1 << 3
    let enemy2Category: UInt32 = 1 << 4
    let enemy3Category: UInt32 = 1 << 5
    let enemy4Category: UInt32 = 1 << 6
    let enemyWeaponCategory: UInt32 = 1 << 7 //Enemy weapons
    
    
    override func didMoveToView(view: SKView) {
        moving = SKNode()
        self.addChild(moving)
        moving.speed = 1
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0.0, -12.8)
        
        
        hero.createHero(self.frame.width)
        hero.ninja.physicsBody?.categoryBitMask = ninjaCategory
        hero.ninja.physicsBody?.contactTestBitMask = groundCategory
        hero.ninja.physicsBody?.collisionBitMask = groundCategory | enemy1Category | enemy2Category | enemy3Category | enemy4Category
        
        self.addChild(enemy1.createEnemy(frame.size.width, speed: 0.013, size: 0.6))
        self.addChild(enemy2.createEnemy(frame.size.width, speed: 0.010, size: 0.4))
        self.addChild(enemy3.createEnemy(frame.size.width, speed: 0.03, size: 1.2))
        self.addChild(hero.ninja)
        enemy1.ninja.physicsBody?.categoryBitMask = enemy1Category
        enemy2.ninja.physicsBody?.categoryBitMask = enemy2Category
        enemy3.ninja.physicsBody?.categoryBitMask = enemy3Category
        //Ground
        
        //Moving Ground
        let groundTexture = SKTexture(imageNamed: "Ground")
        groundTexture.filteringMode = .Nearest
        
        let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.006 * groundTexture.size().width * 2.0))
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        //Move Ground
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( groundTexture.size().width * 0.5 ); ++i {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(1.0)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 4.0)
            if !hero.isDead {
                sprite.runAction(moveGroundSpritesForever, withKey: "moveGroundSprite")
                moving.addChild(sprite)
            }
        }
        
        //Cloud spawning
        let spawnACloud = SKAction.runBlock({self.spawnCloud()})
        let spawnThenDelayCloud = SKAction.sequence([spawnACloud, SKAction.waitForDuration(6.0)])
        let spawnThenDelayCloudForever = SKAction.repeatActionForever(spawnThenDelayCloud)
        self.runAction(spawnThenDelayCloudForever)
        
        let clouddistanceToMove = CGFloat(self.frame.width + 4.0 * cloudTexture.size().width)
        let cloudmovement = SKAction.moveByX(-clouddistanceToMove, y: 0.0, duration: NSTimeInterval(0.025 * clouddistanceToMove))
        let removeCloud = SKAction.removeFromParent()
        cloudMoveAndRemove = SKAction.sequence([cloudmovement, removeCloud])
        
        
        //Actual Ground
        var ground = SKNode()
        ground.position = CGPointMake(0, groundTexture.size().height / 1.47)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width * 3, groundTexture.size().height / 4.0))
        ground.setScale(1.0)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.contactTestBitMask = ninjaCategory | enemy1Category | enemy2Category | enemy3Category | enemy4Category
        ground.physicsBody?.collisionBitMask = ninjaCategory | enemy1Category | enemy2Category | enemy3Category | enemy4Category
        ground.physicsBody?.restitution = 0.0
        self.addChild(ground)
        
        //Jump and Attack buttons
        attackButton.position = CGPointMake(CGRectGetMidX(self.frame) * 1.5, CGRectGetMinY(self.frame))
        jumpButton.position = CGPointMake(CGRectGetMidX(self.frame) / 2, CGRectGetMinY(self.frame))
        jumpButton.physicsBody?.dynamic = false
        attackButton.physicsBody?.dynamic = false
        attackButton.hidden = true
        jumpButton.hidden = true
        jumpButton.setScale(1.1)
        attackButton.setScale(1.1)
        
        self.addChild(jumpButton)
        self.addChild(attackButton)
        
    }
    
    //Contact
    func didBeginContact(contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
        case groundCategory | ninjaCategory:
        if !hero.isDead {
                hero.onGround = true
                hero.playWalkAnimation()
        } else {
            endGame()
            }
        case enemy1Category | weaponCategory:
            enemy1.fakeHealth = enemy1.fakeHealth - 1
            shuriken.removeFromParent()
            if enemy1.fakeHealth == 0 {
                enemy1.playDeadAnimation(frame.size.width)
            }
            
        case enemy2Category | weaponCategory:
            enemy2.fakeHealth = enemy2.fakeHealth - 1
            shuriken.removeFromParent()
            if enemy2.fakeHealth == 0 {
                enemy2.playDeadAnimation(frame.size.width)
            }
        case enemy3Category | weaponCategory:
            enemy3.fakeHealth = enemy3.fakeHealth - 1
            shuriken.removeFromParent()
            if enemy3.fakeHealth == 0 {
                enemy3.playDeadAnimation(frame.size.width)
            }

        /*
        case enemy1Category | weaponCategory:
            shuriken.removeFromParent()
            enemy1.playDeadAnimation(frame.size.width)
        */
            
        case (enemy1Category | ninjaCategory):
            if !hero.isDead{
                die()
            }
        case (enemy2Category | ninjaCategory):
            if !hero.isDead{
                die()
            }
        case (enemy3Category | ninjaCategory):
            if !hero.isDead{
                die()
            }
        case (enemy4Category | ninjaCategory):
            if !hero.isDead{
                die()
            }
        default:
            return
        }
        
    }
    
    
    //Run everytime frame is rendered
    override func update(currentTime: CFTimeInterval) {

    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if (CGRectContainsPoint(attackButton.frame, touch.locationInNode(self)) & (!hero.isDead)) {
                shuriken = hero.throwStar()
                shuriken.physicsBody?.categoryBitMask = weaponCategory
                shuriken.physicsBody?.contactTestBitMask = enemy1Category | enemy2Category | enemy3Category
                shuriken.physicsBody?.collisionBitMask = 0
                self.addChild(shuriken)
                shuriken.physicsBody?.velocity = CGVectorMake(20, 0)
                shuriken.physicsBody?.applyImpulse(CGVectorMake(20, 0))
            }
            
            if (CGRectContainsPoint(jumpButton.frame, touch.locationInNode(displayPanel)) & (hero.onGround) & (!hero.isDead))  {
                hero.jump()
            }
            
            if (CGRectContainsPoint(menuButton.frame, touch.locationInNode(displayPanel))) {
                if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
                    let skView = self.view as SKView!
                    skView.ignoresSiblingOrder = true
                    scene.scaleMode = .AspectFill
                    skView.presentScene(scene)
                }
            }
            
            if (CGRectContainsPoint(playButton.frame, touch.locationInNode(displayPanel))) {
                self.removeAllChildren()
                var scene = PlayScene(size: self.size)
                let skView = self.view as SKView!
                //skView.ignoresSiblingOrder = true
                scene.scaleMode = .ResizeFill
                scene.size = skView.bounds.size
                skView.presentScene(scene)
            }
        }
    }
    
    //You die
    func die() {
        moving.speed = 0
        hero.playDeadAnimation()
        jumpButton.removeFromParent()
        attackButton.removeFromParent()
        enemy1.ninja.physicsBody?.collisionBitMask = groundCategory | weaponCategory
        SKAction.sequence([SKAction.runBlock({
            self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        }), SKAction.waitForDuration(NSTimeInterval(0.08)), SKAction.runBlock({self.backgroundColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)})])
    }
    
    //Game Over Screen
    func endGame() {
        let tintScreen = SKSpriteNode()
        enemy1.ninja.physicsBody?.collisionBitMask = groundCategory
        tintScreen.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        tintScreen.size = CGSize(width: frame.size.width, height: frame.size.height)
        tintScreen.color = SKColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        tintScreen.zPosition = 1
        let gameOver = SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock({self.addChild(tintScreen)}), SKAction.runBlock({self.createEndPanel()})])
        self.runAction(gameOver)
    }
    
    //Create end game panel
    func createEndPanel() {
        let playAgainText = SKSpriteNode(imageNamed: "playAgain")
        let menuText = SKSpriteNode(imageNamed: "menu")
        let gameOverText = SKSpriteNode(imageNamed: "gameOver")
        playAgainText.position = CGPointMake(0, playButton.size.height/4)
        gameOverText.position = CGPointMake(0, displayPanel.size.height/4)
        menuText.position = CGPointMake(0, menuButton.size.height/4)
        gameOverText.setScale(0.3)
        playAgainText.setScale(0.7)
        menuText.setScale(0.7)
        displayPanel.zPosition = 10
        menuButton.addChild(menuText)
        playButton.addChild(playAgainText)
        menuButton.position = CGPointMake(0, displayPanel.size.height - playButton.size.height*2.5)
        displayPanel.setScale(3)
        playButton.setScale(0.3)
        menuButton.setScale(0.3)
        displayPanel.addChild(gameOverText)
        displayPanel.addChild(playButton)
        displayPanel.addChild(menuButton)
        displayPanel.position = CGPointMake(frame.size.width/2, frame.size.height + displayPanel.size.height)
        self.addChild(displayPanel)
        let moveDisplay = SKAction.moveByX(0, y: -(frame.size.height/2 + displayPanel.size.height), duration: 1)
        displayPanel.runAction(moveDisplay)

    }
    
    //Spawn Cloud
    func spawnCloud() {
        let cloud = SKSpriteNode(imageNamed: "Cloud")
        let y = arc4random() % UInt32(frame.size.height)
        var randomSize = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) - 0.6
        if randomSize < 0.0 {
            randomSize = 0.2
        }
        var randomHeight = UInt32(self.frame.size.height / 1.5) + (arc4random() % UInt32(self.frame.size.height / 2))
        cloud.setScale(randomSize)
        cloud.position = CGPointMake(self.frame.size.width + cloud.size.width, CGFloat(randomHeight))
        
        cloud.runAction(cloudMoveAndRemove)
        self.addChild(cloud)
    }
}





