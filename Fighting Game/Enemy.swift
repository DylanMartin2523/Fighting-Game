//
//  Enemy.swift
//  Fighting Game
//
//  Created by Dylan Martin on 7/4/19.
//  Copyright © 2019 Dylan Martin. All rights reserved.
//

import GameplayKit
import SpriteKit

class Enemy: NSObject, SKPhysicsContactDelegate {
	
	typealias CompletionHandler = (_ success:Bool) -> Void
	public var name = String()
	private var health 	= Int()
	private var bitmask:UInt32 = GameScene.CollisionTypes.enemy.rawValue
	public var node:SKSpriteNode
	private var nodeArray:[SKSpriteNode]
	private var target:SKSpriteNode
	private var targetSet = false
	private let speed = 163.33
	private var weapon = Weapon()
	public var punchActive = false
	public var punchDetected = false
	private var animationActive = false
	public var windUpActive = false
	private var type = enemyType.melee
	
	public enum enemyType {
		case ranged
		case melee
	}
	
	public init(name: String, health: Int, target: SKSpriteNode, type: enemyType) {
		self.name = name
		self.health = health
		self.target = target
		self.nodeArray = []
		self.node = SKSpriteNode(imageNamed: "HumanoidStopped")
		self.node.name = name

		self.node.shadowedBitMask = 1
		self.node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 28, height: 80))
		self.node.physicsBody?.collisionBitMask = GameScene.CollisionTypes.wall.rawValue
		self.node.physicsBody?.categoryBitMask = bitmask
		self.node.zPosition = -101
		self.node.physicsBody?.allowsRotation = false
		self.type = type
		
		//self.node.physicsBody?.contactTestBitMask = GameScene.CollisionTypes.humanoid.rawValue
		GameScene.DefaultPhysics(self.node.physicsBody!)
	}
	
	func move() {
		if (!targetSet) {
			return
		}
		
		var distance:float_t = 0.0
		if (type == .melee) {
			distance = 70.0
		} else {
			distance = 140.0
		}
		
		
		let dist = hypotf(Float(target.position.x - node.position.x), Float(target.position.y - node.position.y))
		
		if (dist < 500 && !punchActive) {
			//print(dist)
			let xDist = node.position.x - target.position.x
			var velo = node.physicsBody?.velocity
			
			if (xDist < 0) { // Negative means to the right
				if (!animationActive && dist > distance) {
					animationActive = true
					animateHuman(x: 0)
				}
				
				if (!punchActive && !punchDetected && !animationActive) {
					animationActive = true
					punch(direction: 1) {
						self.defaultPhysics()
						self.animationActive = false
						self.punchActive = false
					}
				}
				if (dist < 50) {
					velo = CGVector(dx: 0, dy: 0)
				} else if (velo!.dx > CGFloat(speed)) {
					velo!.dx = CGFloat(speed)
					
				} else if (!windUpActive) {
					node.physicsBody?.applyForce(CGVector(dx: speed, dy: 0.0))
				}
				
			} else if (xDist > 0) {
				if (!animationActive && dist > distance) {
					self.animationActive = true
					self.animateHuman(x: 1)
				}
				
				if (!punchActive && !punchDetected && !animationActive) {
					animationActive = true
					punch(direction: 0) {
						self.defaultPhysics()
						self.animationActive = false
						self.punchActive = false
					}
				}
				if (dist < 50) {
					velo = CGVector(dx: 0, dy: 0)
				} else if (velo!.dx < CGFloat(-speed)) {
					velo!.dx = CGFloat(-speed)
					
				} else if (!windUpActive) {
					node.physicsBody?.applyForce(CGVector(dx: -speed, dy: 0.0))
				}
			}
		}
	}
	
	func kill() {
		let leftLeg = SKSpriteNode(imageNamed: "Leg")
		let rightLeg = SKSpriteNode(imageNamed: "Leg")
		let leftArm = SKSpriteNode(imageNamed: "Arm")
		let rightArm = SKSpriteNode(imageNamed: "Arm")
		let head = SKSpriteNode(imageNamed: "head")
		let torso = SKSpriteNode(imageNamed: "Torso")
		GameScene.DefaultPhysics(leftLeg.physicsBody!)
		GameScene.DefaultPhysics(rightLeg.physicsBody!)
		GameScene.DefaultPhysics(leftArm.physicsBody!)
		GameScene.DefaultPhysics(rightArm.physicsBody!)
		GameScene.DefaultPhysics(head.physicsBody!)
		GameScene.DefaultPhysics(torso.physicsBody!)
	}
	
	// 0 right 1 left
	func punch(direction: Int, complete: @escaping () -> Void) {
		
		var windUpTime:TimeInterval
		var windUpTextureLeft:SKTexture
		var windUpTextureRight:SKTexture
		var attackTextureLeft:SKTexture
		var attackTextureRight:SKTexture
		
		if (type == .melee) {
			weapon = Weapon(name: "punch", damage: 35, range: 0, node: node, texture: SKTexture(imageNamed: "HumanoidStopped"), textures: [SKTexture(imageNamed: "HumanoidPunchLeft"), SKTexture(imageNamed: "HumanoidPunchRight")])
			weapon.name = "punch"
			
			windUpTime = TimeInterval(0.5)
			
			windUpTextureLeft = SKTexture(imageNamed: "PunchWindUpLeft")
			windUpTextureRight = SKTexture(imageNamed: "PunchWindUpRight")
			attackTextureLeft = SKTexture(imageNamed: "HumanoidPunchLeft")
			attackTextureRight = SKTexture(imageNamed: "HumanoidPunchRight")
		} else {
			weapon = Weapon(name: "pistol", damage: 20, range: 50, node: node, texture: SKTexture(imageNamed: "HumanoidStopped"), textures: [SKTexture(imageNamed: "HumanoidPistolLeft"), SKTexture(imageNamed: "HumanoidPistolRight")])
			weapon.name = "pistol"
			
			windUpTime = TimeInterval(1.0)
			
			windUpTextureLeft = SKTexture(imageNamed: "ShootWindUpLeft")
			windUpTextureRight = SKTexture(imageNamed: "ShootWindUpRight")
			attackTextureLeft = SKTexture(imageNamed: "HumanoidPistolLeft")
			attackTextureRight = SKTexture(imageNamed: "HumanoidPistolRight")
		}
		
		var weap = SKSpriteNode(texture: SKTexture(imageNamed: "HumanoidStopped"))
		node.physicsBody!.categoryBitMask = GameScene.CollisionTypes.enemy.rawValue
		node.physicsBody!.collisionBitMask = GameScene.CollisionTypes.wall.rawValue
		node.physicsBody!.contactTestBitMask = GameScene.CollisionTypes.humanoid.rawValue
		
		var attack: [SKTexture] = []
		var windUp: [SKTexture] = []
		
		if (direction == 0) {
			let left = attackTextureLeft
			weap = weapon.makeWeapon(left)
			windUp.append(windUpTextureLeft)
			attack.append(left)
			
		} else {
			let right = attackTextureRight
			weap = weapon.makeWeapon(right)
			windUp.append(windUpTextureRight)
			attack.append(right)
		}
		
		
		
		windUpActive = true
		node.run(SKAction.animate(with: windUp, timePerFrame: windUpTime, resize: false, restore: true), completion: {
			self.node.physicsBody = weap.physicsBody
			//GameScene.DefaultPhysics(self.node.physicsBody!)
			self.node.physicsBody!.categoryBitMask = GameScene.CollisionTypes.enemy.rawValue
			self.node.physicsBody!.collisionBitMask = GameScene.CollisionTypes.wall.rawValue | GameScene.CollisionTypes.enemy.rawValue
			self.node.physicsBody!.contactTestBitMask = GameScene.CollisionTypes.humanoid.rawValue
			self.punchActive = true
			self.windUpActive = false
			self.node.run(SKAction.animate(with: attack, timePerFrame: 0.2, resize: false, restore: true), completion: {
				self.node.texture = SKTexture(imageNamed: "HumanoidStopped")
				self.punchDetected = false
				if (self.type == .ranged) {
					let bullet = self.shoot(direction: direction, complete: {})
					self.node.parent?.addChild(bullet)
				}
				complete()
			})
		})
	}
	
	func shoot(direction: Int, complete: @escaping () -> Void) -> SKSpriteNode {
		//Humanoid.HumanoidDefaultPhysics(node)
		let obj = SKSpriteNode(imageNamed: "bullet")
		obj.name = "bulletEnemy"
		obj.physicsBody = SKPhysicsBody(rectangleOf: obj.size)
		obj.physicsBody?.angularDamping = 1
		obj.physicsBody?.isDynamic = true
		obj.physicsBody?.affectedByGravity = false
		obj.physicsBody?.allowsRotation = true
		obj.physicsBody?.collisionBitMask = GameScene.CollisionTypes.humanoid.rawValue
		obj.physicsBody?.contactTestBitMask = GameScene.CollisionTypes.humanoid.rawValue | GameScene.CollisionTypes.wall.rawValue
		obj.physicsBody?.categoryBitMask = GameScene.CollisionTypes.weapon.rawValue
		obj.physicsBody?.linearDamping = 0
		obj.physicsBody?.usesPreciseCollisionDetection = false
		
	
		
		if (direction == 0) {
			//obj.physicsBody?.angularVelocity = -10
			obj.position = CGPoint(x: node.position.x - 35, y: node.position.y + 20)
			obj.physicsBody?.velocity = (CGVector(dx: -1600, dy: 0))
		
			
		} else {
			
			//obj.physicsBody?.angularVelocity = 10
			obj.position = CGPoint(x: node.position.x + 35, y: node.position.y + 20)
			obj.physicsBody?.velocity = (CGVector(dx: 1600, dy: 0))
			
		}
		return obj
	}
	
	func defaultPhysics() {
		//self.node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 45, height: 78))
		self.node.texture = SKTexture(imageNamed: "HumanoidStopped")
		//let pa = [SKPhysicsBody(circleOfRadius: CGFloat(6.5), center: CGPoint(x: node.anchorPoint.x, y: node.anchorPoint.y + 30.0)),
//				  SKPhysicsBody(rectangleOf: CGSize(width: 28, height: 33), center: CGPoint(x: node.anchorPoint.x, y: node.anchorPoint.y + 7.0)),
//				  SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 31), center: CGPoint(x: node.anchorPoint.x, y: node.anchorPoint.y - 27.0))]
		self.node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 28, height: 80))
		//self.node.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "HumanoidStopped"), size: SKTexture(imageNamed: "HumanoidStopped").size())
		self.node.physicsBody?.collisionBitMask = GameScene.CollisionTypes.wall.rawValue
		self.node.physicsBody?.categoryBitMask = bitmask
		self.node.physicsBody!.contactTestBitMask = GameScene.CollisionTypes.humanoid.rawValue
		GameScene.DefaultPhysics(self.node.physicsBody!)
	}
	
	//
	func animateHuman(x: Int) {
		let humanoidAnimatedAtlasLeft = SKTextureAtlas(named: "HumanoidWalkLeft.atlas")
		let humanoidAnimatedAtlasRight = SKTextureAtlas(named: "HumanoidWalkRight.atlas")
		var walkFramesLeft: [SKTexture] = []
		var walkFramesRight: [SKTexture] = []
		
		let numImages = humanoidAnimatedAtlasLeft.textureNames.count
		
		
		
		var animation:[SKTexture] = []
		if (x == 0) {
			for i in 2...numImages {
				let humanoidTextureNameRight = "Humanoid\(i)"
				walkFramesRight.append(humanoidAnimatedAtlasRight.textureNamed(humanoidTextureNameRight))
				
			}
			animation = walkFramesRight
		} else if (x == 1) {
			for i in 2...numImages {
				let humanoidTextureNameLeft = "Humanoid\(i)"
				walkFramesLeft.append(humanoidAnimatedAtlasLeft.textureNamed(humanoidTextureNameLeft))
				
			}
			animation = walkFramesLeft
		}
		node.run(SKAction.animate(with: animation, timePerFrame: 0.1, resize: false, restore: false), completion: {
			self.animationActive = false
		})
		
	}
	
	func getWeapon() -> Weapon {
		return weapon
	}
	
	func setTarget(_ node: SKSpriteNode) {
		targetSet = true
		target = node
	}
	
	func getTarget() -> SKSpriteNode {
		return target
	}
	
	func getName() -> String {
		return name
	}
	
	func getHealth() -> Int {
		return health
	}
	
	func getNodeArray() -> [SKSpriteNode] {
		return nodeArray
	}
	
	func getBitmask() -> UInt32 {
		return bitmask
	}
	
	func setHealth(_ hp: Int) {
		health = hp
	}
	
}

