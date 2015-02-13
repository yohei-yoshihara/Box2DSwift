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

class BreakableViewController: BaseViewController, b2ContactListener {
  let count = 7
  
  var m_body1: b2Body!
  var m_velocity = b2Vec2()
  var m_angularVelocity: b2Float = 0
  var m_shape1 = b2PolygonShape()
  var m_shape2 = b2PolygonShape()
  var m_piece1: b2Fixture!
  var m_piece2: b2Fixture!
  
  var m_broke = false
  var m_break = false
  
  override func prepare() {
    world.setContactListener(self)
    
    // Ground body
    b2Locally {
      let bd = b2BodyDef()
      let ground = world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
      ground.createFixture(shape:shape, density: 0.0)
    }
    
    // Breakable dynamic body
    b2Locally {
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(0.0, 40.0)
      bd.angle = 0.25 * b2_pi
      self.m_body1 = self.world.createBody(bd)
      
      self.m_shape1.setAsBox(halfWidth: 0.5, halfHeight: 0.5, center: b2Vec2(-0.5, 0.0), angle: 0.0)
      self.m_piece1 = self.m_body1.createFixture(shape: self.m_shape1, density: 1.0)
      
      self.m_shape2.setAsBox(halfWidth: 0.5, halfHeight: 0.5, center: b2Vec2(0.5, 0.0), angle: 0.0)
      self.m_piece2 = self.m_body1.createFixture(shape: self.m_shape2, density: 1.0)
    }
    
    m_break = false
    m_broke = false
  }
  
  func postSolve(contact: b2Contact, impulse: b2ContactImpulse) {
    contactListener.postSolve(contact, impulse: impulse)
  
    if m_broke {
      // The body already broke.
      return
    }
    
    // Should the body break?
    let count = contact.manifold.pointCount
    
    var maxImpulse: b2Float = 0.0
    for i in 0 ..< count {
      maxImpulse = max(maxImpulse, impulse.normalImpulses[i])
    }
    
    if maxImpulse > 40.0 {
      // Flag the body for breaking.
      m_break = true
    }
  }

  func doBreak() {
		// Create two bodies from one.
		let body1 = m_piece1.body
		let center = body1.worldCenter
  
		body1.destroyFixture(m_piece2)
		m_piece2 = nil
  
		let bd = b2BodyDef()
		bd.type = b2BodyType.dynamicBody
		bd.position = body1.position
		bd.angle = body1.angle
  
		let body2 = world.createBody(bd)
    m_piece2 = body2.createFixture(shape: m_shape2, density: 1.0)
  
		// Compute consistent velocities for new bodies based on
		// cached velocity.
		let center1 = body1.worldCenter
		let center2 = body2.worldCenter
		
		let velocity1 = m_velocity + b2Cross(m_angularVelocity, center1 - center)
		let velocity2 = m_velocity + b2Cross(m_angularVelocity, center2 - center)
  
		body1.setAngularVelocity(m_angularVelocity)
		body1.setLinearVelocity(velocity1)
  
		body2.setAngularVelocity(m_angularVelocity)
		body2.setLinearVelocity(velocity2)
  }

  override func step() {
		if m_break {
      doBreak();
      m_broke = true
      m_break = false
		}
  
		// Cache velocities to improve movement on breakage.
		if m_broke == false {
      m_velocity = m_body1.linearVelocity
      m_angularVelocity = m_body1.angularVelocity
		}
  }
  
  func beginContact(contact : b2Contact) { contactListener.beginContact(contact) }
  func endContact(contact: b2Contact) { contactListener.endContact(contact) }
  func preSolve(contact: b2Contact, oldManifold: b2Manifold) {
    contactListener.preSolve(contact, oldManifold: oldManifold);
  }
  
}
