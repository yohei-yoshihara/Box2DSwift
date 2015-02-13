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

class TilesViewController: BaseViewController {
  let count = 10
  var m_fixtureCount = 0
  var m_createTime: b2Float = 0.0
  var m_additionalInfoView: AdditionalInfoView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    m_additionalInfoView = AdditionalInfoView(frame: self.view.bounds)
    self.view.addSubview(m_additionalInfoView)
  }

  override func prepare() {
    m_fixtureCount = 0
    var timer = b2Timer()
    
    b2Locally {
      let a: b2Float = 0.5
      var bd = b2BodyDef()
      bd.position.y = -a
      var ground = world.createBody(bd)
      
#if true
      let N = 200
      let M = 10
      var position = b2Vec2()
      position.y = 0.0
      for j in 0 ..< M {
        position.x = b2Float(-N) * a
        for i in 0 ..< N {
          var shape = b2PolygonShape()
          shape.setAsBox(halfWidth: a, halfHeight: a, center: position, angle: 0.0)
          ground.createFixture(shape: shape, density: 0.0)
          ++self.m_fixtureCount
          position.x += 2.0 * a
        }
        position.y -= 2.0 * a
      }
#else
      let N = 200
      let M = 10
      var position = b2Vec2()
      position.x = b2Float(-N) * a
      for i in 0 ..< N {
        position.y = 0.0
        for j in 0 ..< M {
          var shape = b2PolygonShape()
          shape.SetAsBox(a, a, position, 0.0)
          ground.createFixture(shape, 0.0)
          position.y -= 2.0 * a
        }
        position.x += 2.0 * a
      }
#endif
    }
    
    b2Locally {
      let a: b2Float = 0.5
      var shape = b2PolygonShape()
      shape.setAsBox(halfWidth: a, halfHeight: a)
      
      var x = b2Vec2(-7.0, 0.75)
      var y = b2Vec2()
      let deltaX = b2Vec2(0.5625, 1.25)
      let deltaY = b2Vec2(1.125, 0.0)
      
      for i in 0 ..< self.count {
        y = x
        
        for (var j = i; j < self.count; ++j) {
          var bd = b2BodyDef()
          bd.type = b2BodyType.dynamicBody
          bd.position = y
          
          //if (i == 0 && j == 0)
          //{
          //	bd.allowSleep = false;
          //}
          //else
          //{
          //	bd.allowSleep = true;
          //}
          
          var body = world.createBody(bd)
          body.createFixture(shape: shape, density: 5.0)
          ++self.m_fixtureCount
          y += deltaY
        }
        
        x += deltaX
      }
    }
    
    m_createTime = timer.milliseconds
  }
 
  override func step() {
    let cm = world.contactManager
    let height = cm.broadPhase.getTreeHeight()
    let leafCount = cm.broadPhase.getProxyCount()
    let minimumNodeCount = 2 * leafCount - 1
    let minimumHeight = ceil(log(b2Float(minimumNodeCount)) / log(2.0))
    
    m_additionalInfoView.begin()
    m_additionalInfoView.append(String(format: "dynamic tree height = %d, min = %d", height, Int(minimumHeight)))
    m_additionalInfoView.append(String(format: "create time = %6.2f ms, fixture count = %d",
      m_createTime, m_fixtureCount))
    m_additionalInfoView.end()
    
    //b2DynamicTree* tree = &world->m_contactManager.m_broadPhase.m_tree;
    
    //if (stepCount == 400)
    //{
    //	tree->RebuildBottomUp();
    //}
  }
}
