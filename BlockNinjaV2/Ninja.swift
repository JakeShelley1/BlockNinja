//
//  Ninja.swift
//  BlockNinjaV2
//
//  Created by Jake on 11/4/14.
//  Copyright (c) 2014 Jake. All rights reserved.
//

import Foundation
import SpriteKit

let groundCategory: UInt32 = 1 << 0
let ninjaCategory: UInt32 = 1 << 1
let weaponCategory: UInt32 = 1 << 2 //Ninja's weapons
let enemyWeaponCategory: UInt32 = 1 << 4 //Enemy weapons

class Hero {
    var isDead = false
    var health: Int
    var ninja = SKSpriteNode(imageNamed: "idle")
    var onGround = false
    
    init(health: Int) {
        self.health = health
    }
    
    
    //Add physics and position to hero
    func createHero(frameWidth: CGFloat) {
        
        ninja.position = CGPoint(x: frameWidth / 6, y: ninja.size.height * 2.5)
        let adjustedNinjaSize = CGSize(width: ninja.size.width * 0.6, height: ninja.size.height * 0.6)
        ninja.physicsBody = SKPhysicsBody(rectangleOfSize: adjustedNinjaSize)
        ninja.physicsBody?.dynamic = true
        ninja.setScale(0.6)
        ninja.physicsBody?.restitution = 0.0
        ninja.physicsBody?.allowsRotation = false
    
    }

    func playWalkAnimation() {
    
        let walk1 = SKTexture(imageNamed: "walk1")
        let walk2 = SKTexture(imageNamed: "walk2")
        let walk3 = SKTexture(imageNamed: "walk3")
        let walk4 = SKTexture(imageNamed: "walk4")
    
        let walkAnim = SKAction.animateWithTextures([walk1, walk2, walk3, walk4, walk3, walk2], timePerFrame: 0.1)
        let walk = SKAction.repeatActionForever(walkAnim)
        ninja.runAction(walk)
    
    }
    
    func playJumpAnimation() {
        
        let jump1 = SKTexture(imageNamed: "jump")
        let jumpAnim = SKAction.animateWithTextures([jump1], timePerFrame: 0.1)
        let jump = SKAction.repeatActionForever(jumpAnim)
        
        ninja.runAction(jump)
    }
    
    func jump() {
        ninja.physicsBody?.applyImpulse(CGVectorMake(0, 100))
        playJumpAnimation()
        onGround = false
    }
    
    func throwStar()-> SKSpriteNode {
        var shuriken = SKSpriteNode(imageNamed: "shuriken")
        let shurikenSize = CGSize(width: shuriken.size.width * 0.3, height: shuriken.size.height * 0.3)
        shuriken.setScale(0.8)
        shuriken.position = CGPointMake(ninja.position.x / 1.5, ninja.position.y)
        shuriken.physicsBody = SKPhysicsBody(rectangleOfSize: shurikenSize)
        shuriken.physicsBody?.dynamic = true
        shuriken.physicsBody?.affectedByGravity = false
        
        playThrowAnimation()
        return shuriken
    }
    
    func playThrowAnimation() {
        let throw = SKTexture(imageNamed: "throw")
        let playThrow = SKAction.animateWithTextures([throw], timePerFrame: 0.1)
        ninja.runAction(playThrow)
    }
    
    func playDeadAnimation() {
        isDead = true
        ninja.physicsBody?.collisionBitMask = groundCategory
        let dead = SKTexture(imageNamed: "dead")
        let deadAnim = SKAction.repeatActionForever(SKAction.animateWithTextures([dead], timePerFrame: 20.0))
        ninja.runAction(deadAnim)
        ninja.physicsBody?.applyImpulse(CGVectorMake(0, 90))
    }
}




class Enemy {
    var enemyMoveAndRemove: SKAction!
    var isRunning = true
    var health: Int
    var fakeHealth: Int
    var ninja = SKSpriteNode(imageNamed: "enemyIdle")
    var onGround = false
    init(health: Int) {
        self.health = health
        self.fakeHealth = health
    }
    
    //Add physics and position to hero
    func createEnemy(frameWidth: CGFloat, speed: CGFloat, size: CGFloat)-> SKSpriteNode{
        isRunning = true
        var shuriken = SKSpriteNode(imageNamed: "shuriken")
        ninja.position = CGPoint(x: frameWidth + ninja.size.width, y: ninja.size.height * 2)
        let adjustedNinjaSize = CGSize(width: ninja.size.width * 0.4, height: ninja.size.height * 0.4)
        ninja.physicsBody = SKPhysicsBody(rectangleOfSize: adjustedNinjaSize)
        ninja.physicsBody?.dynamic = true
        ninja.setScale(size)
        ninja.physicsBody?.restitution = 0.0
        ninja.physicsBody?.allowsRotation = false
        let enemyDistanceToMove = CGFloat(frameWidth * ninja.size.width)
        let enemyMovement = SKAction.moveByX(-enemyDistanceToMove, y: 0.0, duration: NSTimeInterval(speed * enemyDistanceToMove))
        enemyMoveAndRemove = SKAction.sequence([SKAction.waitForDuration(2), enemyMovement, SKAction.runBlock({self.playDeadAnimation(frameWidth)})])
        
        ninja.physicsBody?.contactTestBitMask = ninjaCategory | groundCategory
        ninja.physicsBody?.collisionBitMask = groundCategory
        
        playWalkAnimation()
        ninja.runAction(enemyMoveAndRemove, withKey: "enemyMoveAndRemove")
        
        return ninja
    }
    
    func playWalkAnimation() {
        
        let walk1 = SKTexture(imageNamed: "enemyWalk1")
        let walk2 = SKTexture(imageNamed: "enemyWalk2")
        let walk3 = SKTexture(imageNamed: "enemyWalk3")
        let walk4 = SKTexture(imageNamed: "enemyWalk4")
        
        let walkAnim = SKAction.animateWithTextures([walk1, walk2, walk3, walk4, walk3, walk2], timePerFrame: 0.1)
        let walk = SKAction.repeatActionForever(walkAnim)
        ninja.runAction(walk)
        
    }
    
    func playJumpAnimation() {
        
        let jump1 = SKTexture(imageNamed: "enemyJump")
        let jumpAnim = SKAction.animateWithTextures([jump1], timePerFrame: 0.1)
        let jump = SKAction.repeatActionForever(jumpAnim)
        
        ninja.runAction(jump)
    }
    
    func jump() {
        ninja.physicsBody?.applyImpulse(CGVectorMake(0, 100))
        playJumpAnimation()
        onGround = false
    }
    
    func playThrowAnimation() {
        let throw = SKTexture(imageNamed: "enemyThrow")
        let playThrow = SKAction.animateWithTextures([throw], timePerFrame: 0.1)
        ninja.runAction(playThrow)
    }
    
    func playDeadAnimation(frameWidth: CGFloat) {
        ninja.physicsBody?.collisionBitMask = groundCategory
        let dead = SKTexture(imageNamed: "enemyDead")
        let deadAnim = SKAction.animateWithTextures([dead], timePerFrame: 0.2)
        let died = SKAction.sequence([deadAnim, SKAction.runBlock({self.ninja.position = CGPoint(x: frameWidth + self.ninja.size.width, y: self.ninja.size.height * 2)}), SKAction.runBlock({self.fakeHealth = self.health})])
        ninja.runAction(died)
    }
    
}












