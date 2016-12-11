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

class ApplyForceViewController: BaseViewController {
  var body: b2Body!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let leftButton = UIBarButtonItem(title: "Left", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ApplyForceViewController.onLeft(_:)))
    let upButton = UIBarButtonItem(title: "Up", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ApplyForceViewController.onUp(_:)))
    let rightButton = UIBarButtonItem(title: "Right", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ApplyForceViewController.onRight(_:)))
    let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    self.addToolbarItems([
      leftButton, flexible,
      upButton, flexible,
      rightButton, flexible
      ])
  }
  
  override func prepare() {
    world.setGravity(b2Vec2(0.0, 0.0))
    
    let k_restitution: b2Float = 0.4
    
    var ground: b2Body!
    b2Locally {
      let bd = b2BodyDef()
      bd.position.set(0.0, 20.0)
      ground = self.world.createBody(bd)
     
      let shape = b2EdgeShape()
      
      let sd = b2FixtureDef()
      sd.shape = shape
      sd.density = 0.0
      sd.restitution = k_restitution
     
      // Left vertical
      shape.set(vertex1: b2Vec2(-20.0, -20.0), vertex2: b2Vec2(-20.0, 20.0))
      ground.createFixture(sd)
     
      // Right vertical
      shape.set(vertex1: b2Vec2(20.0, -20.0), vertex2: b2Vec2(20.0, 20.0))
      ground.createFixture(sd)
      
      // Top horizontal
      shape.set(vertex1: b2Vec2(-20.0, 20.0), vertex2: b2Vec2(20.0, 20.0))
      ground.createFixture(sd)
      
      // Bottom horizontal
      shape.set(vertex1: b2Vec2(-20.0, -20.0), vertex2: b2Vec2(20.0, -20.0))
      ground.createFixture(sd)
    }
    
    b2Locally {
      var xf1 = b2Transform()
      xf1.q.set(0.3524 * b2_pi)
      xf1.p = xf1.q.xAxis
      
      var vertices = [b2Vec2]()
      vertices.append(b2Mul(xf1, b2Vec2(-1.0, 0.0)))
      vertices.append(b2Mul(xf1, b2Vec2(1.0, 0.0)))
      vertices.append(b2Mul(xf1, b2Vec2(0.0, 0.5)))
      
      let poly1 = b2PolygonShape()
      poly1.set(vertices: vertices)
      
      let sd1 = b2FixtureDef()
      sd1.shape = poly1
      sd1.density = 4.0
      
      var xf2 = b2Transform()
      xf2.q.set(-0.3524 * b2_pi)
      xf2.p = -xf2.q.xAxis
      
      vertices[0] = b2Mul(xf2, b2Vec2(-1.0, 0.0))
      vertices[1] = b2Mul(xf2, b2Vec2(1.0, 0.0))
      vertices[2] = b2Mul(xf2, b2Vec2(0.0, 0.5))
      
      let poly2 = b2PolygonShape()
      poly2.set(vertices: vertices)
      
      let sd2 = b2FixtureDef()
      sd2.shape = poly2
      sd2.density = 2.0
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.angularDamping = 2.0
      bd.linearDamping = 0.5
      
      bd.position.set(0.0, 2.0)
      bd.angle = b2_pi
      bd.allowSleep = false
      self.body = self.world.createBody(bd)
      self.body.createFixture(sd1)
      self.body.createFixture(sd2)
    }
    
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.5, halfHeight: 0.5)
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 1.0
      fd.friction = 0.3
      
      for i in 0 ..< 10 {
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        
        bd.position.set(0.0, 5.0 + 1.54 * b2Float(i))
        let body = self.world.createBody(bd)
        
        body.createFixture(fd)
        
        let gravity: b2Float = 10.0
        let I = body.inertia
        let mass = body.mass
        
        // For a circle: I = 0.5 * m * r * r ==> r = sqrt(2 * I / m)
        let radius: b2Float = sqrt(2.0 * I / mass)
        
        let jd = b2FrictionJointDef()
        jd.localAnchorA.setZero()
        jd.localAnchorB.setZero()
        jd.bodyA = ground
        jd.bodyB = body
        jd.collideConnected = true
        jd.maxForce = mass * gravity
        jd.maxTorque = mass * radius * gravity
        
        self.world.createJoint(jd)
      }
    }
  }

  override func step() {
  }
  
  func onLeft(_ sender: UIBarButtonItem) {
    body.applyTorque(50.0, wake: true)
  }
  
  func onUp(_ sender: UIBarButtonItem) {
    let f = body.getWorldVector(b2Vec2(0.0, -200.0))
    let p = body.getWorldPoint(b2Vec2(0.0, 2.0))
    body.applyForce(f, point: p, wake: true)
  }

  func onRight(_ sender: UIBarButtonItem) {
    body.applyTorque(-50.0, wake: true)
  }
}
