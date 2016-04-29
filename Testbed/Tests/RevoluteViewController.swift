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

class RevoluteViewController: BaseViewController {
  var ball: b2Body!
  var joint: b2RevoluteJoint!

  override func viewDidLoad() {
    super.viewDidLoad()
    let limitButton = UIBarButtonItem(title: "Limits", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(RevoluteViewController.onLimits(_:)))
    let motorButton = UIBarButtonItem(title: "Motor", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(RevoluteViewController.onMotor(_:)))
    let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    self.addToolbarItems([
      limitButton, flexible,
      motorButton, flexible
      ])
  }
  
  override func prepare() {
    var ground: b2Body! = nil
    b2Locally {
      let bd = b2BodyDef()
      ground = self.world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
      
      let fd = b2FixtureDef()
      fd.shape = shape
      //fd.filter.categoryBits = 2
      
      ground.createFixture(fd)
    }
    
    b2Locally {
      let shape = b2CircleShape()
      shape.radius = 0.5
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      
      let rjd = b2RevoluteJointDef()
      
      bd.position.set(-10.0, 20.0)
      let body = self.world.createBody(bd)
      body.createFixture(shape: shape, density: 5.0)
      
      let w: b2Float = 100.0
      body.setAngularVelocity(w)
      body.setLinearVelocity(b2Vec2(-8.0 * w, 0.0))
      
      rjd.initialize(ground, bodyB: body, anchor: b2Vec2(-10.0, 12.0))
      rjd.motorSpeed = 1.0 * b2_pi
      rjd.maxMotorTorque = 10000.0
      rjd.enableMotor = false
      rjd.lowerAngle = -0.25 * b2_pi
      rjd.upperAngle = 0.5 * b2_pi
      rjd.enableLimit = true
      rjd.collideConnected = true
      
      self.joint = self.world.createJoint(rjd) as! b2RevoluteJoint
    }
    
    b2Locally {
      let circle_shape = b2CircleShape()
      circle_shape.radius = 3.0
      
      let circle_bd = b2BodyDef()
      circle_bd.type = b2BodyType.dynamicBody
      circle_bd.position.set(5.0, 30.0)
      
      let fd = b2FixtureDef()
      fd.density = 5.0
      fd.filter.maskBits = 1
      fd.shape = circle_shape
      
      self.ball = self.world.createBody(circle_bd)
      self.ball.createFixture(fd);
      
      let polygon_shape = b2PolygonShape()
      polygon_shape.setAsBox(halfWidth: 10.0, halfHeight: 0.2, center: b2Vec2(-10.0, 0.0), angle: 0.0)
      
      let polygon_bd = b2BodyDef()
      polygon_bd.position.set(20.0, 10.0)
      polygon_bd.type = b2BodyType.dynamicBody
      polygon_bd.bullet = true
      let polygon_body = self.world.createBody(polygon_bd)
      polygon_body.createFixture(shape: polygon_shape, density: 2.0)
      
      let rjd = b2RevoluteJointDef()
      rjd.initialize(ground, bodyB: polygon_body, anchor: b2Vec2(20.0, 10.0))
      rjd.lowerAngle = -0.25 * b2_pi
      rjd.upperAngle = 0.0 * b2_pi
      rjd.enableLimit = true
      self.world.createJoint(rjd)
    }
    
    // Tests mass computation of a small object far from the origin
    b2Locally {
      let bodyDef = b2BodyDef()
      bodyDef.type = b2BodyType.dynamicBody
      let body = self.world.createBody(bodyDef)
      
      let polyShape = b2PolygonShape()
      var verts = [b2Vec2]()
      verts.append(b2Vec2(17.63, 36.31))
      verts.append(b2Vec2(17.52, 36.69))
      verts.append(b2Vec2(17.19, 36.36))
      polyShape.set(vertices: verts)
      
      let polyFixtureDef = b2FixtureDef()
      polyFixtureDef.shape = polyShape
      polyFixtureDef.density = 1
    
      body.createFixture(polyFixtureDef)	//assertion hits inside here
    }
  }
  
  override func step() {
  }
  
  func onLimits(sender: UIBarButtonItem) {
    joint.enableLimit(!joint.isLimitEnabled)
  }
  
  func onMotor(sender: UIBarButtonItem) {
    joint.enableMotor(!joint.isMotorEnabled)
  }
}
