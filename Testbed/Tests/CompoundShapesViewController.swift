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

class CompoundShapesViewController: BaseViewController {
  
  override func prepare() {
    b2Locally {
      let bd = b2BodyDef()
      bd.position.set(0.0, 0.0)
      let body = self.world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(50.0, 0.0), vertex2: b2Vec2(-50.0, 0.0))
      
      body.createFixture(shape: shape, density: 0.0)
    }
    
    b2Locally {
      let circle1 = b2CircleShape()
      circle1.radius = 0.5
      circle1.p.set(-0.5, 0.5)
      
      let circle2 = b2CircleShape()
      circle2.radius = 0.5
      circle2.p.set(0.5, 0.5)
      
      for i in 0 ..< 10 {
        let x = RandomFloat(-0.1, 0.1)
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        bd.position.set(x + 5.0, 1.05 + 2.5 * b2Float(i))
        bd.angle = RandomFloat(-b2_pi, b2_pi)
        let body = self.world.createBody(bd)
        body.createFixture(shape: circle1, density: 2.0)
        body.createFixture(shape: circle2, density: 0.0)
      }
    }
    
    b2Locally {
      let polygon1 = b2PolygonShape()
      polygon1.setAsBox(halfWidth: 0.25, halfHeight: 0.5)
      
      let polygon2 = b2PolygonShape()
      polygon2.setAsBox(halfWidth: 0.25, halfHeight: 0.5, center: b2Vec2(0.0, -0.5), angle: 0.5 * b2_pi)
      
      for i in 0 ..< 10 {
        let x = RandomFloat(-0.1, 0.1)
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        bd.position.set(x - 5.0, 1.05 + 2.5 * b2Float(i))
        bd.angle = RandomFloat(-b2_pi, b2_pi)
        let body = self.world.createBody(bd)
        body.createFixture(shape: polygon1, density: 2.0)
        body.createFixture(shape: polygon2, density: 2.0)
      }
    }
    
    b2Locally {
      var xf1 = b2Transform()
      xf1.q.set(0.3524 * b2_pi)
      xf1.p = xf1.q.xAxis
      
      var vertices = [b2Vec2](count: 3, repeatedValue: b2Vec2())
      
      let triangle1 = b2PolygonShape()
      vertices[0] = b2Mul(xf1, b2Vec2(-1.0, 0.0))
      vertices[1] = b2Mul(xf1, b2Vec2(1.0, 0.0))
      vertices[2] = b2Mul(xf1, b2Vec2(0.0, 0.5))
      triangle1.set(vertices: vertices)
      
      var xf2 = b2Transform()
      xf2.q.set(-0.3524 * b2_pi)
      xf2.p = -xf2.q.xAxis
      
      let triangle2 = b2PolygonShape()
      vertices[0] = b2Mul(xf2, b2Vec2(-1.0, 0.0))
      vertices[1] = b2Mul(xf2, b2Vec2(1.0, 0.0))
      vertices[2] = b2Mul(xf2, b2Vec2(0.0, 0.5))
      triangle2.set(vertices: vertices)
      
      for i in 0 ..< 10 {
        let x = RandomFloat(-0.1, 0.1)
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        bd.position.set(x, 2.05 + 2.5 * b2Float(i))
        bd.angle = 0.0
        let body = self.world.createBody(bd)
        body.createFixture(shape: triangle1, density: 2.0)
        body.createFixture(shape: triangle2, density: 2.0)
      }
    }
    
    b2Locally {
      let bottom = b2PolygonShape()
      bottom.setAsBox(halfWidth: 1.5, halfHeight: 0.15)
      
      let left = b2PolygonShape()
      left.setAsBox(halfWidth: 0.15, halfHeight: 2.7, center: b2Vec2(-1.45, 2.35), angle: 0.2)
      
      let right = b2PolygonShape()
      right.setAsBox(halfWidth: 0.15, halfHeight: 2.7, center: b2Vec2(1.45, 2.35), angle: -0.2)
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(0.0, 2.0)
      let body = self.world.createBody(bd)
      body.createFixture(shape: bottom, density: 4.0)
      body.createFixture(shape: left, density: 4.0)
      body.createFixture(shape: right, density: 4.0)
    }
  }
  
}
