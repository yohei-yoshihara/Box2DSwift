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

class TheoJansenViewController: BaseViewController {
  var offset = b2Vec2()
  var chassis: b2Body!
  var wheel: b2Body!
  var motorJoint: b2RevoluteJoint!
  var motorOn = false
  var motorSpeed: b2Float = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let left = UIBarButtonItem(title: "Left", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TheoJansenViewController.onLeft(_:)))
    let brake = UIBarButtonItem(title: "Brake", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TheoJansenViewController.onBrake(_:)))
    let right = UIBarButtonItem(title: "Right", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TheoJansenViewController.onRight(_:)))
    let motor = UIBarButtonItem(title: "Motor", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TheoJansenViewController.onMotor(_:)))
    let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    self.addToolbarItems([
      left, flexible,
      brake, flexible,
      right, flexible,
      motor, flexible,
      ])
  }
  
  @objc func onLeft(_ sender: UIBarButtonItem) {
    motorJoint.setMotorSpeed(-motorSpeed)
  }

  @objc func onBrake(_ sender: UIBarButtonItem) {
    motorJoint.setMotorSpeed(0.0)
  }

  @objc func onRight(_ sender: UIBarButtonItem) {
    motorJoint.setMotorSpeed(motorSpeed)
  }

  @objc func onMotor(_ sender: UIBarButtonItem) {
    motorJoint.enableMotor(!motorJoint.isMotorEnabled)
  }

  func createLeg(_ s: b2Float, wheelAnchor: b2Vec2) {
		let p1 = b2Vec2(5.4 * s, -6.1)
		let p2 = b2Vec2(7.2 * s, -1.2)
		let p3 = b2Vec2(4.3 * s, -1.9)
		let p4 = b2Vec2(3.1 * s, 0.8)
		let p5 = b2Vec2(6.0 * s, 1.5)
		let p6 = b2Vec2(2.5 * s, 3.7)
  
		let fd1 = b2FixtureDef(), fd2 = b2FixtureDef()
		fd1.filter.groupIndex = -1
		fd2.filter.groupIndex = -1
		fd1.density = 1.0
		fd2.density = 1.0
  
		let poly1 = b2PolygonShape(), poly2 = b2PolygonShape()
  
		if s > 0.0 {
      var vertices = [b2Vec2]()
      vertices.append(p1)
      vertices.append(p2)
      vertices.append(p3)
      poly1.set(vertices: vertices)
  
      vertices.removeAll()
      vertices.append(b2Vec2_zero)
      vertices.append(p5 - p4)
      vertices.append(p6 - p4)
      poly2.set(vertices: vertices)
		}
		else {
      var vertices = [b2Vec2]()
      vertices.append(p1)
      vertices.append(p3)
      vertices.append(p2)
      poly1.set(vertices: vertices)
  
      vertices.removeAll()
      vertices.append(b2Vec2_zero)
      vertices.append(p6 - p4)
      vertices.append(p5 - p4)
      poly2.set(vertices: vertices)
		}
  
		fd1.shape = poly1
		fd2.shape = poly2
  
		let bd1 = b2BodyDef(), bd2 = b2BodyDef()
		bd1.type = b2BodyType.dynamicBody
		bd2.type = b2BodyType.dynamicBody
		bd1.position = offset
		bd2.position = p4 + offset
  
		bd1.angularDamping = 10.0
		bd2.angularDamping = 10.0
  
		let body1 = world.createBody(bd1)
		let body2 = world.createBody(bd2)
  
		body1.createFixture(fd1)
		body2.createFixture(fd2)
  
		let djd = b2DistanceJointDef()
  
		// Using a soft distance constraint can reduce some jitter.
		// It also makes the structure seem a bit more fluid by
		// acting like a suspension system.
		djd.dampingRatio = 0.5
		djd.frequencyHz = 10.0
  
    djd.initialize(bodyA: body1, bodyB: body2, anchorA: p2 + offset, anchorB: p5 + offset)
		world.createJoint(djd)
  
    djd.initialize(bodyA: body1, bodyB: body2, anchorA: p3 + offset, anchorB: p4 + offset)
		world.createJoint(djd)
  
    djd.initialize(bodyA: body1, bodyB: wheel, anchorA: p3 + offset, anchorB: wheelAnchor + offset)
		world.createJoint(djd)
  
    djd.initialize(bodyA: body2, bodyB: wheel, anchorA: p6 + offset, anchorB: wheelAnchor + offset)
		world.createJoint(djd)
  
		let rjd = b2RevoluteJointDef()
    rjd.initialize(body2, bodyB: chassis, anchor: p4 + offset)
		world.createJoint(rjd)
  }

  override func prepare() {
    offset.set(0.0, 8.0)
    motorSpeed = 2.0
    motorOn = true
    let pivot = b2Vec2(0.0, 0.8)
    
    // Ground
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-50.0, 0.0), vertex2: b2Vec2(50.0, 0.0))
      ground.createFixture(shape: shape, density: 0.0)
      
      shape.set(vertex1: b2Vec2(-50.0, 0.0), vertex2: b2Vec2(-50.0, 10.0))
      ground.createFixture(shape: shape, density: 0.0)
      
      shape.set(vertex1: b2Vec2(50.0, 0.0), vertex2: b2Vec2(50.0, 10.0))
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    // Balls
    for i in 0 ..< 40 {
      let shape = b2CircleShape()
      shape.radius = 0.25
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(-40.0 + 2.0 * b2Float(i), 0.5)
      
      let body = world.createBody(bd);
      body.createFixture(shape: shape, density: 1.0)
    }
    
    // Chassis
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 2.5, halfHeight: 1.0)
      
      let sd = b2FixtureDef()
      sd.density = 1.0
      sd.shape = shape
      sd.filter.groupIndex = -1
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position = pivot + self.offset
      self.chassis = self.world.createBody(bd)
      self.chassis.createFixture(sd)
    }
    
    b2Locally {
      let shape = b2CircleShape()
      shape.radius = 1.6
      
      let sd = b2FixtureDef()
      sd.density = 1.0
      sd.shape = shape
      sd.filter.groupIndex = -1
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position = pivot + self.offset
      self.wheel = self.world.createBody(bd)
      self.wheel.createFixture(sd)
    }
    
    b2Locally {
      let jd = b2RevoluteJointDef()
      jd.initialize(self.wheel, bodyB: self.chassis, anchor: pivot + self.offset)
      jd.collideConnected = false
      jd.motorSpeed = self.motorSpeed
      jd.maxMotorTorque = 400.0
      jd.enableMotor = self.motorOn
      self.motorJoint = self.world.createJoint(jd)
    }
    
    var wheelAnchor = b2Vec2()
    
    wheelAnchor = pivot + b2Vec2(0.0, -0.8)
    
    createLeg(-1.0, wheelAnchor: wheelAnchor)
    createLeg(1.0, wheelAnchor: wheelAnchor)
    
    wheel.setTransform(position: self.wheel.position, angle: 120.0 * b2_pi / 180.0)
    createLeg(-1.0, wheelAnchor: wheelAnchor)
    createLeg(1.0, wheelAnchor: wheelAnchor)
    
    wheel.setTransform(position: self.wheel.position, angle: -120.0 * b2_pi / 180.0)
    createLeg(-1.0, wheelAnchor: wheelAnchor)
    createLeg(1.0, wheelAnchor: wheelAnchor)
  }
  
}
