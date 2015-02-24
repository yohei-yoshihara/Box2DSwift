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

class AddPairViewController: BaseViewController {

  override func prepare() {
    world.setGravity(b2Vec2(0.0, 0.0))
    b2Locally {
      let shape = b2CircleShape()
      shape.p.setZero()
      shape.radius = 0.1
      
      let minX: b2Float = -6.0
      let maxX: b2Float = 0.0
      let minY: b2Float = 4.0
      let maxY: b2Float = 6.0
      
      for i in 0 ..< 50 {
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        bd.position = b2Vec2(RandomFloat(minX,maxX),RandomFloat(minY,maxY))
        let body = self.world.createBody(bd)
        body.createFixture(shape: shape, density: 0.01)
      }
    }
    
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 1.5, halfHeight: 1.5)
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(-40.0, 5.0)
      bd.bullet = true
      let body = self.world.createBody(bd)
      body.createFixture(shape: shape, density: 1.0)
      body.setLinearVelocity(b2Vec2(150.0, 0.0))
    }
  }
  
}
