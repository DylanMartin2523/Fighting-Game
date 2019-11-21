//
//  GameScene.swift
//  Fighting Game
//
//  Created by Dylan Martin on 6/29/19.
//  Copyright © 2019 Dylan Martin. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreGraphics

class GameScene: SKScene, SKPhysicsContactDelegate{
	
	public enum CollisionTypes: UInt32 {
		case humanoid = 1
		case wall = 2
		case enemy = 4
		case weapon = 8
	}
	
	private enum Err: Error {
		case null
	}
	
	public var humanoid = Humanoid()
	public var enemyArray:[Enemy] = []
	private var weaponDict:[SKSpriteNode? : Weapon] = [:]
	private var stickActive = false
	private var xJoystickDelta = CGFloat()
	private var yJoystickDelta = CGFloat()
	private var joyTouch = UITouch()
	private var nonJoy = UITouch()
	private var invLeft = SKSpriteNode(imageNamed: "InvArrowLeft")
	private var invRight = SKSpriteNode(imageNamed: "InvArrowRight")
	private var isPunch = false
	private let cam = SKCameraNode()
	private let dummyNode = SKSpriteNode()
	private let tiles = SKTileSet()
	private var dummyStick = SKSpriteNode()
	private var base = SKSpriteNode()
	private var stick = SKSpriteNode()
	private var leftPunch = SKSpriteNode()
	private var rightPunch = SKSpriteNode()
	private var jump = SKSpriteNode()
	private var dash = SKSpriteNode()
	private var jumpActive = false
	private var dashActive = false
	private var throwButton = SKSpriteNode()
	private var throwActive = false
	private var punchDetected = false
	private var currItem = SKLabelNode()
	private var throwHelper = SKSpriteNode()
	private var toFade:SKSpriteNode = SKSpriteNode()
	private var handleFade:SKNode = SKNode()
	private var invLabel:SKLabelNode = SKLabelNode(text: "Current Weapon:")
	private var weaponLabel:SKLabelNode = SKLabelNode(text: "Punch")
	private var invLabelPos:CGPoint = CGPoint(x: 0, y: 0)
	
    
    override func didMove(to view: SKView) {
	
		self.scene!.view?.showsPhysics = true
		self.physicsWorld.speed = 0.75
		physicsWorld.contactDelegate = self
		self.camera = cam
		dummyNode.name = "camNode"
		addChild(cam)
		cam.xScale = 0.9
		cam.yScale = 0.9
		
		
		
		let gun = Weapon(name: "gun", damage: 20, range: 60, node: SKSpriteNode(imageNamed: "Pistol"), texture: SKTexture(imageNamed: "Pistol"), textures: [SKTexture(imageNamed: "HumanoidPistolLeft"), SKTexture(imageNamed: "HumanoidPistolRight")])
		//gun.node.position = CGPoint(x: -150, y: -520)
		//self.addChild(gun.node)
		
		weaponDict[gun.node] = gun
		humanoid.setInventory([humanoid.getWeapon(), gun])
		
		let dagger = Weapon(name: "dagger", damage: 40, range: 0, node: SKSpriteNode(imageNamed: "dagger"), texture: SKTexture(imageNamed: "dagger"),textures: [SKTexture(imageNamed: "HumanoidDaggerLeft"), SKTexture(imageNamed: "HumanoidDaggerRight")])
		dagger.node.position = CGPoint(x: -150, y: -520)
		self.addChild(dagger.node)
		weaponDict.updateValue(dagger, forKey: dagger.node)
		
		
		weaponLabel.position = CGPoint(x: -180, y: 525)
		cam.addChild(weaponLabel)
		
		invLabel.position = CGPoint(x: -180, y: 575)
		invLabelPos = invLabel.position
		cam.addChild(invLabel)
		displayInventory()
		cam.addChild(dummyNode)
		
		invLeft.name = "invLeft"
		invLeft.position = CGPoint(x: -30, y: 525)
		cam.addChild(invLeft)
		
		invLeft.name = "invLeft"
		invRight.position = CGPoint(x: 25, y: 525)
		cam.addChild(invRight)

		humanoid.node().position = CGPoint(x: -162.887, y: -579.131)
		addChild(humanoid.node())
		
//        let enemy = Enemy(name: "e1", health: 100, target: humanoid.node())
//        enemy.setTarget(humanoid.node())
//        enemy.node.position = CGPoint(x: -150, y: -520)
//        enemyArray.append(enemy)
//        enemy.setTarget(humanoid.node())
//
//        for i in enemyArray {
//            addChild(i.node)
//        }
        
//        addEnemyMelee(pos: CGPoint(x: 1673.362, y: -626.821))
//        addEnemyMelee(pos: CGPoint(x: 999.82, y: 119.821))
//		addEnemyMelee(pos: CGPoint(x: 39.82, y: 119.821))
//		addEnemyMelee(pos: CGPoint(x: 160, y: 833.707))
//		addEnemyMelee(pos: CGPoint(x: 625.18, y: 833.707))
//		addEnemyMelee(pos: CGPoint(x: 415.179, y: 833.707))
//		addEnemyMelee(pos: CGPoint(x: 1080.178, y: 833.707))
		
		addEnemyRanged(pos: CGPoint(x: 1673.362, y: -626.821))
        addEnemyRanged(pos: CGPoint(x: 999.82, y: 119.821))
		addEnemyRanged(pos: CGPoint(x: 39.82, y: 119.821))
		addEnemyRanged(pos: CGPoint(x: 160, y: 833.707))
		addEnemyRanged(pos: CGPoint(x: 625.18, y: 833.707))
		addEnemyRanged(pos: CGPoint(x: 415.179, y: 833.707))
		addEnemyRanged(pos: CGPoint(x: 1080.178, y: 833.707))
		
		
		
		
		let elevator = childNode(withName: "elevator")
		let eleCon = SKConstraint.positionX(SKRange(lowerLimit: (elevator?.position.x)!))
		elevator?.constraints = [eleCon]
		
		
		// Code for JoyStick
		base = SKSpriteNode(imageNamed: "Base.png")
		base.position = CGPoint(x:  -125, y: -500)
		base.name = "base"
		base.zPosition = 2
		cam.addChild(base)
		
		stick = SKSpriteNode(imageNamed: "Stick.png")
		stick.name = "stick"
		stick.position = CGPoint(x: -125, y: -500)
		stick.zPosition = 3
		
		cam.addChild(stick)
		
		//dummyStick = SKSpriteNode(imageNamed: "LeftButton")
		dummyStick.position = CGPoint(x: -190, y: -500)
		dummyStick.size = CGSize(width: 200, height: 200)
		cam.addChild(dummyStick)
		
		
		//Punching Buttons
		leftPunch = SKSpriteNode(imageNamed: "LeftButton")
		leftPunch.name = "leftPunch"
		leftPunch.position = CGPoint(x: 100, y: -500)
		leftPunch.zPosition = 2
		cam.addChild(leftPunch)
		
		rightPunch = SKSpriteNode(imageNamed: "RightButton")
		rightPunch.name = "rightPunch"
		rightPunch.position = CGPoint(x: 200, y: -500)
		rightPunch.zPosition = 2
		cam.addChild(rightPunch)
		
		//Jump and Dash
		jump = SKSpriteNode(imageNamed: "JumpButton")
		jump.name = "jump"
		jump.position = CGPoint(x: 150, y: -400)
		jump.zPosition = 2
		cam.addChild(jump)
		
		dash = SKSpriteNode(imageNamed: "DashButton")
		dash.name = "leftPunch"
		dash.position = CGPoint(x: 250, y: -400)
		dash.zPosition = 2
		cam.addChild(dash)
		
		// Throwing
		throwButton = SKSpriteNode(imageNamed: "ThrowButton")
		throwButton.name = "throwButton"
		throwButton.position = CGPoint(x: 200, y: -300)
		throwButton.zPosition = 2
		cam.addChild(throwButton)
		
		throwHelper.name = "throwHelper"
		throwHelper.position = CGPoint(x: 200, y: -300)
		cam.addChild(throwHelper)
		
	
    }
	
	
	
    
    func touchDown(atPoint pos : CGPoint) {
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
	}
    
    func touchUp(atPoint pos : CGPoint) {
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		let enemy = enemyArray[0].node.position
		hypotf(Float(humanoid.node().position.x - enemy.x), Float(humanoid.node().position.y - enemy.y))
		for touch in touches {
			let location = touch.location(in: self)
			
			//print(location)
			let objects = nodes(at: location)
			if (objects.contains(stick)) {
				stickActive = true
				joyTouch = touch
			} else if (!stickActive){
				nonJoy = touch
			}
			
			if (!isPunch && !dashActive) {
				if (objects.contains(leftPunch)) {
					isPunch = true
					if (humanoid.getWeapon().getType() == .ranged) {
						let bullet = humanoid.shoot(direction: 0) {
							self.isPunch = false
							self.punchDetected = false
						}
						let gunSmoke = SKEmitterNode(fileNamed: "fireLeft.sks")
						gunSmoke?.position = CGPoint(x: bullet.position.x - 10, y: bullet.position.y)
						addChild(gunSmoke!)
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
							gunSmoke?.removeFromParent()
						}
						addChild(bullet)
					} else {
						humanoid.punch(direction: 0, complete: {
							self.isPunch = false
							self.punchDetected = false
						})
					}
				}
				
				if (objects.contains(rightPunch)) {
					isPunch = true
					if (humanoid.getWeapon().getType() == .ranged) {
						let bullet = humanoid.shoot(direction: 1) {
							self.isPunch = false
							self.punchDetected = false
						}
						bullet.physicsBody?.velocity = CGVector(dx: 1000, dy: 0)
						let gunSmoke = SKEmitterNode(fileNamed: "fireRight.sks")
						gunSmoke?.position = CGPoint(x: bullet.position.x + 10, y: bullet.position.y)
						addChild(gunSmoke!)
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
							gunSmoke?.removeFromParent()
						}
						addChild(bullet)
						
						
					} else {
						humanoid.punch(direction: 1, complete: {
							self.isPunch = false
							self.punchDetected = false
						})
					}
				}
					
			}
			
			if (objects.contains(jump)) {
				humanoid.jumpHumananoid(dashActive: dashActive)
			}
			
			if (!dashActive && stickActive)  {
				if (objects.contains(dash)) {
					dashActive = true
					humanoid.doTheDash(xJoystickDelta, dash: dashActive, complete: {
						self.dashActive = false
					})
				}
			}
			
			if (!isPunch && !dashActive) {
				if (objects.contains(throwButton)) {
					humanoid.beforeThrow()
				}
			}
			if (!isPunch) {
				if (objects.contains(invLeft)) {
					//if (humanoid.inventoryIndex() != 0) {
						humanoid.invDecrease()
					//}
					displayInventory()
				}
				if (objects.contains(invRight)) {
					if (humanoid.inventoryIndex() < humanoid.getInventory().count) {
						humanoid.invIncrease()
					}
					displayInventory()
				}
			}
		}
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: cam)
			//print("moved")

			if stickActive && touch == joyTouch {
				xJoystickDelta = location.x - base.position.x
				yJoystickDelta = location.y - base.position.y
				let v = CGVector(dx: xJoystickDelta, dy: yJoystickDelta)
				let angle = atan2(v.dy, v.dx)

				let length: CGFloat = base.frame.size.height / 2

				let xDist: CGFloat = sin(angle - 1.57079633) * length
				let yDist: CGFloat = cos(angle - 1.57079633) * length
				
				dummyStick.position = location
				if base.contains(location) {
					stick.position = location
				} else {
					stick.position = CGPoint(x: base.position.x - xDist, y: base.position.y + yDist)
				}
			}
		}
	}
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			let location = t.location(in: self)
			let objects = nodes(at: location)
			if (objects.contains(dummyStick)) {
				stickActive = false
				xJoystickDelta = 0
				yJoystickDelta = 0
				stick.position = (base.position)
				dummyStick.position = (base.position)
			}
			if (objects.contains(throwButton)) {
				let node = humanoid.throwObject(obj: humanoid.getWeapon().node, x: xJoystickDelta, y: yJoystickDelta)
				displayInventory()
				if (node != nil) {
					addChild(node!)
				}
			}
		}
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    
    override func update(_ currentTime: TimeInterval) {
		
		let ele = childNode(withName: "elevator")
		
		let horo = ((ele?.position.x)! - 50) ... ((ele?.position.x)! + 50)
		let vert = ((ele?.position.y)! ... (ele?.position.y)! + 80)
		if (horo ~= humanoid.node().position.x && vert.contains(humanoid.node().position.y)) {
			ele?.physicsBody?.pinned = false
			ele?.physicsBody?.velocity.dy = 500
			if (ele!.position.y > CGFloat(790)) {
				ele?.physicsBody?.velocity.dy = 0
				ele?.physicsBody!.pinned = true
			}
		} else if ((92...95).contains(Int((ele?.position.y)!))){
			ele?.physicsBody?.velocity.dy = 0
			ele?.physicsBody?.pinned = true
		} else {
			ele?.physicsBody?.pinned = false
			ele?.physicsBody?.velocity.dy = -200
		}
		
		let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: humanoid.node())
		cam.constraints = [constraint]
		
		dummyNode.position = cam.position
		
		if (toFade.contains(humanoid.node().position)) {
			toFade.run(SKAction.fadeOut(withDuration: TimeInterval(exactly: 0.5)!))
		}
		
		if (!isPunch && !dashActive) {
			humanoid.animateHuman(stickActive: stickActive, x: xJoystickDelta)
		}
		//print(humanoid.node().physicsBody?.velocity.dy as Any)
		humanoid.move(Double(xJoystickDelta))
		for i in enemyArray {
			i.move()
		}
    }
	
	func didBegin(_ contact: SKPhysicsContact) {
		if contact.bodyA.node == nil {
			print("crash")
			return
		}
		if contact.bodyA.node == nil {
			print("crash")
			return
		}
		let bodyA = contact.bodyA.node!
		let bodyB = contact.bodyB.node!
		//let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		var enemy = enemyArray[0]
		for i in enemyArray {
			if (i.node == bodyB) {
				enemy = i
			} else if (i.node == bodyA) {
				enemy = i
			}
		}
		//print("B", bodyB.name)
		//print("A", bodyA.name)
		if (bodyB == childNode(withName: "dagger") && bodyA == humanoid.node()) {
			humanoid.add(weapon: weaponDict[bodyB as? SKSpriteNode]!)
			bodyB.removeFromParent()
			//humanoid.invIncrease()
			displayInventory()
		} else if (bodyA == childNode(withName: "dagger") && bodyB == humanoid.node()) {
			humanoid.add(weapon: weaponDict[bodyA as? SKSpriteNode]!)
			bodyA.removeFromParent()
			//humanoid.invIncrease()
			displayInventory()
		}
		if (bodyB == childNode(withName: "gun") && bodyA == humanoid.node()) {
			humanoid.add(weapon: weaponDict[bodyB as? SKSpriteNode]!)
			bodyB.removeFromParent()
			//humanoid.invIncrease()
			displayInventory()
		} else if (bodyA == childNode(withName: "gun") && bodyB == humanoid.node()) {
			humanoid.add(weapon: weaponDict[bodyA as? SKSpriteNode]!)
			bodyA.removeFromParent()
			//humanoid.invIncrease()
			displayInventory()
		}
		
		if ((bodyB.name == "bullet" && bodyA.name == "wall") || (bodyA.name == "wall" && bodyB.name == "bullet")) {
			bodyB.removeFromParent()
		}
		
		var weapon = Weapon()
		for (i, _) in weaponDict {
			if (i == humanoid.lastWeaponThrown()) {
				weapon = weaponDict[i]!
			}
		}
		
		if (humanoid.lastWeaponThrown() != nil) {
			if (bodyA == enemy.node && bodyB.name == humanoid.lastWeaponThrown()!.name) {
				
				if ((humanoid.lastWeaponThrown()?.physicsBody?.velocity.dx)! > CGFloat(250.0) || (humanoid.lastWeaponThrown()?.physicsBody?.velocity.dx)! < CGFloat(-250.0)) {
					enemy.setHealth(enemy.getHealth() - weapon.damage)
					print("hit")
					if (enemy.getHealth() <= 0) {
						print("enemy dead")
						enemy.node.removeFromParent()
					}
				}
			}
		}
		
		if (enemy.node == bodyA && bodyB == humanoid.node()) {
			if (isPunch && !punchDetected) {
				punchDetected = true
				enemy.setHealth(enemy.getHealth() - humanoid.getWeapon().getDamage())
				if (enemy.getHealth() <= 0) {
					print("enemy dead")
					enemy.node.removeFromParent()
				}
			}
		}
		
		if ((enemy.node == bodyB && bodyA.name == "bullet") || (bodyB.name == "bullet" && bodyA == enemy.node)) {
			bodyB.removeFromParent()
			enemy.setHealth(enemy.getHealth() - humanoid.getWeapon().getDamage())
			if (enemy.getHealth() <= 0) {
				enemy.node.removeFromParent()
			}
		}
		
		if ((humanoid.node() == bodyB && bodyA.name == "bulletEnemy") || (bodyB.name == "bulletEnemy" && bodyA == humanoid.node())) {
			bodyB.removeFromParent()
			
			humanoid.setHealth(humanoid.getHealth() - 20)
			if (humanoid.getHealth() <= 0) {
				humanoid.node().removeFromParent()
			}
		}
		
		if (enemy.node == bodyB && bodyA == humanoid.node()) {
			if (enemy.punchActive && !enemy.punchDetected) {
				enemy.punchDetected = true
				humanoid.setHealth(humanoid.getHealth() - enemy.getWeapon().getDamage())
				if (humanoid.getHealth() <= 0) {
					print("humanoid dead")
				}
			}
		}
	}
	
	func append(enemy: Enemy) {
		enemyArray.append(enemy)
	}

	static func DefaultPhysics(_ physicsBody: SKPhysicsBody) {
		physicsBody.affectedByGravity = true
		physicsBody.allowsRotation = false
		physicsBody.friction = 1
		physicsBody.linearDamping = 1
		physicsBody.restitution = 0
	}
	
	func displayInventory() {
		let inv = humanoid.getInventory()
		let index = humanoid.inventoryIndex()
		weaponLabel.text = inv[index].name
		print(humanoid.getWeapon().toString())
	}
	
	func clearInvDisplay() {
		for node in humanoid.getInventory() {
			cam.childNode(withName: node.getName())?.removeFromParent()
		}
		invLabelPos = invLabel.position
		//cam.childNode(withName: "temp")?.removeFromParent()
	}
    
    func addEnemyMelee(pos: CGPoint) {
		let enemy = Enemy(name: "e1", health: 100, target: humanoid.node(), type: Enemy.enemyType.melee)
        enemy.setTarget(humanoid.node())
		enemyArray.append(enemy)
        enemy.node.position = CGPoint(x: pos.x, y: pos.y)
        self.addChild(enemy.node)
    }
	
	
	func addEnemyRanged(pos: CGPoint) {
		let enemy = Enemy(name: "e1", health: 100, target: humanoid.node(), type: Enemy.enemyType.ranged)
        enemy.setTarget(humanoid.node())
		enemyArray.append(enemy)
        enemy.node.position = CGPoint(x: pos.x, y: pos.y)
        self.addChild(enemy.node)
    }
}
