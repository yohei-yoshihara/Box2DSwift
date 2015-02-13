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

class SphereStackViewController: BaseViewController {
  let count = 10
  var m_bodies = [b2Body]()

  override func prepare() {
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    b2Locally {
      let shape = b2CircleShape()
      shape.radius = 1.0
      
      for i in 0 ..< self.count {
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        bd.position.set(0.0, 4.0 + 3.0 * b2Float(i))
        
        self.m_bodies.append(self.world.createBody(bd))
        
        self.m_bodies.last!.createFixture(shape: shape, density: 1.0)
        
        self.m_bodies.last!.setLinearVelocity(b2Vec2(0.0, -50.0))
      }
    }
  }
  
}
