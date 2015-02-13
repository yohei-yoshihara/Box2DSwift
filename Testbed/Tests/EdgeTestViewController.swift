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

class EdgeTestViewController: BaseViewController {

  override func prepare() {
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
      let v1 = b2Vec2(-10.0, 0.0), v2 = b2Vec2(-7.0, -2.0), v3 = b2Vec2(-4.0, 0.0)
      let v4 = b2Vec2(0.0, 0.0), v5 = b2Vec2(4.0, 0.0), v6 = b2Vec2(7.0, 2.0), v7 = b2Vec2(10.0, 0.0)
      
      let shape = b2EdgeShape()
      
      shape.set(vertex1: v1, vertex2: v2)
      shape.hasVertex3 = true
      shape.vertex3 = v3
      ground.createFixture(shape: shape, density: 0.0)
      
      shape.set(vertex1: v2, vertex2: v3)
      shape.hasVertex0 = true
      shape.hasVertex3 = true
      shape.vertex0 = v1
      shape.vertex3 = v4
      ground.createFixture(shape: shape, density: 0.0)
      
      shape.set(vertex1: v3, vertex2: v4)
      shape.hasVertex0 = true
      shape.hasVertex3 = true
      shape.vertex0 = v2
      shape.vertex3 = v5
      ground.createFixture(shape: shape, density: 0.0)
      
      shape.set(vertex1: v4, vertex2: v5)
      shape.hasVertex0 = true
      shape.hasVertex3 = true
      shape.vertex0 = v3
      shape.vertex3 = v6
      ground.createFixture(shape: shape, density: 0.0)
      
      shape.set(vertex1: v5, vertex2: v6)
      shape.hasVertex0 = true
      shape.hasVertex3 = true
      shape.vertex0 = v4
      shape.vertex3 = v7
      ground.createFixture(shape: shape, density: 0.0)
      
      shape.set(vertex1: v6, vertex2: v7)
      shape.hasVertex0 = true
      shape.vertex0 = v5
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    b2Locally {
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(-0.5, 0.6)
      bd.allowSleep = false
      let body = self.world.createBody(bd)
      
      let shape = b2CircleShape()
      shape.radius = 0.5
      
      body.createFixture(shape: shape, density: 1.0)
    }
    
    b2Locally {
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(1.0, 0.6)
      bd.allowSleep = false
      let body = world.createBody(bd)
      
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.5, halfHeight: 0.5)
      
      body.createFixture(shape: shape, density: 1.0)
    }
  }
}
