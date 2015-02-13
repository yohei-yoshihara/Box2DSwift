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

class Actor {
  var aabb = b2AABB()
  var fraction: b2Float = 0.0
  var overlap = false
  var proxyId = -1
}

class DynamicTreeTestViewController: BaseViewController, b2QueryWrapper, b2RayCastWrapper {
  let actorCount = 128
  
  var worldExtent: b2Float = 15.0
  var m_proxyExtent: b2Float = 0.5
  
  var m_tree = b2DynamicTree<Actor>()
  var m_queryAABB = b2AABB()
  var m_rayCastInput = b2RayCastInput()
  var m_rayCastOutput = b2RayCastOutput()
  var m_rayActor: Actor? = nil
  var m_actors = [Actor]()
  //  var stepCount = 0
  var m_automated = false
  var m_additionalInfoView: AdditionalInfoView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let autoButton = UIBarButtonItem(title: "Auto", style: UIBarButtonItemStyle.Plain, target: self, action: "onAuto:")
    let createButton = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.Plain, target: self, action: "onCreate:")
    let destroyButton = UIBarButtonItem(title: "Destroy", style: UIBarButtonItemStyle.Plain, target: self, action: "onDestroy:")
    let moveButton = UIBarButtonItem(title: "Move", style: UIBarButtonItemStyle.Plain, target: self, action: "onMove:")
    let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    self.addToolbarItems([
      autoButton, flexible,
      createButton, flexible,
      destroyButton, flexible,
      moveButton, flexible,
      ])
    
    m_additionalInfoView = AdditionalInfoView(frame: self.view.bounds)
    self.view.addSubview(m_additionalInfoView)
  }
  
  func onAuto(sender: UIBarButtonItem) {
    m_automated = !m_automated
  }
  
  func onCreate(sender: UIBarButtonItem) {
    CreateProxy()
  }

  func onDestroy(sender: UIBarButtonItem) {
    DestroyProxy()
  }

  func onMove(sender: UIBarButtonItem) {
    MoveProxy()
  }
  
  override func prepare() {
    for i in 0 ..< self.actorCount {
      var actor = Actor()
      GetRandomAABB(&actor.aabb)
      actor.proxyId = m_tree.createProxy(aabb: actor.aabb, userData: actor)
      m_actors.append(actor)
    }
    
    stepCount = 0
    
    let h = worldExtent
    m_queryAABB.lowerBound.set(-3.0, -4.0 + h);
    m_queryAABB.upperBound.set(5.0, 6.0 + h)
    
    m_rayCastInput.p1.set(-5.0, 5.0 + h)
    m_rayCastInput.p2.set(7.0, -4.0 + h)
    //m_rayCastInput.p1.set(0.0f, 2.0f + h);
    //m_rayCastInput.p2.set(0.0f, -2.0f + h);
    m_rayCastInput.maxFraction = 1.0
    
    m_automated = false
  }
  
  override func step() {
    m_rayActor = nil
    for actor in m_actors {
      actor.fraction = 1.0
      actor.overlap = false
    }
    
    if m_automated {
      let actionCount = max(1, self.actorCount >> 2)
      
      for i in 0 ..< actionCount {
        Action()
      }
    }
    
    Query()
    RayCast()
    
    for actor in m_actors {
      if actor.proxyId == b2_nullNode {
        continue
      }
      
      var c = b2Color(0.9, 0.9, 0.9)
      if actor === m_rayActor && actor.overlap {
        c.set(0.9, 0.6, 0.6)
      }
      else if actor === m_rayActor {
        c.set(0.6, 0.9, 0.6)
      }
      else if actor.overlap {
        c.set(0.6, 0.6, 0.9)
      }
      
      debugDraw.drawAABB(actor.aabb, c)
    }
    
    let c = b2Color(0.7, 0.7, 0.7)
    debugDraw.drawAABB(m_queryAABB, c)
    
    debugDraw.drawSegment(m_rayCastInput.p1, m_rayCastInput.p2, c)
    
    let c1 = b2Color(0.2, 0.9, 0.2)
    let c2 = b2Color(0.9, 0.2, 0.2)
    debugDraw.drawPoint(m_rayCastInput.p1, 6.0, c1)
    debugDraw.drawPoint(m_rayCastInput.p2, 6.0, c2)
    
    if m_rayActor != nil {
      let cr = b2Color(0.2, 0.2, 0.9)
      let p = m_rayCastInput.p1 + m_rayActor!.fraction * (m_rayCastInput.p2 - m_rayCastInput.p1)
      debugDraw.drawPoint(p, 6.0, cr);
    }
    
    b2Locally {
      let height = m_tree.getHeight()
      
      self.m_additionalInfoView.begin()
      self.m_additionalInfoView.append(String(format: "dynamic tree height = %d", height))
      self.m_additionalInfoView.end()
    }
  }
  
  func queryCallback(proxyId: Int) -> Bool {
    var actor = m_tree.getUserData(proxyId)! as Actor
    actor.overlap = b2TestOverlap(m_queryAABB, actor.aabb)
    return true
  }
  
  func rayCastCallback(input: b2RayCastInput, _ proxyId: Int) -> b2Float {
    var actor = m_tree.getUserData(proxyId)! as Actor
    
    let output = actor.aabb.rayCast(input)
    
    if output != nil {
      m_rayCastOutput = output!
      m_rayActor = actor
      m_rayActor!.fraction = output!.fraction
      return output!.fraction
    }
    
    return input.maxFraction
  }
  
  func GetRandomAABB(inout aabb: b2AABB) {
    let w = b2Vec2(2.0 * m_proxyExtent, 2.0 * m_proxyExtent)
    //aabb->lowerBound.x = -m_proxyExtent;
    //aabb->lowerBound.y = -m_proxyExtent + worldExtent;
    aabb.lowerBound.x = RandomFloat(-worldExtent, worldExtent)
    aabb.lowerBound.y = RandomFloat(0.0, 2.0 * worldExtent)
    aabb.upperBound = aabb.lowerBound + w
  }
  
  func MoveAABB(inout aabb: b2AABB) {
    var d = b2Vec2()
    d.x = RandomFloat(-0.5, 0.5)
    d.y = RandomFloat(-0.5, 0.5)
    //d.x = 2.0f;
    //d.y = 0.0f;
    aabb.lowerBound += d
    aabb.upperBound += d
    
    let c0 = 0.5 * (aabb.lowerBound + aabb.upperBound)
    let min = b2Vec2(-worldExtent, 0.0)
    let max = b2Vec2(worldExtent, 2.0 * worldExtent)
    let c = b2Clamp(c0, min, max)
    
    aabb.lowerBound += c - c0
    aabb.upperBound += c - c0
  }
  
  func CreateProxy() {
    for i in 0 ..< self.actorCount {
      let j = Int(arc4random_uniform(UInt32(self.actorCount)))
      let actor = m_actors[j]
      if actor.proxyId == b2_nullNode {
        GetRandomAABB(&actor.aabb)
        actor.proxyId = m_tree.createProxy(aabb: actor.aabb, userData: actor)
        return
      }
    }
  }
  
  func DestroyProxy() {
    for i in 0 ..< self.actorCount {
      let j = Int(arc4random_uniform(UInt32(self.actorCount)))
      let actor = m_actors[j]
      if actor.proxyId != b2_nullNode {
        m_tree.destroyProxy(actor.proxyId)
        actor.proxyId = b2_nullNode
        return
      }
    }
  }
  
  func MoveProxy() {
    for i in 0 ..< self.actorCount {
      let j = Int(arc4random_uniform(UInt32(self.actorCount)))
      let actor = m_actors[j]
      if actor.proxyId == b2_nullNode {
        continue
      }
    
      let aabb0 = actor.aabb
      MoveAABB(&actor.aabb)
      let displacement = actor.aabb.center - aabb0.center
      m_tree.moveProxy(actor.proxyId, aabb: actor.aabb, displacement: displacement)
      return
    }
  }
  
  
  func Action() {
    let choice = Int(arc4random_uniform(20))
    
    switch choice {
    case 0:
      CreateProxy()
    case 1:
        DestroyProxy()
    default:
          MoveProxy()
    }
  }
  
  func Query() {
    m_tree.query(callback: self, aabb: m_queryAABB)
    
    for actor in m_actors {
      if actor.proxyId == b2_nullNode {
        continue
      }
      
      let overlap = b2TestOverlap(m_queryAABB, actor.aabb)
      assert(overlap == actor.overlap)
    }
  }
  
  func RayCast() {
    m_rayActor = nil
    
    var input = m_rayCastInput
    // Ray cast against the dynamic tree.
    m_tree.rayCast(callback: self, input: input)
    
    // Brute force ray cast.
    var bruteActor: Actor? = nil
    var bruteOutput: b2RayCastOutput? = nil
    for actor in m_actors {
      if actor.proxyId == b2_nullNode {
        continue
      }
      
      let output = actor.aabb.rayCast(input)
      if output != nil {
        bruteActor = actor
        bruteOutput = output!
        input.maxFraction = output!.fraction
      }
    }
    
    if bruteActor != nil {
      assert(bruteOutput!.fraction == m_rayCastOutput.fraction)
    }
  }
  
}
