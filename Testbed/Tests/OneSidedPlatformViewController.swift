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

class OneSidedPlatformViewController: BaseViewController, b2ContactListener {
  var radius: b2Float = 0.5
  let top: b2Float = 10.0 + 0.5
  let bottom: b2Float = 10.0 - 0.5
  var platform: b2Fixture!
  var character: b2Fixture!
  var additionalInfoView: AdditionalInfoView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let size = self.view.bounds.size
    additionalInfoView = AdditionalInfoView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    self.view.addSubview(additionalInfoView)
  }
  
  override func prepare() {
    world.setContactListener(self)
    
    // Ground
    b2Locally {
      var bd = b2BodyDef()
      var ground = self.world.createBody(bd)
      
      var shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-20.0, 0.0), vertex2: b2Vec2(20.0, 0.0))
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    // Platform
    b2Locally {
      var bd = b2BodyDef()
      bd.position.set(0.0, 10.0)
      var body = self.world.createBody(bd)
      
      var shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 3.0, halfHeight: 0.5)
      self.platform = body.createFixture(shape: shape, density: 0.0)
    }
    
    // Actor
    b2Locally {
      var bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(0.0, 12.0)
      var body = self.world.createBody(bd)
      
      var shape = b2CircleShape()
      shape.radius = self.radius
      self.character = body.createFixture(shape: shape, density: 20.0)
      
      body.setLinearVelocity(b2Vec2(0.0, -50.0))
    }
  }
  
  func preSolve(contact: b2Contact, oldManifold: b2Manifold) {
    contactListener.preSolve(contact, oldManifold: oldManifold)
    
    let fixtureA = contact.fixtureA
    let fixtureB = contact.fixtureB
    
    if fixtureA !== platform && fixtureA !== character {
      return
    }
    
    if fixtureB !== platform && fixtureB !== character {
      return
    }
    
#if true
    let position = character.body.position
    if position.y < top + radius - 3.0 * b2_linearSlop {
      contact.setEnabled(false)
    }
#else
    let v = character.body.linearVelocity
    if v.y > 0.0 {
      contact.setEnabled(false);
    }
#endif
  }
  
  override func step() {
    additionalInfoView.begin()
    let v = character.body.linearVelocity
    additionalInfoView.append(String(format: "Character Linear Velocity: %f", v.y))
    additionalInfoView.end()
  }
  
  func beginContact(contact : b2Contact) { contactListener.beginContact(contact) }
  func endContact(contact: b2Contact) { contactListener.endContact(contact) }
  func postSolve(contact: b2Contact, impulse: b2ContactImpulse) { contactListener.postSolve(contact, impulse: impulse) }
}
