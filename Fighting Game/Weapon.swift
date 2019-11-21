//
//  Weapon.swift
//  Fighting Game
//
//  Created by Dylan Martin on 7/4/19.
//  Copyright © 2019 Dylan Martin. All rights reserved.
//

import GameplayKit
import SpriteKit

class Weapon: NSObject, SKPhysicsContactDelegate {
	enum weaponType {
		case ranged
		case melee
	}
	var type:weaponType
	var damage = Int()
	var range = Int()
	var name = String()
	var node = SKSpriteNode()
	var texture = SKTexture()
	var texturesLR:[SKTexture]
	
	public init(name: String, damage: Int, range: Int, node: SKSpriteNode, texture: SKTexture, textures: [SKTexture]) {
		self.name = name
		self.damage = damage
		self.range = range
		self.node = node
		self.texture = texture
		self.texturesLR = textures
		if (range > 0) {
			type = weaponType.ranged
		} else {
			type = weaponType.melee
		}
		node.name = name
		node.texture = texture
		node.physicsBody = SKPhysicsBody(rectangleOf: texture.size())
		node.physicsBody?.categoryBitMask = GameScene.CollisionTypes.weapon.rawValue
		node.physicsBody?.collisionBitMask = GameScene.CollisionTypes.wall.rawValue
		node.physicsBody?.contactTestBitMask = GameScene.CollisionTypes.humanoid.rawValue
	}
	
	public convenience override init() {
		let def = SKSpriteNode(imageNamed: "HumanoidStopped")
		self.init(name: "punch", damage: 5, range: 80, node: def, texture: SKTexture(imageNamed: "HumanoidStopped"), textures: [SKTexture(imageNamed: "HumanoidPunchLeft"), SKTexture(imageNamed: "HumanoidPunchRight")])
	}
	
	func getType() -> weaponType {
		return type
	}
	
	func getName() -> String {
		return name
	}
	
	func getDamage() -> Int {
		return damage
	}
	
	func getRange() -> Int {
		return range
	}
	
	func getNode() -> SKSpriteNode {
		return node
	}
	
	func makeWeapon(_ texture: SKTexture) -> SKSpriteNode {
		let weapon = SKSpriteNode(texture: texture)

		weapon.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
		defaultWeaponPhysics(weapon.physicsBody!)
		return weapon
	}
	
	func defaultWeaponPhysics(_ wep: SKPhysicsBody) {
		wep.affectedByGravity = false
		wep.allowsRotation = false
		wep.isDynamic = false
		wep.mass = 0.1
		
	}
	
	func getTextureArray() -> [SKTexture] {
		return texturesLR
	}
	
	func toString() -> String {
		var str = "Name: " + name
		str += " Range: " + String(range)
		str += " Damage: " + String(damage)
		return str
	}
}
