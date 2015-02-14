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

class GearViewController: BaseViewController {
  var joint1: b2RevoluteJoint!
  var joint2: b2RevoluteJoint!
  var joint3: b2PrismaticJoint!
  var joint4: b2GearJoint!
  var joint5: b2GearJoint!
  var additionalInfoView: AdditionalInfoView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    additionalInfoView = AdditionalInfoView(frame: self.view.bounds)
    self.view.addSubview(additionalInfoView)
  }
  
  override func prepare() {
    var ground: b2Body! = nil
    b2Locally {
      var bd = b2BodyDef()
      ground = self.world.createBody(bd)
      
      var shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(50.0, 0.0), vertex2: b2Vec2(-50.0, 0.0))
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    b2Locally {
      var circle1 = b2CircleShape()
      circle1.radius = 1.0
      
      var box = b2PolygonShape()
      box.setAsBox(halfWidth: 0.5, halfHeight: 5.0)
      
      var circle2 = b2CircleShape()
      circle2.radius = 2.0
      
      var bd1 = b2BodyDef()
      bd1.type = b2BodyType.staticBody
      bd1.position.set(10.0, 9.0)
      var body1 = world.createBody(bd1)
      body1.createFixture(shape: circle1, density: 5.0)
      
      var bd2 = b2BodyDef()
      bd2.type = b2BodyType.dynamicBody
      bd2.position.set(10.0, 8.0)
      var body2 = world.createBody(bd2)
      body2.createFixture(shape: box, density: 5.0)
      
      var bd3 = b2BodyDef()
      bd3.type = b2BodyType.dynamicBody
      bd3.position.set(10.0, 6.0)
      var body3 = world.createBody(bd3)
      body3.createFixture(shape: circle2, density: 5.0)
      
      var jd1 = b2RevoluteJointDef()
      jd1.initialize(body2, bodyB: body1, anchor: bd1.position)
      let joint1 = world.createJoint(jd1)
      
      var jd2 = b2RevoluteJointDef()
      jd2.initialize(body2, bodyB: body3, anchor: bd3.position)
      let joint2 = world.createJoint(jd2)
      
      var jd4 = b2GearJointDef()
      jd4.bodyA = body1
      jd4.bodyB = body3
      jd4.joint1 = joint1
      jd4.joint2 = joint2
      jd4.ratio = circle2.radius / circle1.radius
      self.world.createJoint(jd4)
    }
    
    b2Locally {
      var circle1 = b2CircleShape()
      circle1.radius = 1.0
      
      var circle2 = b2CircleShape()
      circle2.radius = 2.0
      
      var box = b2PolygonShape()
      box.setAsBox(halfWidth: 0.5, halfHeight: 5.0)
      
      var bd1 = b2BodyDef()
      bd1.type = b2BodyType.dynamicBody
      bd1.position.set(-3.0, 12.0)
      var body1 = world.createBody(bd1)
      body1.createFixture(shape: circle1, density: 5.0)
      
      var jd1 = b2RevoluteJointDef()
      jd1.bodyA = ground
      jd1.bodyB = body1
      jd1.localAnchorA = ground.getLocalPoint(bd1.position)
      jd1.localAnchorB = body1.getLocalPoint(bd1.position)
      jd1.referenceAngle = body1.angle - ground.angle
      self.joint1 = self.world.createJoint(jd1) as! b2RevoluteJoint
      
      var bd2 = b2BodyDef()
      bd2.type = b2BodyType.dynamicBody
      bd2.position.set(0.0, 12.0)
      var body2 = world.createBody(bd2)
      body2.createFixture(shape: circle2, density: 5.0)
      
      var jd2 = b2RevoluteJointDef()
      jd2.initialize(ground, bodyB: body2, anchor: bd2.position)
      self.joint2 = self.world.createJoint(jd2) as! b2RevoluteJoint
      
      var bd3 = b2BodyDef()
      bd3.type = b2BodyType.dynamicBody
      bd3.position.set(2.5, 12.0)
      var body3 = world.createBody(bd3)
      body3.createFixture(shape: box, density: 5.0)
      
      var jd3 = b2PrismaticJointDef()
      jd3.initialize(bodyA: ground, bodyB: body3, anchor: bd3.position, axis: b2Vec2(0.0, 1.0))
      jd3.lowerTranslation = -5.0
      jd3.upperTranslation = 5.0
      jd3.enableLimit = true
      
      self.joint3 = self.world.createJoint(jd3) as! b2PrismaticJoint
      
      var jd4 = b2GearJointDef()
      jd4.bodyA = body1
      jd4.bodyB = body2
      jd4.joint1 = self.joint1
      jd4.joint2 = self.joint2
      jd4.ratio = circle2.radius / circle1.radius
      self.joint4 = self.world.createJoint(jd4) as! b2GearJoint
      
      var jd5 = b2GearJointDef()
      jd5.bodyA = body2
      jd5.bodyB = body3
      jd5.joint1 = self.joint2
      jd5.joint2 = self.joint3
      jd5.ratio = -1.0 / circle2.radius
      self.joint5 = self.world.createJoint(jd5) as! b2GearJoint
    }
  }
  
  override func step() {
    additionalInfoView.begin()
    
    var ratio = joint4.ratio
    var value = joint1.jointAngle + ratio * joint2.jointAngle
    additionalInfoView.append(String(format: "theta1 + %4.2f * theta2 = %4.2f", ratio, value))
    
    ratio = joint5.ratio
    value = joint2.jointAngle + ratio * joint3.jointTranslation
    additionalInfoView.append(String(format: "theta1 + %4.2f * theta2 = %4.2f", ratio, value))
    
    additionalInfoView.end()
  }
  
}
