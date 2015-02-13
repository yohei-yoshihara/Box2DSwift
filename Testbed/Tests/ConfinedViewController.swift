/**
Copyright (c) 2006-2014 Erin Catto http://www.box2d.org
Copyright (c) 2015 - Yohei Yoshihara

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.

This version of box2d was developed by Yohei Yoshihara. It is based upon
the original C++ code written by Erin Catto.
*/

import UIKit
import Box2D

class ConfinedViewController: BaseViewController {
  let columnCount = 0
  let rowCount = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let createButton = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.Plain, target: self, action: "onCreate:")
    let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    self.addToolbarItems([createButton, flexible])
  }
  
  func onCreate(sender: UIBarButtonItem) {
    createCircle()
  }
  
  override func prepare() {
    b2Locally {
      let bd = b2BodyDef()
      let ground = world.createBody(bd)
      
      let shape = b2EdgeShape()
      
      // Floor
      shape.set(vertex1: b2Vec2(-10.0, 0.0), vertex2: b2Vec2(10.0, 0.0))
      ground.createFixture(shape: shape, density: 0.0)
      
      // Left wall
      shape.set(vertex1: b2Vec2(-10.0, 0.0), vertex2: b2Vec2(-10.0, 20.0))
      ground.createFixture(shape: shape, density: 0.0)
      
      // Right wall
      shape.set(vertex1: b2Vec2(10.0, 0.0), vertex2: b2Vec2(10.0, 20.0))
      ground.createFixture(shape: shape, density: 0.0)
      
      // Roof
      shape.set(vertex1: b2Vec2(-10.0, 20.0), vertex2: b2Vec2(10.0, 20.0))
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    let radius: b2Float = 0.5
    let shape = b2CircleShape()
    shape.p.setZero()
    shape.radius = radius
    
    let fd = b2FixtureDef()
    fd.shape = shape
    fd.density = 1.0
    fd.friction = 0.1
    
    for j in 0 ..< columnCount {
      for i in 0 ..< rowCount {
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        bd.position.set(-10.0 + (2.1 * b2Float(j) + 1.0 + 0.01 * b2Float(i)) * radius, (2.0 * b2Float(i) + 1.0) * radius)
        let body = world.createBody(bd)
        body.createFixture(fd)
      }
    }
    
    world.setGravity(b2Vec2(0.0, 0.0))
  }
  
  func createCircle() {
    let radius: b2Float = 2.0
		let shape = b2CircleShape()
		shape.p.setZero()
		shape.radius = radius
  
		let fd = b2FixtureDef()
		fd.shape = shape
    fd.density = 1.0
		fd.friction = 0.0
  
		let p = b2Vec2(randomFloat(), 3.0 + randomFloat())
		let bd = b2BodyDef()
		bd.type = b2BodyType.dynamicBody;
		bd.position = p
		//bd.allowSleep = false
		let body = world.createBody(bd)
  
		body.createFixture(fd)
  }
  
}
