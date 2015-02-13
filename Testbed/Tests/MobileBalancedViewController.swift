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

class MobileBalancedViewController: BaseViewController {
  let depth = 4
  
  override func prepare() {
    var ground: b2Body!
    
    // Create ground body.
    b2Locally {
      var bodyDef = b2BodyDef()
      bodyDef.position.set(0.0, 20.0)
      ground = self.world.createBody(bodyDef)
    }
    
    let a: b2Float = 0.5
    let h = b2Vec2(0.0, a)
    
    let root = addNode(ground, b2Vec2_zero, 0, 3.0, a)
    
    var jointDef = b2RevoluteJointDef()
    jointDef.bodyA = ground
    jointDef.bodyB = root
    jointDef.localAnchorA.setZero()
    jointDef.localAnchorB = h
    world.createJoint(jointDef)
  }
  
  func addNode(parent: b2Body, _ localAnchor: b2Vec2, _ depth: Int, _ offset: b2Float, _ a: b2Float) -> b2Body {
    let density: b2Float = 20.0
    let h = b2Vec2(0.0, a)
    
    let p = parent.position + localAnchor - h
    
    var bodyDef = b2BodyDef()
    bodyDef.type = b2BodyType.dynamicBody
    bodyDef.position = p
    var body = world.createBody(bodyDef)
    
    var shape = b2PolygonShape()
    shape.setAsBox(halfWidth: 0.25 * a, halfHeight: a)
    body.createFixture(shape: shape, density: density)
    
    if depth == self.depth {
      return body
    }
    
    shape.setAsBox(halfWidth: offset, halfHeight: 0.25 * a, center: b2Vec2(0, -a), angle: 0.0)
    body.createFixture(shape: shape, density: density)
    
    let a1 = b2Vec2(offset, -a)
    let a2 = b2Vec2(-offset, -a)
    let body1 = addNode(body, a1, depth + 1, 0.5 * offset, a)
    let body2 = addNode(body, a2, depth + 1, 0.5 * offset, a)
    
    var jointDef = b2RevoluteJointDef()
    jointDef.bodyA = body
    jointDef.localAnchorB = h
    
    jointDef.localAnchorA = a1
    jointDef.bodyB = body1
    world.createJoint(jointDef)
    
    jointDef.localAnchorA = a2
    jointDef.bodyB = body2
    world.createJoint(jointDef)
    
    return body
  }
}
