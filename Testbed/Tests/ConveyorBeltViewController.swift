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

class ConveyorBeltViewController: BaseViewController, b2ContactListener {
  var platform: b2Fixture!

  override func prepare() {
    world.setContactListener(self)
    
    // Ground
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
        
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-20.0, 0.0), vertex2: b2Vec2(20.0, 0.0))
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    // Platform
    b2Locally {
      let bd = b2BodyDef()
      bd.position.set(-5.0, 5.0)
      let body = self.world.createBody(bd)
      
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 10.0, halfHeight: 0.5)
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.friction = 0.8
      self.platform = body.createFixture(fd)
    }
    
    // Boxes
    for i in 0 ..< 5 {
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(-10.0 + 2.0 * b2Float(i), 7.0)
      let body = world.createBody(bd)
      
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.5, halfHeight: 0.5)
      body.createFixture(shape: shape, density: 20.0)
    }
  }

  func preSolve(contact: b2Contact, oldManifold: b2Manifold) {
    contactListener.preSolve(contact, oldManifold: oldManifold)
    
    let fixtureA = contact.fixtureA
    let fixtureB = contact.fixtureB
    
    if fixtureA === platform {
      contact.setTangentSpeed(5.0)
    }
    
    if fixtureB === platform {
      contact.setTangentSpeed(-5.0)
    }
  }
  
  func beginContact(contact : b2Contact) { contactListener.beginContact(contact) }
  func endContact(contact: b2Contact) { contactListener.endContact(contact) }
  func postSolve(contact: b2Contact, impulse: b2ContactImpulse) { contactListener.postSolve(contact, impulse: impulse) }
}
