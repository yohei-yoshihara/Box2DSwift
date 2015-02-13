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

class ShapeEditingViewController: BaseViewController {
  var m_body: b2Body!
  var m_fixture1: b2Fixture!
  var m_fixture2: b2Fixture? = nil
  var m_sensor = false

  override func viewDidLoad() {
    super.viewDidLoad()
    let createButton = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.Plain, target: self, action: "onCreate:")
    let destroyButton = UIBarButtonItem(title: "Destroy", style: UIBarButtonItemStyle.Plain, target: self, action: "onDestroy:")
    let sensorButton = UIBarButtonItem(title: "Sensor", style: UIBarButtonItemStyle.Plain, target: self, action: "onSensor:")
    let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    self.addToolbarItems([
      createButton, flexible,
      destroyButton, flexible,
      sensorButton, flexible,
      ])
  }
  
  override func prepare() {
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    let bd = b2BodyDef()
    bd.type = b2BodyType.dynamicBody
    bd.position.set(0.0, 10.0)
    m_body = world.createBody(bd)
    
    let shape = b2PolygonShape()
    shape.setAsBox(halfWidth: 4.0, halfHeight: 4.0, center: b2Vec2(0.0, 0.0), angle: 0.0)
    m_fixture1 = m_body.createFixture(shape: shape, density: 10.0)
    
    m_fixture2 = nil
    
    m_sensor = false
  }
  
  func onCreate(sender: UIBarButtonItem) {
    if m_fixture2 == nil {
      let shape = b2CircleShape()
      shape.radius = 3.0
      shape.p.set(0.5, -4.0)
      m_fixture2 = m_body.createFixture(shape: shape, density: 10.0)
      m_body.setAwake(true)
    }
  }

  func onDestroy(sender: UIBarButtonItem) {
    if m_fixture2 != nil {
      m_body.destroyFixture(m_fixture2!)
      m_fixture2 = nil
      m_body.setAwake(true)
    }
  }

  func onSensor(sender: UIBarButtonItem) {
    if m_fixture2 != nil {
      m_sensor = !m_sensor
      m_fixture2!.setSensor(m_sensor)
    }
  }
}
