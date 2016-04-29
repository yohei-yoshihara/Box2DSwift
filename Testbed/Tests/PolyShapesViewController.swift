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
  
  var circle = b2CircleShape()
  var transform = b2Transform()
  var debugDraw: b2Draw!
  var count = 0

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
    if count == self.maxCount {
      return false
    }
    
    let body = fixture.body
    let shape = fixture.shape
    
    let overlap = b2TestOverlap(shapeA: shape, indexA: 0,
      shapeB: circle, indexB: 0,
      transformA: body.transform, transformB: transform)
    
    if overlap {
      DrawFixture(fixture)
      count += 1
    }
    
    return true
  }
}

class PolyShapesViewController: BaseViewController, TextListViewControllerDelegate {
  struct Const {
    static let maxBodies = 256
  }
  var dropVC = TextListViewController()
  var bodyIndex = 0
  var bodies = [b2Body?](count: Const.maxBodies, repeatedValue: nil)
  var polygons = [b2PolygonShape]()
  var circle: b2CircleShape!

  override func viewDidLoad() {
    super.viewDidLoad()

    dropVC.title = "Drop Object"
    dropVC.textListName = "Drop"
    dropVC.textList = ["1 (filtered)", "2", "3", "4", "5", "6"]
    dropVC.textListDelegate = self

    let dropStuffButton = UIBarButtonItem(title: "Drop", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PolyShapesViewController.onDropStuff(_:)))
    let modeChangeButton = UIBarButtonItem(title: "Activate", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PolyShapesViewController.onActivate(_:)))
    let deleteStuffButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: #selector(PolyShapesViewController.onDeleteStuff(_:)))
    let flexibleButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    addToolbarItems([
      dropStuffButton, flexibleButton,
      modeChangeButton, flexibleButton,
      deleteStuffButton, flexibleButton
      ]);
  }
  
  func onDropStuff(sender: UIBarButtonItem) {
    dropVC.modalPresentationStyle = UIModalPresentationStyle.Popover
    let popPC = dropVC.popoverPresentationController
    popPC?.barButtonItem = sender
    popPC?.permittedArrowDirections = UIPopoverArrowDirection.Any
    self.presentViewController(dropVC, animated: true, completion: nil)
  }

  func onActivate(sender: UIBarButtonItem) {
    var i = 0
    while i < Const.maxBodies
    {
        if bodies[i] != nil {
            let active = bodies[i]!.isActive
            bodies[i]!.setActive(!active)
        }

        i += 2
    }
  }
  
  func onDeleteStuff(sender: UIBarButtonItem) {
    destroyBody()
  }
  
  override func prepare() {
		// Ground body
		b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
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
      self.polygons.append(shape)
    }
    
    b2Locally {
      var vertices = [b2Vec2]()
      vertices.append(b2Vec2(-0.1, 0.0))
      vertices.append(b2Vec2(0.1, 0.0))
      vertices.append(b2Vec2(0.0, 1.5))
      let shape = b2PolygonShape()
      shape.set(vertices: vertices)
      self.polygons.append(shape)
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
      self.polygons.append(shape)
    }
    
    b2Locally {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.5, halfHeight: 0.5)
      self.polygons.append(shape)
		}
  
		b2Locally {
      self.circle = b2CircleShape()
      self.circle.radius = 0.5
		}
  
		bodyIndex = 0
  }
  
  func create(index: Int) {
		if bodies[bodyIndex] != nil {
      world.destroyBody(bodies[bodyIndex]!)
      bodies[bodyIndex] = nil
		}
  
		let bd = b2BodyDef()
		bd.type = b2BodyType.dynamicBody
  
		let x = RandomFloat(-2.0, 2.0)
		bd.position.set(x, 10.0)
		bd.angle = RandomFloat(-b2_pi, b2_pi)
  
		if index == 4 {
      bd.angularDamping = 0.02
		}
  
		bodies[bodyIndex] = world.createBody(bd)
  
		if index < 4 {
      let fd = b2FixtureDef()
      fd.shape = polygons[index]
      fd.density = 1.0
      fd.friction = 0.3
      bodies[bodyIndex]!.createFixture(fd)
		}
		else {
      let fd = b2FixtureDef()
      fd.shape = circle
      fd.density = 1.0
      fd.friction = 0.3
  
      bodies[bodyIndex]!.createFixture(fd)
		}
  
		bodyIndex = (bodyIndex + 1) % Const.maxBodies
  }
  
  func destroyBody() {
		for i in 0 ..< Const.maxBodies {
      if bodies[i] != nil {
        world.destroyBody(bodies[i]!);
        bodies[i] = nil
        return
      }
		}
  }

  override func step() {
    let callback = PolyShapesCallback()
    callback.circle.radius = 2.0
    callback.circle.p.set(0.0, 1.1)
    callback.transform.setIdentity()
    callback.debugDraw = debugDraw
    
    var aabb = b2AABB()
    callback.circle.computeAABB(&aabb, transform: callback.transform, childIndex: 0)
    
    world.queryAABB(callback: callback, aabb: aabb)
    
    let color = b2Color(0.4, 0.7, 0.8)
    debugDraw.drawCircle(callback.circle.p, callback.circle.radius, color)
  }
 
  func textListDidSelect(name name: String, index: Int) {
    self.dismissViewControllerAnimated(true, completion: nil)
    if name == "Drop" {
      create(index)
    }
  }

}
