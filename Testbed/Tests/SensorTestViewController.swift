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

class SensorTestViewController: BaseViewController, b2ContactListener {
  let count = 7
  
  var sensor: b2Fixture!
  var bodies = [b2Body]()

  override func prepare() {
    world.setContactListener(self)
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
      b2Locally {
        let shape = b2EdgeShape()
        shape.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
        ground.createFixture(shape: shape, density: 0.0)
      }
      
#if false
      b2Locally {
        let sd = b2FixtureDef()
        sd.SetAsBox(10.0, 2.0, b2Vec2(0.0, 20.0), 0.0)
        sd.isSensor = true
        self.sensor = ground.createFixture(sd)
      }
#else
      b2Locally {
        let shape = b2CircleShape()
        shape.radius = 5.0
        shape.p.set(0.0, 10.0)
          
        let fd = b2FixtureDef()
        fd.shape = shape
        fd.isSensor = true
        self.sensor = ground.createFixture(fd)
      }
#endif
    }
    
    b2Locally {
      let shape = b2CircleShape()
      shape.radius = 1.0
      
      for i in 0 ..< self.count {
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        bd.position.set(-10.0 + 3.0 * b2Float(i), 20.0)
        bd.userData = NSNumber(bool: false)
        self.bodies.append(self.world.createBody(bd))
        self.bodies.last!.createFixture(shape: shape, density: 1.0)
      }
    }
  }
  
  func beginContact(contact: b2Contact) {
    contactListener.beginContact(contact)

    let fixtureA = contact.fixtureA
    let fixtureB = contact.fixtureB
    
    if fixtureA === sensor {
      let userData: AnyObject? = fixtureB.body.userData
      if userData != nil {
        fixtureB.body.setUserData(NSNumber(bool: true))
      }
    }
    
    if fixtureB === sensor {
      let userData: AnyObject? = fixtureA.body.userData
      if userData != nil {
        fixtureA.body.setUserData(NSNumber(bool: true))
      }
    }
  }
  
  func endContact(contact: b2Contact) {
    contactListener.endContact(contact)

    let fixtureA = contact.fixtureA
    let fixtureB = contact.fixtureB
    
    if fixtureA === sensor {
      let userData: AnyObject? = fixtureB.body.userData
      if userData != nil {
        fixtureB.body.setUserData(NSNumber(bool: false))
      }
    }
    
    if fixtureB === sensor {
      let userData: AnyObject? = fixtureA.body.userData
      if userData != nil {
        fixtureA.body.setUserData(NSNumber(bool: false))
      }
    }
  }
  
  func preSolve(contact: b2Contact, oldManifold: b2Manifold) {
    contactListener.preSolve(contact, oldManifold: oldManifold)
  }
  
  func postSolve(contact: b2Contact, impulse: b2ContactImpulse) {
    contactListener.postSolve(contact, impulse: impulse)
  }
  
  override func step() {
		// Traverse the contact results. Apply a force on shapes
		// that overlap the sensor.
		for i in 0 ..< self.count {
      let body = bodies[i]
      let userData: AnyObject? = body.userData
      if userData == nil {
        continue
      }
      if (userData! as! NSNumber).boolValue == false {
        continue
      }
      
      let ground = sensor.body
      
      let circle = sensor.shape as! b2CircleShape
      let center = ground.getWorldPoint(circle.p)
      
      let position = body.position
      
      var d = center - position
      if d.lengthSquared() < FLT_EPSILON * FLT_EPSILON {
        continue
      }
      
      d.normalize()
      let F = 100.0 * d
      body.applyForce(F, point: position, wake: false)
		}
  }
}
