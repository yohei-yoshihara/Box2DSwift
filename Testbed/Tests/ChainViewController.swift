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

class ChainViewController: BaseViewController {
  override func prepare() {
    var ground: b2Body! = nil
    b2Locally {
      let bd = b2BodyDef()
      ground = self.world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.6, halfHeight: 0.125)
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 20.0
      fd.friction = 0.2
      
      let jd = b2RevoluteJointDef()
      jd.collideConnected = false
      
      let y: b2Float = 25.0
      var prevBody = ground
      for i in 0 ..< 30 {
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        bd.position.set(0.5 + b2Float(i), y)
        let body = self.world.createBody(bd)
        body.createFixture(fd)
        
        let anchor = b2Vec2(b2Float(i), y)
        jd.initialize(prevBody, bodyB: body, anchor: anchor)
        self.world.createJoint(jd)
        
        prevBody = body
      }
    }
  }
}
