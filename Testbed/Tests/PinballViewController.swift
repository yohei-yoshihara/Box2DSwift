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

class PinballViewController: BaseViewController {
  var leftJoint: b2RevoluteJoint!
  var rightJoint: b2RevoluteJoint!
  var ball: b2Body!
  var button = false

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let switchButton = UIBarButtonItem(title: "On/Off", style: UIBarButtonItemStyle.Plain, target: self, action: "onSwitch:")
    let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    self.addToolbarItems([switchButton, flexible])
  }
  
  func onSwitch(sender: UIBarButtonItem) {
    button = !button
  }
  
  override func prepare() {
    // Ground body
    var ground: b2Body! = nil
    b2Locally {
      let bd = b2BodyDef()
      ground = self.world.createBody(bd)
      
      var vs = [b2Vec2]()
      vs.append(b2Vec2(0.0, -2.0))
      vs.append(b2Vec2(8.0, 6.0))
      vs.append(b2Vec2(8.0, 20.0))
      vs.append(b2Vec2(-8.0, 20.0))
      vs.append(b2Vec2(-8.0, 6.0))
      
      let loop = b2ChainShape()
      loop.createLoop(vertices:vs)
      let fd = b2FixtureDef()
      fd.shape = loop
      fd.density = 0.0
      ground.createFixture(fd)
    }
    
    // Flippers
    b2Locally {
      let p1 = b2Vec2(-2.0, 0.0), p2 = b2Vec2(2.0, 0.0)
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      
      bd.position = p1
      let leftFlipper = self.world.createBody(bd)
      
      bd.position = p2
      let rightFlipper = self.world.createBody(bd)
      
      let box = b2PolygonShape()
      box.setAsBox(halfWidth: 1.75, halfHeight: 0.1)
      
      let fd = b2FixtureDef()
      fd.shape = box
      fd.density = 1.0
      
      leftFlipper.createFixture(fd)
      rightFlipper.createFixture(fd)
      
      let jd = b2RevoluteJointDef()
      jd.bodyA = ground
      jd.localAnchorB.setZero()
      jd.enableMotor = true
      jd.maxMotorTorque = 1000.0
      jd.enableLimit = true
      
      jd.motorSpeed = 0.0
      jd.localAnchorA = p1
      jd.bodyB = leftFlipper
      jd.lowerAngle = -30.0 * b2_pi / 180.0
      jd.upperAngle = 5.0 * b2_pi / 180.0
      self.leftJoint = self.world.createJoint(jd) as! b2RevoluteJoint
      
      jd.motorSpeed = 0.0
      jd.localAnchorA = p2
      jd.bodyB = rightFlipper
      jd.lowerAngle = -5.0 * b2_pi / 180.0
      jd.upperAngle = 30.0 * b2_pi / 180.0
      self.rightJoint = self.world.createJoint(jd) as! b2RevoluteJoint
    }
    
    // Circle character
    b2Locally {
      let bd = b2BodyDef()
      bd.position.set(1.0, 15.0)
      bd.type = b2BodyType.dynamicBody
      bd.bullet = true
      
      self.ball = self.world.createBody(bd)
      
      let shape = b2CircleShape()
      shape.radius = 0.2
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 1.0
      self.ball.createFixture(fd)
    }
  }
  
  override func step() {
    if button {
      leftJoint.setMotorSpeed(20.0)
      rightJoint.setMotorSpeed(-20.0)
    }
    else {
      leftJoint.setMotorSpeed(-10.0)
      rightJoint.setMotorSpeed(10.0)
    }
  }
  
}
