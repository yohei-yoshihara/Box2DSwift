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

class DominosViewController: BaseViewController {
  override func prepare() {
    var b1: b2Body!
    b2Locally {
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
      
      let bd = b2BodyDef()
      b1 = self.world.createBody(bd)
      b1.createFixture(shape: shape, density: 0.0)
    }
    
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 6.0, halfHeight: 0.25)
      
      let bd = b2BodyDef()
      bd.position.set(-1.5, 10.0)
      let ground = self.world.createBody(bd)
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.1, halfHeight: 1.0)
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 20.0
      fd.friction = 0.1
      
      for i in 0 ..< 10 {
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        bd.position.set(-6.0 + 1.0 * b2Float(i), 11.25)
        let body = self.world.createBody(bd)
        body.createFixture(fd)
      }
    }
    
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 7.0, halfHeight: 0.25, center: b2Vec2_zero, angle: 0.3)
      
      let bd = b2BodyDef()
      bd.position.set(1.0, 6.0)
      let ground = self.world.createBody(bd)
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    var b2: b2Body!
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.25, halfHeight: 1.5)
      
      let bd = b2BodyDef()
      bd.position.set(-7.0, 4.0)
      b2 = self.world.createBody(bd)
      b2.createFixture(shape: shape, density: 0.0)
    }
    
    var b3: b2Body!
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 6.0, halfHeight: 0.125)
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(-0.9, 1.0)
      bd.angle = -0.15
      
      b3 = self.world.createBody(bd)
      b3.createFixture(shape: shape, density: 10.0)
    }
    
    let jd = b2RevoluteJointDef()
    var anchor = b2Vec2()
    anchor.set(-2.0, 1.0)
    jd.initialize(b1, bodyB: b3, anchor: anchor)
    jd.collideConnected = true
    self.world.createJoint(jd)
    
    var b4: b2Body!
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.25, halfHeight: 0.25)
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(-10.0, 15.0)
      b4 = self.world.createBody(bd)
      b4.createFixture(shape: shape, density: 10.0)
    }
    
    anchor.set(-7.0, 15.0)
    jd.initialize(b2, bodyB: b4, anchor: anchor)
    self.world.createJoint(jd)
    
    var b5: b2Body!
    b2Locally {
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(6.5, 3.0)
      b5 = self.world.createBody(bd)
      
      let shape = b2PolygonShape()
      let fd = b2FixtureDef()
      
      fd.shape = shape
      fd.density = 10.0
      fd.friction = 0.1
      
      shape.setAsBox(halfWidth: 1.0, halfHeight: 0.1, center: b2Vec2(0.0, -0.9), angle: 0.0)
      b5.createFixture(fd)
      
      shape.setAsBox(halfWidth: 0.1, halfHeight: 1.0, center: b2Vec2(-0.9, 0.0), angle: 0.0)
      b5.createFixture(fd)
      
      shape.setAsBox(halfWidth: 0.1, halfHeight: 1.0, center: b2Vec2(0.9, 0.0), angle: 0.0)
      b5.createFixture(fd)
    }
    
    anchor.set(6.0, 2.0)
    jd.initialize(b1, bodyB: b5, anchor: anchor)
    self.world.createJoint(jd)
    
    var b6: b2Body!
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 1.0, halfHeight: 0.1)
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(6.5, 4.1)
      b6 = self.world.createBody(bd)
      b6.createFixture(shape: shape, density: 30.0)
    }
    
    anchor.set(7.5, 4.0)
    jd.initialize(b5, bodyB: b6, anchor: anchor)
    self.world.createJoint(jd)
    
    var b7: b2Body!
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.1, halfHeight: 1.0)
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(7.4, 1.0)
      
      b7 = self.world.createBody(bd)
      b7.createFixture(shape: shape, density: 10.0)
    }
    
    let djd = b2DistanceJointDef()
    djd.bodyA = b3
    djd.bodyB = b7
    djd.localAnchorA.set(6.0, 0.0)
    djd.localAnchorB.set(0.0, -1.0)
    let d = djd.bodyB.getWorldPoint(djd.localAnchorB) - djd.bodyA.getWorldPoint(djd.localAnchorA)
    djd.length = d.length()
    self.world.createJoint(djd)
    
    b2Locally {
      let radius: b2Float = 0.2
      
      let shape = b2CircleShape()
      shape.radius = radius
      
      for i in 0 ..< 4 {
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        bd.position.set(5.9 + 2.0 * radius * b2Float(i), 2.4)
        let body = self.world.createBody(bd)
        body.createFixture(shape: shape, density: 10.0)
      }
    }
  }
  
}
