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

class PrismaticViewController: BaseViewController {
  var joint: b2PrismaticJoint!
  var additionalInfoView: AdditionalInfoView!

  override func viewDidLoad() {
    super.viewDidLoad()
    additionalInfoView = AdditionalInfoView(frame: self.view.bounds)
    self.view.addSubview(additionalInfoView)
  }
  
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
      shape.setAsBox(halfWidth: 2.0, halfHeight: 0.5)
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(-10.0, 10.0)
      bd.angle = 0.5 * b2_pi
      bd.allowSleep = false
      let body = self.world.createBody(bd)
      body.createFixture(shape: shape, density: 5.0)
      
      let pjd = b2PrismaticJointDef()
      
      // Bouncy limit
      var axis = b2Vec2(2.0, 1.0)
      axis.normalize()
      pjd.initialize(bodyA: ground, bodyB: body, anchor: b2Vec2(0.0, 0.0), axis: axis)
      
      // Non-bouncy limit
      //pjd.initialize(ground, body, b2Vec2(-10.0f, 10.0f), b2Vec2(1.0f, 0.0f));
      
      pjd.motorSpeed = 10.0
      pjd.maxMotorForce = 10000.0
      pjd.enableMotor = true
      pjd.lowerTranslation = 0.0
      pjd.upperTranslation = 20.0
      pjd.enableLimit = true
      
      self.joint = self.world.createJoint(pjd) as! b2PrismaticJoint
    }
  }
  
  override func step() {
    let force = joint.getMotorForce(inverseTimeStep: settings.hz)
    additionalInfoView.begin()
    additionalInfoView.append(String(format: "Motor Force = %4.0f", force))
    additionalInfoView.end()
  }
  
}
