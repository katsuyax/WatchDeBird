//
//  GameScene.swift
//  WatchDeBird
//
//  Created by Katsuya Kato on 2016/12/04.
//  Copyright © 2016年 CrossBridge. All rights reserved.
//

import UIKit
import SpriteKit
import WatchKit

class GameScene: SKScene {
    
    enum CollisionCategory: UInt32 {
        case bird   = 0b0001
        case ground = 0b0010
        case wall   = 0b0100
        case score  = 0b1000
    }
    
    let birdSize: CGFloat = 15.0
    let wallWidth: CGFloat = 15.0
    let wallHeight: CGFloat = 100.0
    let impulse: CGFloat = 1.3
    
    var birdNode: SKSpriteNode?
    var groundNode: SKSpriteNode?
    var scrollNode: SKSpriteNode?
    var wallNode: SKSpriteNode?
    var scoreLabelNode: SKLabelNode?
    
    var score = 0
    
    override func sceneDidLoad() {
        
        backgroundColor = UIColor.cyan
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        physicsWorld.contactDelegate = self
        
        scrollNode = SKSpriteNode()
        if let scrollNode = scrollNode {
            addChild(scrollNode)
        }
        
        setupBird()
        setupGround()
        setupWall()
        setupScoreLabel()
    }
    
    func setupBird() {
        let birdTexture = SKTexture(imageNamed: "bird")
        birdTexture.filteringMode = SKTextureFilteringMode.linear
        birdNode = SKSpriteNode(texture: birdTexture)
        
        if let birdNode = birdNode {
            birdNode.size = CGSize(width: birdSize, height: birdSize)
            birdNode.position = CGPoint(x: frame.size.width * 0.15,
                                        y: frame.size.height * 0.7)
            
            birdNode.physicsBody = SKPhysicsBody(circleOfRadius: birdNode.size.height / 2.0)
            birdNode.physicsBody?.allowsRotation = false
            birdNode.physicsBody?.categoryBitMask = CollisionCategory.bird.rawValue
            birdNode.physicsBody?.collisionBitMask = CollisionCategory.ground.rawValue | CollisionCategory.wall.rawValue
            birdNode.physicsBody?.contactTestBitMask = CollisionCategory.ground.rawValue | CollisionCategory.wall.rawValue
            
            addChild(birdNode)
        }
    }
    
    func setupGround() {
        groundNode = SKSpriteNode(color: UIColor.brown,
                                  size: CGSize(width: frame.width, height: 10))
        if let groundNode = groundNode {
            groundNode.position =  CGPoint(x: frame.width / 2, y: groundNode.size.height / 2)
            
            groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
            groundNode.physicsBody?.categoryBitMask = CollisionCategory.ground.rawValue
            groundNode.physicsBody?.isDynamic = false
            
            addChild(groundNode)
        }
    }
    
    func setupWall() {
        wallNode = SKSpriteNode()
        if let wallNode = wallNode {
            scrollNode?.addChild(wallNode)
        }
        
        let movingDistance = CGFloat(frame.size.width + wallWidth)
        let moveWall = SKAction.moveBy(x: -movingDistance,
                                       y: 0,
                                       duration: 4.0)
        let removeWall = SKAction.removeFromParent()
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        let randomRange = frame.size.height / 4
        let clearance = self.frame.size.height / 2.5
        
        let createWallAnimation = SKAction.run({
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + self.wallWidth / 2,
                                    y: 0.0)
            wall.zPosition = -10.0
            
            let underWallYPositon = CGFloat(UInt32(self.frame.size.height / 2 - self.wallHeight / 2 - randomRange / 2)
                + arc4random_uniform(UInt32(randomRange)))
            
            let under = SKSpriteNode(color: UIColor.gray,
                                     size: CGSize(width: self.wallWidth,
                                                  height: self.wallHeight))
            under.position = CGPoint(x: 0.0, y: underWallYPositon)
            under.physicsBody = SKPhysicsBody(rectangleOf: under.size)
            under.physicsBody?.categoryBitMask = CollisionCategory.wall.rawValue
            under.physicsBody?.isDynamic = false
            wall.addChild(under)
            
            let upper = SKSpriteNode(color: UIColor.gray,
                                     size: CGSize(width: self.wallWidth, height: self.wallHeight))
            upper.position = CGPoint(x: 0.0, y: underWallYPositon + self.wallHeight + clearance)
            upper.physicsBody = SKPhysicsBody(rectangleOf: upper.size)
            upper.physicsBody?.categoryBitMask = CollisionCategory.wall.rawValue
            upper.physicsBody?.isDynamic = false
            wall.addChild(upper)
            
            let scoreNode = SKNode()
            if let birdNode = self.birdNode {
                scoreNode.position = CGPoint(x: upper.size.width + birdNode.size.width / 2,
                                             y: self.frame.height / 2.0)
            }
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width,
                                                                      height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = CollisionCategory.score.rawValue
            scoreNode.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            
            self.wallNode?.addChild(wall)
        })
        
        let waitAnimation = SKAction.wait(forDuration: 2)
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode?.run(repeatForeverAnimation)
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        if let scoreLabelNode = scoreLabelNode {
            scoreLabelNode.fontSize = 10
            scoreLabelNode.fontColor = UIColor.black
            scoreLabelNode.position = CGPoint(x: 5, y: frame.size.height - 10)
            scoreLabelNode.zPosition = 100
            scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            scoreLabelNode.text = "Score:\(score)"
            addChild(scoreLabelNode)
        }
    }
    
    func didTap(_ recognizer: WKTapGestureRecognizer) {
        if let birdNode = birdNode, let scrollSpeed = scrollNode?.speed {
            if scrollSpeed > CGFloat(0.0) {
                birdNode.physicsBody?.velocity = CGVector.zero
                birdNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: impulse))
            } else if scrollSpeed == 0 && birdNode.speed == 0{
                restart()
            }
        }
    }
    
    func restart() {
        score = 0
        scoreLabelNode?.text = String("Score:\(score)")
        
        birdNode?.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        birdNode?.physicsBody?.velocity = CGVector.zero
        birdNode?.physicsBody?.collisionBitMask = CollisionCategory.ground.rawValue | CollisionCategory.wall.rawValue
        birdNode?.zRotation = 0.0

        wallNode?.removeAllChildren()
        
        birdNode?.speed = 1
        scrollNode?.speed = 1
    }
}

extension GameScene: SKPhysicsContactDelegate {
    public func didBegin(_ contact: SKPhysicsContact) {
        guard let scrollNode = scrollNode,
            let scoreLabelNode = scoreLabelNode,
            let birdNode = birdNode else {
            return
        }
        
        guard scrollNode.speed > 0 else {
            return
        }

        if (contact.bodyA.categoryBitMask & CollisionCategory.score.rawValue) == CollisionCategory.score.rawValue
            || (contact.bodyB.categoryBitMask & CollisionCategory.score.rawValue) == CollisionCategory.score.rawValue {
            score += 1
            scoreLabelNode.text = "Score:\(score)"
        } else {
            scrollNode.speed = 0
            
            birdNode.physicsBody?.collisionBitMask = CollisionCategory.ground.rawValue
            
            let roll = SKAction.rotate(byAngle: CGFloat(M_PI) * CGFloat(birdNode.position.y) * 0.01, duration:1)
            birdNode.run(roll, completion:{
                birdNode.speed = 0
            })
        }
    }
}
