//
//  Humanoid.swift
//  Fighting Game
//
//  Created by Dylan Martin on 7/9/19.
//  Copyright © 2019 Dylan Martin. All rights reserved.
//

import GameplayKit
import SpriteKit

class Humanoid: NSObject, SKPhysicsContactDelegate {
	
	enum dir {
		case right
		case left
		case stopped
	}
	
	typealias CompletionHandler = (_ success:Bool) -> Void
	public var humanoid = SKSpriteNode()
	private var direction = dir.stopped
	private var humanoidWalkingRight: [SKTexture] = []
	private var humanoidWalkingLeft: [SKTexture] = []
	private var bitmask:UInt32 = GameScene.CollisionTypes.humanoid.rawValue
	private var weapon = Weapon()
	private var jumpCount = 0
	private var jumpActive = false
	private var animationActive = false
	private var lastX:CGFloat = CGFloat(0)
	private var health = 100
	private var inventory:[Weapon]
	private var currentInventorySlot:Int = 0
	private var lastThrown:SKSpriteNode?
	private var dirChanged = false
	private var throwActive = false
	private var defaultPB:SKPhysicsBody
	
	
	public override init() {
		
		let humanoidAnimatedAtlasLeft = SKTextureAtlas(named: "HumanoidWalkLeft.atlas")
		let humanoidAnimatedAtlasRight = SKTextureAtlas(named: "HumanoidWalkRight.atlas")
		var walkFramesLeft: [SKTexture] = []
		var walkFramesRight: [SKTexture] = []
		inventory = [Weapon(name: "Punch", damage: 35, range: 0, node: humanoid, texture: SKTexture(imageNamed: "HumanoidStopped"), textures: [SKTexture(imageNamed: "HumanoidPunchLeft"), SKTexture(imageNamed: "HumanoidPunchRight")])]
		lastThrown = nil
		
		let numImages = humanoidAnimatedAtlasLeft.textureNames.count
		for i in 2...numImages {
			let humanoidTextureNameLeft = "Humanoid\(i)"
			walkFramesLeft.append(humanoidAnimatedAtlasLeft.textureNamed(humanoidTextureNameLeft))
			
		}
		for i in 2...numImages {
			let humanoidTextureNameRight = "Humanoid\(i)"
			walkFramesRight.append(humanoidAnimatedAtlasRight.textureNamed(humanoidTextureNameRight))
			
		}
		humanoidWalkingRight = walkFramesRight
		humanoidWalkingLeft = walkFramesLeft
		
		humanoid = SKSpriteNode(imageNamed: "HumanoidStopped")
		humanoid.name = "humanoid"
		Humanoid.HumanoidDefaultPhysics(humanoid)
		
		defaultPB = SKPhysicsBody(rectangleOf: CGSize(width: 28, height: 80))
		
		let light = SKLightNode()
		light.categoryBitMask = GameScene.CollisionTypes.humanoid.rawValue
		
		light.lightColor = UIColor.white
		light.shadowColor = UIColor.black
		light.zPosition = -100
		light.position = humanoid.anchorPoint
		light.falloff = 0.0
		
		//humanoid.addChild(light)
	}
	
	func jumpHumananoid(dashActive: Bool) {
		if (Int((humanoid.physicsBody?.velocity.dy)!) == 0) {
			jumpCount = 0
		}
		
		if (jumpCount == 0) {
			jumpActive = false
		}
		if (jumpCount >= 2 && !self.jumpActive) {
			jumpCount = 0
		}
		if (!jumpActive && !dashActive) {
			humanoid.physicsBody?.velocity.dy = 1000
			jumpActive = true
			jumpCount += 1
		} else if (jumpActive && jumpCount < 2) {
			humanoid.physicsBody?.velocity.dy = 1000
			jumpCount += 1
		}
		
	}
	
	func doTheDash(_ xJoystickDelta: CGFloat, dash: Bool, complete: @escaping () -> Void) {
		var dir = 0
		if (xJoystickDelta == 0) {
			return;
		}
		humanoid.physicsBody?.contactTestBitMask = 0
		var dashAtlas = SKTextureAtlas()
		if (xJoystickDelta > 0) {
			dashAtlas = SKTextureAtlas(named: "Dash.atlas")
			dir = 1
		} else {
			dashAtlas = SKTextureAtlas(named: "DashLeft.atlas")
			dir = 0
		}
		
		var dashFrames: [SKTexture] = []
		
		let numImages = dashAtlas.textureNames.count
		for i in 1...numImages {
			let dashTextureName = "dash\(i)"
			dashFrames.append(dashAtlas.textureNamed(dashTextureName))
			
		}
		
		let dashAnimation = dashFrames
		if (dir == 1) {
			humanoid.physicsBody?.velocity.dx = 1000
		} else {
			humanoid.physicsBody?.velocity.dx = -1000
		}
		
		//let firstFrameTexture = dashAnimation[0]
		humanoid.run(SKAction.animate(with: dashAnimation, timePerFrame: 0.05), completion: {
			self.humanoid.physicsBody?.contactTestBitMask = GameScene.CollisionTypes.enemy.rawValue
			
			complete()
		})
	}
	
	func punch(direction: Int, complete: @escaping () -> Void) {
		animationActive = false
		attackAnimation(direction: direction, complete: {
			complete()
		})
	}
	
	func attackAnimation(direction: Int, complete: @escaping () -> Void) {
		weapon = inventory[currentInventorySlot]
		let temp = weapon.node
		var attack: [SKTexture] = []
		let arr = weapon.getTextureArray()
		if (direction == 0) {
			let left = arr[0]
			weapon.node = weapon.makeWeapon(left)
			attack.append(left)
		} else {
			let right = arr[1]
			weapon.node = weapon.makeWeapon(right)
			//weapon.node.xScale = weapon.node.xScale * -1
			attack.append(right)
		}
		humanoid.physicsBody = weapon.node.physicsBody!
		
		GameScene.DefaultPhysics(humanoid.physicsBody!)
		humanoid.physicsBody!.categoryBitMask = GameScene.CollisionTypes.humanoid.rawValue
		humanoid.physicsBody!.collisionBitMask = GameScene.CollisionTypes.wall.rawValue
		humanoid.physicsBody!.contactTestBitMask = GameScene.CollisionTypes.enemy.rawValue
		
		humanoid.run(SKAction.animate(with: attack, timePerFrame: 0.2, resize: false, restore: true), completion: {
			Humanoid.HumanoidDefaultPhysics(self.humanoid)
			complete()
		})
		weapon.node = temp
		
	}
	
	func shoot(direction: Int, complete: @escaping () -> Void) -> SKSpriteNode {
		Humanoid.HumanoidDefaultPhysics(humanoid)
		let obj = SKSpriteNode(imageNamed: "bullet")
		obj.name = "bullet"
		obj.physicsBody = SKPhysicsBody(rectangleOf: obj.size)
		obj.physicsBody?.angularDamping = 1
		obj.physicsBody?.isDynamic = true
		obj.physicsBody?.affectedByGravity = false
		obj.physicsBody?.allowsRotation = true
		obj.physicsBody?.collisionBitMask = GameScene.CollisionTypes.enemy.rawValue
		obj.physicsBody?.contactTestBitMask = GameScene.CollisionTypes.enemy.rawValue | GameScene.CollisionTypes.wall.rawValue
		obj.physicsBody?.categoryBitMask = GameScene.CollisionTypes.weapon.rawValue
		obj.physicsBody?.linearDamping = 0
		obj.physicsBody?.usesPreciseCollisionDetection = false
		
	
		
		if (direction == 0) {
			//obj.physicsBody?.angularVelocity = -10
			obj.position = CGPoint(x: humanoid.position.x - 35, y: humanoid.position.y + 20)
			obj.physicsBody?.velocity = (CGVector(dx: -1600, dy: 0))
		
			
		} else {
			
			//obj.physicsBody?.angularVelocity = 10
			obj.position = CGPoint(x: humanoid.position.x + 35, y: humanoid.position.y + 20)
			obj.physicsBody?.velocity = (CGVector(dx: 1600, dy: 0))
			
		}
		attackAnimation(direction: direction) {
			complete()
		}
		return obj
	}
	
	func node() -> SKSpriteNode {
		return humanoid
	}
	
	static func HumanoidDefaultPhysics(_ node: SKSpriteNode) {
		node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 28, height: 80))
		//node.physicsBody = SKPhysicsBody(bodies: pa)
		node.physicsBody!.affectedByGravity = true
		node.physicsBody!.categoryBitMask = GameScene.CollisionTypes.humanoid.rawValue
		node.physicsBody!.collisionBitMask = GameScene.CollisionTypes.wall.rawValue
		node.physicsBody!.contactTestBitMask = GameScene.CollisionTypes.enemy.rawValue
		node.physicsBody!.allowsRotation = false
		node.physicsBody!.friction = 1
		node.physicsBody!.linearDamping = 1
		node.physicsBody!.restitution = 0
	}
	
	func animateHuman(stickActive: Bool, x: CGFloat) {

		var animation:[SKTexture] = [SKTexture(imageNamed: "HumanoidStopped")]
		if (x == 0 || Int((humanoid.physicsBody?.velocity.dx)!) == 0) {
			animation[0] = SKTexture(imageNamed: "HumanoidStopped")
		} else if (x > 0) {
			animation = humanoidWalkingRight
		} else if (x < 0) {
			animation = humanoidWalkingLeft
		}
		if (x.sign != lastX.sign) {
			dirChanged = true
		}
		
		if ((stickActive && !animationActive && !throwActive) || (dirChanged && !throwActive)) {
			animationActive = true
			if (dirChanged) {
				humanoid.removeAllActions()
			}
			dirChanged = false
			lastX = x
			humanoid.run(SKAction.animate(with: animation, timePerFrame: TimeInterval(0.1)), completion: {
				self.animationActive = false
			})
		} else if (!stickActive && !throwActive && !animationActive) {
			//print("NO")
			humanoid.removeAllActions()
			humanoid.texture = SKTexture(imageNamed: "HumanoidStopped")
		}
	}
	
	func move(_ xJoystickDelta: Double) {
		if (throwActive) {
			var pb = SKSpriteNode()
			let right = SKTexture(imageNamed: "ArmRight")
			let left = SKTexture(imageNamed: "ArmLeft")
			if (xJoystickDelta > 0) {
				humanoid.texture = SKTexture(imageNamed: "ThrowRight")
				pb = SKSpriteNode(texture: right)
				pb.physicsBody = SKPhysicsBody(texture: right, size: right.size())
			} else if (xJoystickDelta < 0) {
				humanoid.texture = SKTexture(imageNamed: "ThrowLeft")
				pb = SKSpriteNode(texture: left)
				pb.physicsBody = SKPhysicsBody(texture: left, size: left.size())
			}
			return
		}
		//print(humanoid.physicsBody?.velocity.dy)
		let maxSpeed = 750
		let xScale = 3.5 //adjust to your preference
		//let yScale = 3.5
		
		if (xJoystickDelta < 0) {
			direction = dir.left
		}
		if (xJoystickDelta > 0) {
			direction = dir.right
		}
		var xAdd = xScale * Double(xJoystickDelta)
		//var yAdd = yScale * Double(yJoystickDelta)
		
		let r:Double = 70.0 // base.size.width / 2
		
		if (xJoystickDelta < -r) {
			xAdd = xScale * Double(-r)
		}
		if (xJoystickDelta > r) {
			xAdd = xScale * Double(r)
		}
		if ((humanoid.physicsBody?.velocity.dx)! > CGFloat(maxSpeed) || (humanoid.physicsBody?.velocity.dx)! < CGFloat(-maxSpeed)) {
			return
		}
		humanoid.physicsBody?.applyForce(CGVector(dx: xAdd, dy: 0))
	}
	
	func beforeThrow() {
		if (currentInventorySlot == 0) {
			return
		}
		throwActive = true
		humanoid.removeAllActions()
		var pb = SKSpriteNode()
		let right = SKTexture(imageNamed: "ArmRight")
		let left = SKTexture(imageNamed: "ArmLeft")
		if (direction == dir.right) {
			humanoid.texture = SKTexture(imageNamed: "ThrowRight")
			pb = SKSpriteNode(texture: right)
			pb.physicsBody = SKPhysicsBody(texture: right, size: right.size())
			
		} else if (direction == dir.left) {
			humanoid.texture = SKTexture(imageNamed: "ThrowLeft")
			pb = SKSpriteNode(texture: left)
			pb.physicsBody = SKPhysicsBody(texture: left, size: left.size())
			
		} else {
			humanoid.texture = SKTexture(imageNamed: "ThrowRight")
			pb = SKSpriteNode(texture: right)
			pb.physicsBody = SKPhysicsBody(texture: right, size: right.size())
		}
	}
	
	func throwObject(obj: SKSpriteNode, x: CGFloat, y: CGFloat) -> SKSpriteNode? {
		if (currentInventorySlot == 0) {
			throwActive = false
			return nil
		}
		throwActive = false
		animationActive = false
		Humanoid.HumanoidDefaultPhysics(humanoid)
		
		inventory.remove(at: currentInventorySlot)
		currentInventorySlot = currentInventorySlot - 1
		obj.physicsBody?.angularDamping = 1
		obj.physicsBody?.allowsRotation = true
		obj.physicsBody?.collisionBitMask = GameScene.CollisionTypes.enemy.rawValue
		obj.physicsBody?.contactTestBitMask = GameScene.CollisionTypes.enemy.rawValue | GameScene.CollisionTypes.humanoid.rawValue
		obj.physicsBody?.categoryBitMask = GameScene.CollisionTypes.weapon.rawValue
		obj.physicsBody?.friction = 1
		obj.physicsBody?.linearDamping = 0
		
		lastThrown = obj
		let scale = 10
		var xAdd = x * CGFloat(scale)
		var yAdd = y * CGFloat(scale)
		if (xAdd > 1300) {
			xAdd = 1300
		} else if (xAdd < -1300) {
			xAdd = -1300
		}
		if (yAdd > 1300) {
			yAdd = 1300
		} else if (yAdd < -1300) {
			yAdd = 1300
		}
		
		print("x", xAdd)
		print("y", yAdd)

		
		if (direction == dir.right) {
			//humanoid.addChild(obj)
			obj.physicsBody?.velocity = (CGVector(dx: humanoid.physicsBody!.velocity.dx + xAdd, dy: humanoid.physicsBody!.velocity.dy + yAdd))
			obj.physicsBody?.angularVelocity = -10
			obj.position = CGPoint(x: humanoid.position.x, y: humanoid.position.y + 60)
			
			humanoid.texture = SKTexture(imageNamed: "ThrowBodyRight")
			
		} else {
			obj.physicsBody?.velocity = (CGVector(dx: humanoid.physicsBody!.velocity.dx + xAdd, dy: humanoid.physicsBody!.velocity.dy + yAdd))
			obj.physicsBody?.angularVelocity = 10
			obj.position = CGPoint(x: humanoid.position.x, y: humanoid.position.y + 60)
			
			humanoid.texture = SKTexture(imageNamed: "ThrowBodyLeft")
		}
		
		
		return obj
	}
	
	func lastWeaponThrown() -> SKSpriteNode? {
		if (lastThrown == nil) {
			return nil
		}
		return lastThrown
	}
	
	func cancelThrow() {
		throwActive = false
		Humanoid.HumanoidDefaultPhysics(humanoid)
	}
	
	func add(weapon: Weapon) {
		inventory.append(weapon)
	}
	
	func getBitmask() -> UInt32 {
		return bitmask
	}
	
	func getWeapon() -> Weapon {
		return inventory[currentInventorySlot]
	}
	
	func setWeapon(weapon: Weapon) {
		self.weapon = weapon
	}
	
	func setNode(node: SKSpriteNode) {
		self.humanoid = node
	}
	
	func getHealth() -> Int {
		return health
	}
	
	func setHealth(_ hp: Int) {
		health = hp
	}
	
	func setInventory(_ arr: [Weapon]) {
		inventory = arr
		currentInventorySlot = 0
		
	}
	
	func getInventory() -> [Weapon] {
		return inventory
	}
	
	// 0 to get index any other number to make the index shift by x
	func inventoryIndex() -> Int {
		return currentInventorySlot
	}
	
	func invIncrease() {
		if (currentInventorySlot + 1 > inventory.count - 1) {
			currentInventorySlot = 0
		} else {
			currentInventorySlot += 1
		}
	}
	
	func invDecrease() {
		if (currentInventorySlot == 0) {
			currentInventorySlot = inventory.count - 1
		} else {
			currentInventorySlot -= 1
		}
	}
	
	func setThrow(_ bool: Bool) {
		throwActive = bool
	}
}

