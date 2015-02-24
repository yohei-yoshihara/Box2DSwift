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

class EdgeShapesCallback : b2RayCastCallback {
  var fixture: b2Fixture? = nil
  var point = b2Vec2()
  var normal = b2Vec2()
  
  func reportFixture(fixture: b2Fixture, point: b2Vec2, normal: b2Vec2, fraction: b2Float) -> b2Float {
    self.fixture = fixture
    self.point = point
    self.normal = normal
    return fraction
  }
}

class EdgeShapesViewController: BaseViewController, TextListViewControllerDelegate {
  struct Const {
    static let maxBodies = 256
  }
  var dropVC = TextListViewController()
  var bodyIndex = 0
  var bodies = [b2Body?](count: Const.maxBodies, repeatedValue: nil)
  var polygons = [b2PolygonShape]()
  var circle: b2CircleShape!
  var angle: b2Float = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dropVC.title = "Drop Object"
    dropVC.textListName = "Drop"
    dropVC.textList = ["1", "2", "3", "4", "5", "6"]
    dropVC.textListDelegate = self
    
    let dropStuffButton = UIBarButtonItem(title: "Drop", style: UIBarButtonItemStyle.Plain, target: self, action: "onDropStuff:")
    let deleteStuffButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "onDeleteStuff:")
    let flexibleButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    addToolbarItems([
      dropStuffButton, flexibleButton,
      deleteStuffButton, flexibleButton
      ]);
  }

  override func prepare() {
    // Ground body
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
      var x1: b2Float = -20.0
      var y1: b2Float = 2.0 * cos(x1 / 10.0 * b2_pi)
      for i in 0 ..< 80 {
        let x2 = x1 + 0.5
        let y2 = 2.0 * cos(x2 / 10.0 * b2_pi)
        
        let shape = b2EdgeShape()
        shape.set(vertex1: b2Vec2(x1, y1), vertex2: b2Vec2(x2, y2))
        ground.createFixture(shape: shape, density: 0.0)
        
        x1 = x2
        y1 = y2
      }
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
    angle = 0.0
  }
  
  func create(index: Int) {
		if bodies[bodyIndex] != nil {
      world.destroyBody(bodies[bodyIndex]!)
      bodies[bodyIndex] = nil
		}
  
		let bd = b2BodyDef()
		let x = RandomFloat(-10.0, 10.0)
		let y = RandomFloat(10.0, 20.0)
		bd.position.set(x, y)
		bd.angle = RandomFloat(-b2_pi, b2_pi)
		bd.type = b2BodyType.dynamicBody
  
		if index == 4 {
      bd.angularDamping = 0.02
		}
  
		bodies[bodyIndex] = world.createBody(bd)
  
		if index < 4 {
      let fd = b2FixtureDef()
      fd.shape = polygons[index]
      fd.friction = 0.3
      fd.density = 20.0
      bodies[bodyIndex]!.createFixture(fd)
		}
		else {
      let fd = b2FixtureDef()
      fd.shape = circle
      fd.friction = 0.3
      fd.density = 20.0
      bodies[bodyIndex]!.createFixture(fd)
		}
		bodyIndex = (bodyIndex + 1) % Const.maxBodies
  }
  
  func destroyBody() {
		for i in 0 ..< Const.maxBodies {
      if bodies[i] != nil {
        world.destroyBody(bodies[i]!)
        bodies[i] = nil
        return
      }
    }
  }

  override func step() {
		let advanceRay = settings.pause == false || settings.singleStep
  
		let L: b2Float = 25.0
		let point1 = b2Vec2(0.0, 10.0)
		let d = b2Vec2(L * cos(angle), -L * abs(sin(angle)))
		let point2 = point1 + d
  
		let callback = EdgeShapesCallback()
  
    world.rayCast(callback: callback, point1: point1, point2: point2)
  
		if callback.fixture != nil {
      debugDraw.drawPoint(callback.point, 5.0, b2Color(0.4, 0.9, 0.4))
      debugDraw.drawSegment(point1, callback.point, b2Color(0.8, 0.8, 0.8))
      let head = callback.point + 0.5 * callback.normal
      debugDraw.drawSegment(callback.point, head, b2Color(0.9, 0.9, 0.4))
		}
    else {
      debugDraw.drawSegment(point1, point2, b2Color(0.8, 0.8, 0.8))
		}
  
		if advanceRay {
      angle += 0.25 * b2_pi / 180.0
		}
  }

  func onDropStuff(sender: UIBarButtonItem) {
    dropVC.modalPresentationStyle = UIModalPresentationStyle.Popover
    var popPC = dropVC.popoverPresentationController
    popPC?.barButtonItem = sender
    popPC?.permittedArrowDirections = UIPopoverArrowDirection.Any
    self.presentViewController(dropVC, animated: true, completion: nil)
  }
  
  func onDeleteStuff(sender: UIBarButtonItem) {
    destroyBody()
  }

  func textListDidSelect(#name: String, index: Int) {
    self.dismissViewControllerAnimated(true, completion: nil)
    if name == "Drop" {
      create(index)
    }
  }
}


