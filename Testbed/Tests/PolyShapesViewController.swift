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

/// This tests stacking. It also shows how to use b2World::Query
/// and b2TestOverlap.

/// This callback is called by b2World::QueryAABB. We find all the fixtures
/// that overlap an AABB. Of those, we use b2TestOverlap to determine which fixtures
/// overlap a circle. Up to 4 overlapped fixtures will be highlighted with a yellow border.
class PolyShapesCallback: b2QueryCallback {
  let maxCount = 4
  
  var m_circle = b2CircleShape()
  var m_transform = b2Transform()
  var debugDraw: b2Draw!
  var m_count = 0

  func DrawFixture(fixture: b2Fixture) {
		let color = b2Color(0.95, 0.95, 0.6)
		let xf = fixture.body.transform
  
		switch fixture.type {
		case .circle:
      let circle = fixture.shape as! b2CircleShape
  
      let center = b2Mul(xf, circle.p)
      let radius = circle.radius
  
      debugDraw.drawCircle(center, radius, color)
  
		case .polygon:
      let poly = fixture.shape as! b2PolygonShape
      let vertexCount = poly.count
      assert(vertexCount <= b2_maxPolygonVertices)
      var vertices = [b2Vec2]()
  
      for i in 0 ..< vertexCount {
        vertices.append(b2Mul(xf, poly.vertices[i]))
      }
  
      debugDraw.drawPolygon(vertices, color)
  
		default:
      break
		}
  }
  
  /// Called for each fixture found in the query AABB.
  /// @return false to terminate the query.
  func reportFixture(fixture: b2Fixture) -> Bool {
    if m_count == self.maxCount {
      return false
    }
    
    let body = fixture.body
    let shape = fixture.shape
    
    let overlap = b2TestOverlap(shapeA: shape, indexA: 0,
      shapeB: m_circle, indexB: 0,
      transformA: body.transform, transformB: m_transform)
    
    if overlap {
      DrawFixture(fixture)
      ++m_count
    }
    
    return true
  }
}

class PolyShapesViewController: BaseViewController, TextListViewControllerDelegate {
  struct Const {
    static let maxBodies = 256
  }
  var m_dropVC = TextListViewController()
  var m_bodyIndex = 0
  var m_bodies = [b2Body?](count: Const.maxBodies, repeatedValue: nil)
  var m_polygons = [b2PolygonShape]()
  var m_circle: b2CircleShape!

  override func viewDidLoad() {
    super.viewDidLoad()

    m_dropVC.title = "Drop Object"
    m_dropVC.textListName = "Drop"
    m_dropVC.textList = ["1 (filtered)", "2", "3", "4", "5", "6"]
    m_dropVC.textListDelegate = self

    let dropStuffButton = UIBarButtonItem(title: "Drop", style: UIBarButtonItemStyle.Plain, target: self, action: "onDropStuff:")
    let modeChangeButton = UIBarButtonItem(title: "Activate", style: UIBarButtonItemStyle.Plain, target: self, action: "onActivate:")
    let deleteStuffButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "onDeleteStuff:")
    let flexibleButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    addToolbarItems([
      dropStuffButton, flexibleButton,
      modeChangeButton, flexibleButton,
      deleteStuffButton, flexibleButton
      ]);
  }
  
  func onDropStuff(sender: UIBarButtonItem) {
    m_dropVC.modalPresentationStyle = UIModalPresentationStyle.Popover
    var popPC = m_dropVC.popoverPresentationController
    popPC?.barButtonItem = sender
    popPC?.permittedArrowDirections = UIPopoverArrowDirection.Any
    self.presentViewController(m_dropVC, animated: true, completion: nil)
  }

  func onActivate(sender: UIBarButtonItem) {
    for (var i = 0; i < Const.maxBodies; i += 2) {
      if m_bodies[i] != nil {
        let active = m_bodies[i]!.isActive
        m_bodies[i]!.setActive(!active)
      }
    }
  }
  
  func onDeleteStuff(sender: UIBarButtonItem) {
    destroyBody()
  }
  
  override func prepare() {
		// Ground body
		b2Locally {
      let bd = b2BodyDef()
      let ground = world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
      ground.createFixture(shape: shape, density: 0.0)
		}
  
		b2Locally {
      var vertices = [b2Vec2]()
      vertices.append(b2Vec2(-0.5, 0.0))
      vertices.append(b2Vec2(0.5, 0.0))
      vertices.append(b2Vec2(0.0, 1.5))
      let shape = b2PolygonShape()
      shape.set(vertices: vertices)
      self.m_polygons.append(shape)
    }
    
    b2Locally {
      var vertices = [b2Vec2]()
      vertices.append(b2Vec2(-0.1, 0.0))
      vertices.append(b2Vec2(0.1, 0.0))
      vertices.append(b2Vec2(0.0, 1.5))
      let shape = b2PolygonShape()
      shape.set(vertices: vertices)
      self.m_polygons.append(shape)
		}
  
		b2Locally {
      let w: b2Float = 1.0
      let b: b2Float = w / (2.0 + sqrt(2.0))
      let s: b2Float = sqrt(2.0) * b
    
      var vertices = [b2Vec2]()
      vertices.append(b2Vec2(0.5 * s, 0.0))
      vertices.append(b2Vec2(0.5 * w, b))
      vertices.append(b2Vec2(0.5 * w, b + s))
      vertices.append(b2Vec2(0.5 * s, w))
      vertices.append(b2Vec2(-0.5 * s, w))
      vertices.append(b2Vec2(-0.5 * w, b + s))
      vertices.append(b2Vec2(-0.5 * w, b))
      vertices.append(b2Vec2(-0.5 * s, 0.0))
    
      let shape = b2PolygonShape()
      shape.set(vertices: vertices)
      self.m_polygons.append(shape)
    }
    
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.5, halfHeight: 0.5)
      self.m_polygons.append(shape)
		}
  
		b2Locally {
      self.m_circle = b2CircleShape()
      self.m_circle.radius = 0.5
		}
  
		m_bodyIndex = 0
  }
  
  func create(index: Int) {
		if m_bodies[m_bodyIndex] != nil {
      world.destroyBody(m_bodies[m_bodyIndex]!)
      m_bodies[m_bodyIndex] = nil
		}
  
		let bd = b2BodyDef()
		bd.type = b2BodyType.dynamicBody
  
		let x = RandomFloat(-2.0, 2.0)
		bd.position.set(x, 10.0)
		bd.angle = RandomFloat(-b2_pi, b2_pi)
  
		if index == 4 {
      bd.angularDamping = 0.02
		}
  
		m_bodies[m_bodyIndex] = world.createBody(bd)
  
		if index < 4 {
      let fd = b2FixtureDef()
      fd.shape = m_polygons[index]
      fd.density = 1.0
      fd.friction = 0.3
      m_bodies[m_bodyIndex]!.createFixture(fd)
		}
		else {
      let fd = b2FixtureDef()
      fd.shape = m_circle
      fd.density = 1.0
      fd.friction = 0.3
  
      m_bodies[m_bodyIndex]!.createFixture(fd)
		}
  
		m_bodyIndex = (m_bodyIndex + 1) % Const.maxBodies
  }
  
  func destroyBody() {
		for i in 0 ..< Const.maxBodies {
      if m_bodies[i] != nil {
        world.destroyBody(m_bodies[i]!);
        m_bodies[i] = nil
        return
      }
		}
  }

  override func step() {
    let callback = PolyShapesCallback()
    callback.m_circle.radius = 2.0
    callback.m_circle.p.set(0.0, 1.1)
    callback.m_transform.setIdentity()
    callback.debugDraw = debugDraw
    
    var aabb = b2AABB()
    callback.m_circle.computeAABB(&aabb, transform: callback.m_transform, childIndex: 0)
    
    world.queryAABB(callback: callback, aabb: aabb)
    
    let color = b2Color(0.4, 0.7, 0.8)
    debugDraw.drawCircle(callback.m_circle.p, callback.m_circle.radius, color)
  }
 
  func textListDidSelect(#name: String, index: Int) {
    self.dismissViewControllerAnimated(true, completion: nil)
    if name == "Drop" {
      create(index)
    }
  }

}
