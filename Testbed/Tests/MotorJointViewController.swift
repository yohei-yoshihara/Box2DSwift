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

class MotorJointViewController: BaseViewController {
  var m_joint: b2MotorJoint!
  var m_time: b2Float = 0
  var m_go = false

  override func viewDidLoad() {
    super.viewDidLoad()
    let startButton = UIBarButtonItem(title: "Start", style: UIBarButtonItemStyle.Plain, target: self, action: "onStart:")
    let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    self.addToolbarItems([startButton, flexible])
  }
  
  override func prepare() {
    var ground: b2Body? = nil
    b2Locally {
      var bd = b2BodyDef()
      ground = self.world.createBody(bd)
      
      var shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-20.0, 0.0), vertex2: b2Vec2(20.0, 0.0))
      
      var fd = b2FixtureDef()
      fd.shape = shape
      
      ground!.createFixture(fd)
    }
    
    // Define motorized body
    b2Locally {
      var bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(0.0, 8.0)
      var body = self.world.createBody(bd)
      
      var shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 2.0, halfHeight: 0.5)
      
      var fd = b2FixtureDef()
      fd.shape = shape
      fd.friction = 0.6
      fd.density = 2.0
      body.createFixture(fd)
      
      var mjd = b2MotorJointDef()
      mjd.initialize(ground!, bodyB: body)
      mjd.maxForce = 1000.0
      mjd.maxTorque = 1000.0
      self.m_joint = self.world.createJoint(mjd) as! b2MotorJoint
    }
    
    m_go = false
    m_time = 0.0
  }
  

  func onStart(sender: UIBarButtonItem) {
    m_go = !m_go
  }
  
  override func step() {
    if m_go && settings.hz > 0.0 {
      m_time += 1.0 / settings.hz
    }
    
    var linearOffset = b2Vec2()
    linearOffset.x = 6.0 * sin(2.0 * m_time)
    linearOffset.y = 8.0 + 4.0 * sin(1.0 * m_time)
    
    var angularOffset = 4.0 * m_time
    
    m_joint!.setLinearOffset(linearOffset)
    m_joint!.setAngularOffset(angularOffset)
    
    debugDraw.drawPoint(linearOffset, 4.0, b2Color(0.9, 0.9, 0.9))
    
//    Test::Step(settings);
//    debugDraw.DrawString(5, m_textLine, "Keys: (s) pause");
//    m_textLine += 15;
  }
  
}
