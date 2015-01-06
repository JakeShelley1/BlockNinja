//
//  PlayScene.swift
//  BlockNinjaV2
//
//  Created by Jake on 11/4/14.
//  Copyright (c) 2014 Jake. All rights reserved.
//


//*******TODO: CHANGE ALL THE SKNODES THAT ARE JUST WORDS INTO SKLABELNODES NOW THAT THE FONT WORKS

import Foundation
import SpriteKit

class PlayScene: SKScene, SKPhysicsContactDelegate {

    
    var score = 0
    let scoreText = SKLabelNode(fontNamed: "CF Samurai Bob")
    var cloudTexture = SKTexture(imageNamed: "Cloud")
    var cloudMoveAndRemove = SKAction()
    var moving: SKNode!
    var enemyImage = SKSpriteNode(imageNamed: "enemyIdle")
    var skyColor: SKColor!
    let jumpButton = SKSpriteNode(imageNamed: "JumpAttackButton")
    let attackButton = SKSpriteNode(imageNamed: "JumpAttackButton")
    
    let hero = Hero(health: 1)
    let enemy1 = Enemy(health: 1, jumper: false)
    let enemy2 = Enemy(health: 1, jumper: false)
    let enemy3 = Enemy(health: 1, jumper: false)
    
    let playButton = SKSpriteNode(imageNamed: "button")
    let pressedPlayButton = SKSpriteNode(imageNamed: "pressedButton")
    let menuButton = SKSpriteNode(imageNamed: "button")
    let pressedMenuButton = SKSpriteNode(imageNamed: "pressedButton")
    let displayPanel = SKSpriteNode(imageNamed: "brownPanel")
    let playAgainText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let menuText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let gameOverText = SKLabelNode(fontNamed: "CF Samurai Bob")
    
    let pauseText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let pauseMenuText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let resumeText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let restartText = SKLabelNode(fontNamed: "CF Samurai Bob")
    let resumeButton = SKSpriteNode(imageNamed: "button")
    let pauseMenuButton = SKSpriteNode(imageNamed: "button")
    let restartButton = SKSpriteNode(imageNamed: "button")
    
    
    let pausePicture = SKSpriteNode(imageNamed: "pausePic")
    let pauseButton = SKSpriteNode(imageNamed: "smallButton")
    
    var shuriken: SKSpriteNode!
    
    let leftEndOfScreen = SKSpriteNode(imageNamed: "endOfScreen")
    let rightEndOfScreen = SKSpriteNode(imageNamed: "endOfScreen")
    
    //Colliders
    let groundCategory: UInt32 = 1 << 0
    let ninjaCategory: UInt32 = 1 << 1
    let weaponCategory: UInt32 = 1 << 2 //Ninja's weapons
    let enemy1Category: UInt32 = 1 << 3
    let enemy2Category: UInt32 = 1 << 4
    let enemy3Category: UInt32 = 1 << 5
    let enemy4Category: UInt32 = 1 << 6
    let enemyWeaponCategory: UInt32 = 1 << 7 //Enemy weapons
    let endOfScreenCategory: UInt32 = 1 << 8 //End of screen
    
    override func didMoveToView(view: SKView) {
        
        moving = SKNode()
        self.addChild(moving)
        moving.speed = 1
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0.0, -12.8)
        
        //Score
        self.scoreText.text = "0"
        self.scoreText.fontSize = 50
        self.scoreText.position = CGPoint(x: self.frame.width/1.05, y: self.frame.height/1.1)
        self.scoreText.fontColor = UIColor.blackColor()
        self.addChild(scoreText)
        
        //End of Screen stuff
        let endScreenSize = CGSize(width: leftEndOfScreen.size.width, height: leftEndOfScreen.size.height)
        leftEndOfScreen.physicsBody = SKPhysicsBody(rectangleOfSize: endScreenSize)
        leftEndOfScreen.position = CGPointMake(-enemy1.ninja.size.width, frame.size.height/2)
        leftEndOfScreen.hidden = false
        leftEndOfScreen.physicsBody?.categoryBitMask = endOfScreenCategory
        leftEndOfScreen.physicsBody?.contactTestBitMask = weaponCategory | enemy1Category | enemy2Category | enemy3Category | enemy4Category
        leftEndOfScreen.physicsBody?.dynamic = false
        
        rightEndOfScreen.physicsBody = SKPhysicsBody(rectangleOfSize: endScreenSize)
        rightEndOfScreen.position = CGPointMake(frame.size.width + enemy1.ninja.size.width, frame.size.height/2)
        rightEndOfScreen.physicsBody?.categoryBitMask = endOfScreenCategory
        rightEndOfScreen.physicsBody?.contactTestBitMask = weaponCategory
        rightEndOfScreen.physicsBody?.dynamic = false
        
        self.addChild(leftEndOfScreen)
        self.addChild(rightEndOfScreen)
        
        //Pause Button
        pauseButton.setScale(1)
        pauseButton.position = CGPointMake(CGRectGetMinX(self.frame) + (1.05 * pauseButton.size.width), CGRectGetMaxY(self.frame) - (1.05 * pauseButton.size.height))
        pauseButton.addChild(pausePicture)
        self.addChild(pauseButton)
        
        //Create player's ninja
        hero.createHero(self.frame.width)
        hero.ninja.physicsBody?.categoryBitMask = ninjaCategory
        hero.ninja.physicsBody?.contactTestBitMask = groundCategory
        hero.ninja.physicsBody?.collisionBitMask = groundCategory | enemy1Category | enemy2Category | enemy3Category | enemy4Category
        
        
        //*****when finished, start enemies as isDead = true
        self.addChild(enemy1.createEnemy(frame.size.width, speed: 0.013, size: 0.6))
        self.addChild(enemy2.createEnemy(frame.size.width, speed: 0.011, size: 0.6))
        self.addChild(enemy3.createEnemy(frame.size.width, speed: 0.005, size: 0.4))
        self.addChild(hero.ninja)
        
        //Add enemies (set isDead to true later)
        enemy1.ninja.physicsBody?.categoryBitMask = enemy1Category
        enemy2.ninja.physicsBody?.categoryBitMask = enemy2Category
        enemy3.ninja.physicsBody?.categoryBitMask = enemy3Category
        //enemy1.isDead = true
        //enemy2.isDead = true
        //enemy3.isDead = true
        
        //Ground
        let groundTexture = SKTexture(imageNamed: "Ground")
        groundTexture.filteringMode = .Nearest
        
        let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.006 * groundTexture.size().width * 2.0))
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        //Move Ground
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( groundTexture.size().width * 0.5 ); ++i {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(1.0)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 4)
            sprite.runAction(moveGroundSpritesForever, withKey: "moveGroundSprite")
            sprite.physicsBody?.dynamic = false
            moving.addChild(sprite)
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
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width * 4, groundTexture.size().height / 4.0))
        ground.setScale(1.0)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.contactTestBitMask = ninjaCategory | enemy1Category | enemy2Category | enemy3Category | enemy4Category
        ground.physicsBody?.collisionBitMask = ninjaCategory | enemy1Category | enemy2Category | enemy3Category | enemy4Category
        ground.physicsBody?.restitution = 0.0
        self.addChild(ground)
        
        //Jump and Attack buttons
        attackButton.position = CGPointMake(CGRectGetMidX(self.frame) * 1.5, CGRectGetMidY(self.frame))
        jumpButton.position = CGPointMake(CGRectGetMidX(self.frame) / 2, CGRectGetMidY(self.frame))
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
            enemy1.health = enemy1.health - 1
            shuriken.removeFromParent()
            if enemy1.health == 0 {
                score++
                self.scoreText.text = String(self.score)
                enemy1.playDeadAnimation(frame.size.width)
            }
            
        case enemy2Category | weaponCategory:
            enemy2.health = enemy2.health - 1
            shuriken.removeFromParent()
            if enemy2.health == 0 {
                score++
                self.scoreText.text = String(self.score)
                enemy2.playDeadAnimation(frame.size.width)
            }
            
        case enemy2Category | groundCategory:
            if (enemy2.health != 0 && enemy2.jumper == true) {
                enemy2.jump()
            }
        case enemy3Category | weaponCategory:
            enemy3.health = enemy3.health - 1
            shuriken.removeFromParent()
            if enemy3.health == 0 {
                score++
                self.scoreText.text = String(self.score)
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
            
        case (weaponCategory | endOfScreenCategory):
            shuriken.removeFromParent()

        //death of enemy
        case (enemy1Category | endOfScreenCategory):
            enemy1.isDead = true
            
        case (enemy3Category | endOfScreenCategory):
            enemy3.isDead = true
            
        case (enemy2Category | endOfScreenCategory):
            enemy2.isDead = true
            
            
        default:
            return
        }
        
    }
    
    
    //Run everytime frame is rendered
    override func update(currentTime: CFTimeInterval) {
        
        //RESPAWN ENEMIES -- TODO: make enemies with the ability to jump (and throw stars)
        if enemy1.isDead {
            enemy1.isDead = false
            let respawnSequence = SKAction.sequence([SKAction.runBlock({self.enemy1.ninja.removeFromParent()}), SKAction.runBlock({
                self.enemy1.isDead = false
                var delay = CGFloat((arc4random() % 10) / 2)
                var thisSpeed = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * 0.01
                var thisSize = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
                
                //if size or speed are too low or fast
                if thisSize < 0.35 || thisSize > 0.7 {
                    thisSize = 0.55
                }
                if thisSpeed < 0.0035 {
                    thisSpeed = 0.005
                }
                
                self.enemy1.health = 1
                self.addChild(self.enemy1.createEnemy(self.frame.size.width, speed: thisSpeed, size: thisSize))
                self.enemy1.ninja.physicsBody?.categoryBitMask = self.enemy1Category
            })])
            self.runAction(respawnSequence)
        }
        if enemy2.isDead {
            enemy2.isDead = false
            let respawnSequence = SKAction.sequence([SKAction.runBlock({self.enemy2.ninja.removeFromParent()}), SKAction.runBlock({
                self.enemy2.isDead = false
                var delay = CGFloat((arc4random() % 10) / 2)
                var thisSpeed = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * 0.01
                var thisSize = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
                //if size or speed are too low or fast
                if thisSize < 0.35 || thisSize > 0.7 {
                    thisSize = 0.55
                }
                if thisSpeed < 0.0035 {
                    thisSpeed = 0.005
                }
                
                self.enemy2.health = 1
                self.addChild(self.enemy2.createEnemy(self.frame.size.width, speed: thisSpeed, size: thisSize))
                self.enemy2.ninja.physicsBody?.categoryBitMask = self.enemy2Category
            })])
            self.runAction(respawnSequence)
        }
        
        if enemy3.isDead {
            enemy3.isDead = false
            let respawnSequence = SKAction.sequence([SKAction.runBlock({self.enemy3.ninja.removeFromParent()}), SKAction.runBlock({
                self.enemy3.isDead = false
                var delay = CGFloat((arc4random() % 10) / 2)
                var thisSpeed = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * 0.01
                var thisSize = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
                //if size or speed are too low or fast
                if thisSize < 0.35 || thisSize > 0.7 {
                    thisSize = 0.55
                }
                if thisSpeed < 0.0035 {
                    thisSpeed = 0.005
                }
                
                self.enemy3.health = 1
                self.addChild(self.enemy3.createEnemy(self.frame.size.width, speed: thisSpeed, size: thisSize))
                self.enemy3.ninja.physicsBody?.categoryBitMask = self.enemy3Category
            })])
            self.runAction(respawnSequence)
        }
    }

    //Touches
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if (CGRectContainsPoint(attackButton.frame, touch.locationInNode(self)) & (!hero.isDead)) {
                shuriken = hero.throwStar()
                shuriken.physicsBody?.categoryBitMask = weaponCategory
                shuriken.physicsBody?.contactTestBitMask = enemy1Category | enemy2Category | enemy3Category | endOfScreenCategory
                shuriken.physicsBody?.collisionBitMask = 0
                self.addChild(shuriken)
                shuriken.physicsBody?.velocity = CGVectorMake(20, 0)
                shuriken.physicsBody?.applyImpulse(CGVectorMake(20, 0))
            }
            
            if (CGRectContainsPoint(jumpButton.frame, touch.locationInNode(self)) & (hero.onGround) & (!hero.isDead))  {
                hero.jump()
            }
            
            if (CGRectContainsPoint(self.menuButton.frame, touch.locationInNode(displayPanel))) {
                if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
                    let skView = self.view as SKView!
                    skView.ignoresSiblingOrder = true
                    scene.scaleMode = .AspectFill
                    skView.presentScene(scene)
                }
            }
            
            if (CGRectContainsPoint(self.playButton.frame, touch.locationInNode(displayPanel))) {
                self.removeAllChildren()
                var scene = PlayScene(size: self.size)
                let skView = self.view as SKView!
                skView.ignoresSiblingOrder = false
                scene.scaleMode = .ResizeFill
                scene.size = skView.bounds.size
                skView.presentScene(scene)
            }
            
            if (CGRectContainsPoint(self.pauseButton.frame, touch.locationInNode(self)) & (self.view?.paused == false)) {
                pauseGame()
                self.view?.paused = true
            }
            
            if (CGRectContainsPoint(self.pauseButton.frame, touch.locationInNode(self)) & (self.view?.paused == true)) {
                self.view?.paused = false
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
        
        highScoring()
        
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
        playAgainText.fontSize = 45
        playAgainText.fontColor = UIColor.blackColor()
        playAgainText.position = CGPointMake(0, -self.playButton.size.height/7)
        gameOverText.position = CGPointMake(0, displayPanel.size.height/4)
        menuText.position = CGPointMake(0, -self.menuButton.size.height/7)
        menuText.fontSize = 45
        menuText.fontColor = UIColor.blackColor()
        gameOverText.fontSize = 23
        gameOverText.fontColor = UIColor.blackColor()
        gameOverText.text = "GAME OVER"
        menuText.text = "MENU"
        playAgainText.text = "PLAY AGAIN"
        
        displayPanel.zPosition = 10
        self.menuButton.addChild(menuText)
        self.playButton.addChild(playAgainText)
        self.menuButton.position = CGPointMake(0, displayPanel.size.height - self.playButton.size.height*2.5)
        displayPanel.setScale(3)
        self.playButton.setScale(0.3)
        self.menuButton.setScale(0.3)
        displayPanel.addChild(gameOverText)
        displayPanel.addChild(self.playButton)
        displayPanel.addChild(self.menuButton)
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
    
    func highScoring() {
        NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    
        //Check if score is higher than NSUserDefaults stored value and change NSUserDefaults stored value if it's true
        if score > NSUserDefaults.standardUserDefaults().integerForKey("highscore") {
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highscore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    
    }
    
    func pauseGame() {
        
        pauseMenuText.fontSize = 45
        pauseMenuText.fontColor = UIColor.blackColor()
        pauseMenuText.text = ("MENU")
        resumeText.fontSize = 45
        resumeText.fontColor = UIColor.blackColor()
        resumeText.text = ("RESUME")
        restartText.fontSize = 45
        restartText.fontColor = UIColor.blackColor()
        restartText.text = ("NEW GAME")
        pauseMenuButton.setScale(0.8)
        pauseMenuButton.position = CGPointMake((frame.size.width/2) + (pauseMenuButton.size.width * 1.2), (frame.size.height/2 + pauseMenuButton.size.height))
        resumeButton.setScale(0.8)
        resumeButton.position = CGPointMake((frame.size.width/2) - (pauseMenuButton.size.width * 1.2), (frame.size.height/2 + pauseMenuButton.size.height))
        restartButton.setScale(0.8)
        restartButton.position = CGPointMake((frame.size.width/2), (frame.size.height/2 - pauseMenuButton.size.height))
        self.addChild(pauseMenuButton)
        self.addChild(restartButton)
        self.addChild(resumeButton)
        pauseMenuButton.addChild(pauseMenuText)
        resumeButton.addChild(resumeText)
        restartButton.addChild(restartText)
        pauseText.position = CGPointMake(frame.size.width/2, frame.size.height/2 + pauseMenuButton.size.height * 2)
        self.addChild(pauseText)
    }

}

