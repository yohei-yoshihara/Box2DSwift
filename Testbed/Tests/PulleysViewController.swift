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

class PulleysViewController: BaseViewController {
  var joint1: b2PulleyJoint!
  var additionalInfoView: AdditionalInfoView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    additionalInfoView = AdditionalInfoView(frame: self.view.bounds)
    self.view.addSubview(additionalInfoView)
  }

  override func prepare() {
    let y: b2Float = 16.0
    let L: b2Float = 12.0
    let a: b2Float = 1.0
    let b: b2Float = 2.0
    
    var ground: b2Body! = nil
    b2Locally {
      let bd = b2BodyDef()
      ground = self.world.createBody(bd)
      
      let edge = b2EdgeShape()
      edge.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
      //ground->createFixture(&shape, 0.0f);
      
      let circle = b2CircleShape()
      circle.radius = 2.0
      
      circle.p.set(-10.0, y + b + L)
      ground.createFixture(shape: circle, density: 0.0)
      
      circle.p.set(10.0, y + b + L)
      ground.createFixture(shape: circle, density: 0.0)
    }
    
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: a, halfHeight: b)
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      
      //bd.fixedRotation = true;
      bd.position.set(-10.0, y)
      let body1 = world.createBody(bd)
      body1.createFixture(shape: shape, density: 5.0)
      
      bd.position.set(10.0, y)
      let body2 = world.createBody(bd)
      body2.createFixture(shape: shape, density: 5.0)
      
      let pulleyDef = b2PulleyJointDef()
      let anchor1 = b2Vec2(-10.0, y + b)
      let anchor2 = b2Vec2(10.0, y + b)
      let groundAnchor1 = b2Vec2(-10.0, y + b + L)
      let groundAnchor2 = b2Vec2(10.0, y + b + L)
      pulleyDef.initialize(body1, body2, groundAnchor1, groundAnchor2, anchor1, anchor2, 1.5)
      
      self.joint1 = self.world.createJoint(pulleyDef) as! b2PulleyJoint
    }
  }
  
  override func step() {
    additionalInfoView.begin()
    let ratio = joint1.ratio
    let L = joint1.currentLengthA + ratio * joint1.currentLengthB
    additionalInfoView.append(String(format:"L1 + %4.2f * L2 = %4.2f", ratio, L))
    additionalInfoView.end()
  }

}
