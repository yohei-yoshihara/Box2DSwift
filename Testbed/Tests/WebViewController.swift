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

class WebViewController: BaseViewController {
  var bodies = [b2Body?]()
  var joints = [b2Joint?]()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let destroyBody = UIBarButtonItem(title: "Destroy Body", style: UIBarButtonItemStyle.Plain, target: self, action: "onDestroyBody:")
    let destroyJoint = UIBarButtonItem(title: "Destroy Joint", style: UIBarButtonItemStyle.Plain, target: self, action: "onDestroyJoint:")
    let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    self.addToolbarItems([
      destroyBody, flexible,
      destroyJoint, flexible,
      ])
  }

  func ondestroyBody(sender: UIBarButtonItem) {
    for i in 0 ..< 4 {
      if bodies[i] != nil {
        world.destroyBody(bodies[i]!)
        bodies[i] = nil
        break
      }
    }
  }

  func ondestroyJoint(sender: UIBarButtonItem) {
    for i in 0 ..< 8 {
      if joints[i] != nil {
        world.destroyJoint(joints[i]!)
        joints[i] = nil
        break
      }
    }
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
      shape.setAsBox(halfWidth: 0.5, halfHeight: 0.5)
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      
      bd.position.set(-5.0, 5.0)
      self.bodies.append(self.world.createBody(bd))
      self.bodies.last!!.createFixture(shape: shape, density: 5.0)
      
      bd.position.set(5.0, 5.0)
      self.bodies.append(self.world.createBody(bd))
      self.bodies.last!!.createFixture(shape: shape, density: 5.0)
      
      bd.position.set(5.0, 15.0)
      self.bodies.append(self.world.createBody(bd))
      self.bodies.last!!.createFixture(shape: shape, density: 5.0)
      
      bd.position.set(-5.0, 15.0)
      self.bodies.append(self.world.createBody(bd))
      self.bodies.last!!.createFixture(shape: shape, density: 5.0)
      
      let jd = b2DistanceJointDef()
      var p1 = b2Vec2(), p2 = b2Vec2(), d = b2Vec2()
      
      jd.frequencyHz = 2.0
      jd.dampingRatio = 0.0
      
      jd.bodyA = ground
      jd.bodyB = self.bodies[0]
      jd.localAnchorA.set(-10.0, 0.0)
      jd.localAnchorB.set(-0.5, -0.5)
      p1 = jd.bodyA.getWorldPoint(jd.localAnchorA)
      p2 = jd.bodyB.getWorldPoint(jd.localAnchorB)
      d = p2 - p1
      jd.length = d.length()
      self.joints.append(self.world.createJoint(jd))
      
      jd.bodyA = ground
      jd.bodyB = self.bodies[1]
      jd.localAnchorA.set(10.0, 0.0)
      jd.localAnchorB.set(0.5, -0.5)
      p1 = jd.bodyA.getWorldPoint(jd.localAnchorA)
      p2 = jd.bodyB.getWorldPoint(jd.localAnchorB)
      d = p2 - p1
      jd.length = d.length()
      self.joints.append(self.world.createJoint(jd))
      
      jd.bodyA = ground
      jd.bodyB = self.bodies[2]
      jd.localAnchorA.set(10.0, 20.0)
      jd.localAnchorB.set(0.5, 0.5)
      p1 = jd.bodyA.getWorldPoint(jd.localAnchorA)
      p2 = jd.bodyB.getWorldPoint(jd.localAnchorB)
      d = p2 - p1
      jd.length = d.length()
      self.joints.append(self.world.createJoint(jd))
      
      jd.bodyA = ground
      jd.bodyB = self.bodies[3]
      jd.localAnchorA.set(-10.0, 20.0)
      jd.localAnchorB.set(-0.5, 0.5)
      p1 = jd.bodyA.getWorldPoint(jd.localAnchorA)
      p2 = jd.bodyB.getWorldPoint(jd.localAnchorB)
      d = p2 - p1
      jd.length = d.length()
      self.joints.append(self.world.createJoint(jd))
      
      jd.bodyA = self.bodies[0]
      jd.bodyB = self.bodies[1]
      jd.localAnchorA.set(0.5, 0.0)
      jd.localAnchorB.set(-0.5, 0.0)
      p1 = jd.bodyA.getWorldPoint(jd.localAnchorA)
      p2 = jd.bodyB.getWorldPoint(jd.localAnchorB)
      d = p2 - p1
      jd.length = d.length()
      self.joints.append(self.world.createJoint(jd))
      
      jd.bodyA = self.bodies[1]
      jd.bodyB = self.bodies[2]
      jd.localAnchorA.set(0.0, 0.5)
      jd.localAnchorB.set(0.0, -0.5)
      p1 = jd.bodyA.getWorldPoint(jd.localAnchorA)
      p2 = jd.bodyB.getWorldPoint(jd.localAnchorB)
      d = p2 - p1
      jd.length = d.length()
      self.joints.append(self.world.createJoint(jd))
      
      jd.bodyA = self.bodies[2]
      jd.bodyB = self.bodies[3]
      jd.localAnchorA.set(-0.5, 0.0)
      jd.localAnchorB.set(0.5, 0.0)
      p1 = jd.bodyA.getWorldPoint(jd.localAnchorA)
      p2 = jd.bodyB.getWorldPoint(jd.localAnchorB)
      d = p2 - p1
      jd.length = d.length()
      self.joints.append(self.world.createJoint(jd))
      
      jd.bodyA = self.bodies[3]
      jd.bodyB = self.bodies[0]
      jd.localAnchorA.set(0.0, -0.5)
      jd.localAnchorB.set(0.0, 0.5)
      p1 = jd.bodyA.getWorldPoint(jd.localAnchorA)
      p2 = jd.bodyB.getWorldPoint(jd.localAnchorB)
      d = p2 - p1
      jd.length = d.length()
      self.joints.append(self.world.createJoint(jd))
    }
  }
}
