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

// This is a test of collision filtering.
// There is a triangle, a box, and a circle.
// There are 6 shapes. 3 large and 3 small.
// The 3 small ones always collide.
// The 3 large ones never collide.
// The boxes don't collide with triangles (except if both are small).
class CollisionFilteringViewController: BaseViewController {
  struct Const {
    static let k_smallGroup: Int16 = 1
    static let k_largeGroup: Int16 = -1
    
    static let k_defaultCategory: UInt16 = 0x0001
    static let k_triangleCategory: UInt16 = 0x0002
    static let k_boxCategory: UInt16 = 0x0004
    static let k_circleCategory: UInt16 = 0x0008
    
    static let k_triangleMask: UInt16 = 0xFFFF
    static let k_boxMask: UInt16 = 0xFFFF ^ k_triangleCategory
    static let k_circleMask: UInt16 = 0xFFFF
  }
  
  override func prepare() {
    // Ground body
    b2Locally {
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
      
      let sd = b2FixtureDef()
      sd.shape = shape
      sd.friction = 0.3
      
      let bd = b2BodyDef()
      let ground = world.createBody(bd)
      ground.createFixture(sd)
    }
    
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
    
    triangleShapeDef.filter.groupIndex = Const.k_smallGroup
    triangleShapeDef.filter.categoryBits = Const.k_triangleCategory
    triangleShapeDef.filter.maskBits = Const.k_triangleMask
    
    let triangleBodyDef = b2BodyDef()
    triangleBodyDef.type = b2BodyType.dynamicBody
    triangleBodyDef.position.set(-5.0, 2.0)
    
    let body1 = world.createBody(triangleBodyDef)
    body1.createFixture(triangleShapeDef)
    
    // Large triangle (recycle definitions)
    vertices[0] *= 2.0
    vertices[1] *= 2.0
    vertices[2] *= 2.0
    polygon.set(vertices: vertices)
    triangleShapeDef.filter.groupIndex = Const.k_largeGroup
    triangleBodyDef.position.set(-5.0, 6.0)
    triangleBodyDef.fixedRotation = true // look at me!
    
    let body2 = world.createBody(triangleBodyDef)
    body2.createFixture(triangleShapeDef)
    
    b2Locally {
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(-5.0, 10.0)
      let body = world.createBody(bd)
      
      let p = b2PolygonShape()
      p.setAsBox(halfWidth: 0.5, halfHeight: 1.0)
      body.createFixture(shape: p, density: 1.0)
      
      let jd = b2PrismaticJointDef()
      jd.bodyA = body2
      jd.bodyB = body
      jd.enableLimit = true
      jd.localAnchorA.set(0.0, 4.0)
      jd.localAnchorB.setZero()
      jd.localAxisA.set(0.0, 1.0)
      jd.lowerTranslation = -1.0
      jd.upperTranslation = 1.0
      
      self.world.createJoint(jd)
    }
    
    // Small box
    polygon.setAsBox(halfWidth: 1.0, halfHeight: 0.5)
    let boxShapeDef = b2FixtureDef()
    boxShapeDef.shape = polygon
    boxShapeDef.density = 1.0
    boxShapeDef.restitution = 0.1
    
    boxShapeDef.filter.groupIndex = Const.k_smallGroup
    boxShapeDef.filter.categoryBits = Const.k_boxCategory
    boxShapeDef.filter.maskBits = Const.k_boxMask
    
    let boxBodyDef = b2BodyDef()
    boxBodyDef.type = b2BodyType.dynamicBody
    boxBodyDef.position.set(0.0, 2.0)
    
    let body3 = world.createBody(boxBodyDef)
    body3.createFixture(boxShapeDef)
    
    // Large box (recycle definitions)
    polygon.setAsBox(halfWidth: 2.0, halfHeight: 1.0)
    boxShapeDef.filter.groupIndex = Const.k_largeGroup
    boxBodyDef.position.set(0.0, 6.0)
    
    let body4 = world.createBody(boxBodyDef)
    body4.createFixture(boxShapeDef)
    
    // Small circle
    let circle = b2CircleShape()
    circle.radius = 1.0
    
    let circleShapeDef = b2FixtureDef()
    circleShapeDef.shape = circle
    circleShapeDef.density = 1.0
    
    circleShapeDef.filter.groupIndex = Const.k_smallGroup
    circleShapeDef.filter.categoryBits = Const.k_circleCategory
    circleShapeDef.filter.maskBits = Const.k_circleMask
    
    let circleBodyDef = b2BodyDef()
    circleBodyDef.type = b2BodyType.dynamicBody
    circleBodyDef.position.set(5.0, 2.0)
    
    let body5 = world.createBody(circleBodyDef)
    body5.createFixture(circleShapeDef)
    
    // Large circle
    circle.radius *= 2.0
    circleShapeDef.filter.groupIndex = Const.k_largeGroup
    circleBodyDef.position.set(5.0, 6.0)
    
    let body6 = world.createBody(circleBodyDef)
    body6.createFixture(circleShapeDef)
  }
  
}
