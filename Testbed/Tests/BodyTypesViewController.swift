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

class BodyTypesViewController: BaseViewController {
  var attachment: b2Body!
  var platform: b2Body!
  let speed: b2Float = 3.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let dynamicButton = UIBarButtonItem(title: "Dynamic", style: UIBarButtonItem.Style.plain, target: self, action: #selector(BodyTypesViewController.onDynamic(_:)))
    let staticButton = UIBarButtonItem(title: "Static", style: UIBarButtonItem.Style.plain, target: self, action: #selector(BodyTypesViewController.onStatic(_:)))
    let kinematicButton = UIBarButtonItem(title: "Kinematic", style: UIBarButtonItem.Style.plain, target: self, action: #selector(BodyTypesViewController.onKinematic(_:)))
    let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    self.addToolbarItems([
      dynamicButton, flexible,
      staticButton, flexible,
      kinematicButton, flexible
      ])
  }
  
  @objc func onDynamic(_ sender: UIBarButtonItem) {
    platform.setType(b2BodyType.dynamicBody)
  }

  @objc func onStatic(_ sender: UIBarButtonItem) {
    platform.setType(b2BodyType.staticBody)
  }

  @objc func onKinematic(_ sender: UIBarButtonItem) {
    platform.setType(b2BodyType.kinematicBody)
    platform.setLinearVelocity(b2Vec2(-speed, 0.0))
    platform.setAngularVelocity(0.0)
  }

  override func prepare() {
    var ground: b2Body! = nil
    b2Locally {
      let bd = b2BodyDef()
      ground = self.world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-20.0, 0.0), vertex2: b2Vec2(20.0, 0.0))
      
      let fd = b2FixtureDef()
      fd.shape = shape
      
      ground.createFixture(fd)
    }
    
    // Define attachment
    b2Locally {
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(0.0, 3.0)
      self.attachment = self.world.createBody(bd)
      
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.5, halfHeight: 2.0)
      self.attachment.createFixture(shape: shape, density: 2.0)
    }
    
    // Define platform
    b2Locally {
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(-4.0, 5.0)
      self.platform = self.world.createBody(bd)
      
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.5, halfHeight: 4.0, center: b2Vec2(4.0, 0.0), angle: 0.5 * b2_pi)
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.friction = 0.6
      fd.density = 2.0
      self.platform.createFixture(fd)
      
      let rjd = b2RevoluteJointDef()
      rjd.initialize(self.attachment, bodyB: self.platform, anchor: b2Vec2(0.0, 5.0))
      rjd.maxMotorTorque = 50.0
      rjd.enableMotor = true
      self.world.createJoint(rjd)
      
      let pjd = b2PrismaticJointDef()
      pjd.initialize(bodyA: ground, bodyB: self.platform, anchor: b2Vec2(0.0, 5.0), axis: b2Vec2(1.0, 0.0))
      
      pjd.maxMotorForce = 1000.0
      pjd.enableMotor = true
      pjd.lowerTranslation = -10.0
      pjd.upperTranslation = 10.0
      pjd.enableLimit = true
      
      self.world.createJoint(pjd)
    }
    
    // Create a payload
    b2Locally {
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(0.0, 8.0)
      let body = self.world.createBody(bd)
      
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.75, halfHeight: 0.75)
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.friction = 0.6
      fd.density = 2.0
      
      body.createFixture(fd)
    }
  }
  
  override func step() {
    // Drive the kinematic body.
    if platform.type == b2BodyType.kinematicBody {
      let p = platform.transform.p
      var v = platform.linearVelocity
    
      if (p.x < -10.0 && v.x < 0.0) || (p.x > 10.0 && v.x > 0.0) {
        v.x = -v.x
        platform.setLinearVelocity(v)
      }
    }
  }

}
