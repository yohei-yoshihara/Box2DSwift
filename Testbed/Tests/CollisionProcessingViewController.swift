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

class CollisionProcessingViewController: BaseViewController {
  override func prepare() {
    // Ground body
    b2Locally {
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-50.0, 0.0), vertex2: b2Vec2(50.0, 0.0))
      
      let sd = b2FixtureDef()
      sd.shape = shape
      
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      ground.createFixture(sd)
    }
    
    let xLo: b2Float = -5.0, xHi: b2Float = 5.0
    let yLo: b2Float = 2.0, yHi: b2Float = 35.0
    
    // Small triangle
    var vertices = [b2Vec2]()
    vertices.append(b2Vec2(-1.0, 0.0))
    vertices.append(b2Vec2(1.0, 0.0))
    vertices.append(b2Vec2(0.0, 2.0))
    
    let polygon = b2PolygonShape()
    polygon.set(vertices: vertices)
    
    let triangleShapeDef = b2FixtureDef()
    triangleShapeDef.shape = polygon
    triangleShapeDef.density = 1.0
    
    let triangleBodyDef = b2BodyDef()
    triangleBodyDef.type = b2BodyType.dynamicBody
    triangleBodyDef.position.set(RandomFloat(xLo, xHi), RandomFloat(yLo, yHi))
    
    let body1 = world.createBody(triangleBodyDef)
    body1.createFixture(triangleShapeDef)
    
    // Large triangle (recycle definitions)
    vertices[0] *= 2.0
    vertices[1] *= 2.0
    vertices[2] *= 2.0
    polygon.set(vertices: vertices)
    
    triangleBodyDef.position.set(RandomFloat(xLo, xHi), RandomFloat(yLo, yHi))
    
    let body2 = world.createBody(triangleBodyDef)
    body2.createFixture(triangleShapeDef)
    
    // Small box
    polygon.setAsBox(halfWidth: 1.0, halfHeight: 0.5)
    
    let boxShapeDef = b2FixtureDef()
    boxShapeDef.shape = polygon
    boxShapeDef.density = 1.0
    
    let boxBodyDef = b2BodyDef()
    boxBodyDef.type = b2BodyType.dynamicBody
    boxBodyDef.position.set(RandomFloat(xLo, xHi), RandomFloat(yLo, yHi))
    
    let body3 = world.createBody(boxBodyDef)
    body3.createFixture(boxShapeDef)
    
    // Large box (recycle definitions)
    polygon.setAsBox(halfWidth: 2.0, halfHeight: 1.0)
    boxBodyDef.position.set(RandomFloat(xLo, xHi), RandomFloat(yLo, yHi))
    
    let body4 = world.createBody(boxBodyDef)
    body4.createFixture(boxShapeDef)
    
    // Small circle
    let circle = b2CircleShape()
    circle.radius = 1.0
    
    let circleShapeDef = b2FixtureDef()
    circleShapeDef.shape = circle
    circleShapeDef.density = 1.0
    
    let circleBodyDef = b2BodyDef()
    circleBodyDef.type = b2BodyType.dynamicBody
    circleBodyDef.position.set(RandomFloat(xLo, xHi), RandomFloat(yLo, yHi))
    
    let body5 = world.createBody(circleBodyDef)
    body5.createFixture(circleShapeDef)
    
    // Large circle
    circle.radius *= 2.0
    circleBodyDef.position.set(RandomFloat(xLo, xHi), RandomFloat(yLo, yHi))
    
    let body6 = world.createBody(circleBodyDef)
    body6.createFixture(circleShapeDef)
  }
  
  override func step() {
    // We are going to destroy some bodies according to contact
    // points. We must buffer the bodies that should be destroyed
    // because they may belong to multiple contact points.
    let k_maxNuke = 6
    var nuke = [b2Body]()
    let nukeCount = 0
    
    // Traverse the contact results. Destroy bodies that
    // are touching heavier bodies.
    for i in 0 ..< contactListener.m_points.count {
      let point = contactListener.m_points[i]
      
      let body1 = point.fixtureA!.body
      let body2 = point.fixtureB!.body
      let mass1 = body1.mass
      let mass2 = body2.mass
      
      if mass1 > 0.0 && mass2 > 0.0 {
        if mass2 > mass1 {
          nuke.append(body1)
        }
        else {
          nuke.append(body2)
        }
        
        if nukeCount == k_maxNuke {
          break
        }
      }
    }
    
    // remove duplicated bodies
    var ar = [b2Body]()
    for e1 in nuke {
      var found = false
      for e2 in ar {
        if e1 === e2 {
          found = true
          break
        }
      }
      if !found {
        ar.append(e1)
      }
    }
    
    for b in nuke {
      if b !== bombLauncher.bomb {
        world.destroyBody(b)
      }
    }
  }
}
