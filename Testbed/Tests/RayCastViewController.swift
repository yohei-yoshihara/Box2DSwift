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

// This test demonstrates how to use the world ray-cast feature.
// NOTE: we are intentionally filtering one of the polygons, therefore
// the ray will always miss one type of polygon.

// This callback finds the closest hit. Polygon 0 is filtered.
class RayCastClosestCallback : b2RayCastCallback {
  func reportFixture(fixture: b2Fixture, point: b2Vec2, normal: b2Vec2, fraction: b2Float) -> b2Float {
    let body = fixture.body
    let userData: AnyObject? = body.userData
    if userData != nil {
      let index: Int = (userData! as! NSNumber).integerValue
      if index == 0 {
        // By returning -1, we instruct the calling code to ignore this fixture and
        // continue the ray-cast to the next fixture.
        return -1.0
      }
    }
    
    self.hit = true
    self.point = point
    self.normal = normal
    
    // By returning the current fraction, we instruct the calling code to clip the ray and
    // continue the ray-cast to the next fixture. WARNING: do not assume that fixtures
    // are reported in order. However, by clipping, we can always get the closest fixture.
    return fraction
  }
  
  var hit = false
  var point = b2Vec2()
  var normal = b2Vec2()
}

// This callback finds any hit. Polygon 0 is filtered. For this type of query we are usually
// just checking for obstruction, so the actual fixture and hit point are irrelevant.
class RayCastAnyCallback : b2RayCastCallback {
  func reportFixture(fixture: b2Fixture, point: b2Vec2, normal: b2Vec2, fraction: b2Float) -> b2Float {
    let body = fixture.body
    let userData: AnyObject? = body.userData
    if userData != nil {
      let index: Int = (userData as! NSNumber).integerValue
      if index == 0 {
        // By returning -1, we instruct the calling code to ignore this fixture
        // and continue the ray-cast to the next fixture.
        return -1.0
      }
    }
    
    self.hit = true
    self.point = point
    self.normal = normal
    
    // At this point we have a hit, so we know the ray is obstructed.
    // By returning 0, we instruct the calling code to terminate the ray-cast.
    return 0.0
  }
  
  var hit = false
  var point = b2Vec2()
  var normal = b2Vec2()
}

// This ray cast collects multiple hits along the ray. Polygon 0 is filtered.
// The fixtures are not necessary reported in order, so we might not capture
// the closest fixture.
class RayCastMultipleCallback : b2RayCastCallback {
  let maxCount = 3
  
  func reportFixture(fixture: b2Fixture, point: b2Vec2, normal: b2Vec2, fraction: b2Float) -> b2Float {
    let body = fixture.body
    let userData: AnyObject? = body.userData
    if userData != nil {
      let index: Int = (userData as! NSNumber).integerValue
      if index == 0 {
        // By returning -1, we instruct the calling code to ignore this fixture
        // and continue the ray-cast to the next fixture.
        return -1.0
      }
    }
    
    assert(self.count < maxCount)
    
    self.points.append(point)
    self.normals.append(normal)
    ++self.count;
    
    if count == maxCount {
      // At this point the buffer is full.
      // By returning 0, we instruct the calling code to terminate the ray-cast.
      return 0.0
    }
    
    // By returning 1, we instruct the caller to continue without clipping the ray.
    return 1.0
  }
  
  var points = [b2Vec2]()
  var normals = [b2Vec2]()
  var count = 0
}

class RayCastViewController: BaseViewController, TextListViewControllerDelegate {
  var dropVC = TextListViewController()
  var modeVC = TextListViewController()
  var bodies = [(b2Body, Int)]()
  var polygons = [b2PolygonShape]()
  var circle: b2CircleShape!
  var edge: b2EdgeShape!
  var angle: b2Float = 0.0
  enum Mode {
    case closest
    case any
    case multiple
  }
  var mode: Mode = Mode.closest
  
  override func viewDidLoad() {
    super.viewDidLoad()

    dropVC.title = "Drop Object"
    dropVC.textListName = "Drop"
    dropVC.textList = ["1 (filtered)", "2", "3", "4", "5", "6"]
    dropVC.textListDelegate = self
    
    modeVC.title = "Mode"
    modeVC.textListName = "Mode"
    modeVC.textList = ["Closest", "Any", "Multiple"]
    modeVC.textListDelegate = self
    
    let dropStuffButton = UIBarButtonItem(title: "Drop", style: UIBarButtonItemStyle.Plain, target: self, action: "onDropStuff:")
    let modeChangeButton = UIBarButtonItem(title: "Mode", style: UIBarButtonItemStyle.Plain, target: self, action: "onChangeMode:")
    let deleteStuffButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "onDeleteStuff:")
    let flexibleButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    addToolbarItems([
      dropStuffButton, flexibleButton,
      modeChangeButton, flexibleButton,
      deleteStuffButton, flexibleButton
      ]);
  }

  override func prepare() {
    // Ground body
    let bd = b2BodyDef()
    let ground = world.createBody(bd)
    let shape = b2EdgeShape()
    shape.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
    ground.createFixture(shape: shape, density: 0.0)
    
    // polygon 0
    let vertices0 = [
      b2Vec2(-0.5, 0.0),
      b2Vec2(0.5, 0.0),
      b2Vec2(0.0, 1.5)
    ]
    let polygon0 = b2PolygonShape()
    polygon0.set(vertices: vertices0)
    polygons.append(polygon0)
    
    // polygon 1
    let vertices1 = [
      b2Vec2(-0.1, 0.0),
      b2Vec2(0.1, 0.0),
      b2Vec2(0.0, 1.5)
    ]
    let polygon1 = b2PolygonShape()
    polygon1.set(vertices: vertices1)
    polygons.append(polygon1)
    
    // polygon 2
    let w: b2Float = 1.0
    let b: b2Float = w / (2.0 + sqrt(2.0))
    let s: b2Float = sqrt(2.0) * b
    
    var vertices2 = [b2Vec2](count: 8, repeatedValue: b2Vec2())
    vertices2[0].set(0.5 * s, 0.0)
    vertices2[1].set(0.5 * w, b)
    vertices2[2].set(0.5 * w, b + s)
    vertices2[3].set(0.5 * s, w)
    vertices2[4].set(-0.5 * s, w)
    vertices2[5].set(-0.5 * w, b + s);
    vertices2[6].set(-0.5 * w, b)
    vertices2[7].set(-0.5 * s, 0.0)
    
    let polygon2 = b2PolygonShape()
    polygon2.set(vertices: vertices2)
    polygons.append(polygon2)
    
    // polygon 3
    let polygon3 = b2PolygonShape()
    polygon3.setAsBox(halfWidth: 0.5, halfHeight: 0.5)
    polygons.append(polygon3)
    
    circle = b2CircleShape()
    circle.radius = 0.5
    
    edge = b2EdgeShape()
    edge.set(vertex1: b2Vec2(-1.0, 0.0), vertex2: b2Vec2(1.0, 0.0))
    
    angle = 0.0
    
    mode = Mode.closest
  }
  
  override func step() {
    // RayCast
    let advanceRay = !settings.pause || settings.singleStep
    let L: b2Float = 11.0
    let point1 = b2Vec2(0.0, 10.0)
    let d = b2Vec2(L * cosf(angle), L * sinf(angle))
    let point2 = point1 + d
    
    if mode == Mode.closest {
      let callback = RayCastClosestCallback()
      world.rayCast(callback: callback, point1: point1, point2: point2)
      if callback.hit {
        debugDraw.drawPoint(callback.point, 5.0, b2Color(0.4, 0.9, 0.4))
        debugDraw.drawSegment(point1, callback.point, b2Color(0.8, 0.8, 0.8))
        let head = callback.point + 0.5 * callback.normal
        debugDraw.drawSegment(callback.point, head, b2Color(0.9, 0.9, 0.4))
      }
      else {
        debugDraw.drawSegment(point1, point2, b2Color(0.8, 0.8, 0.8))
      }
    }
    else if mode == Mode.any {
      let callback = RayCastAnyCallback()
      world.rayCast(callback: callback, point1: point1, point2: point2)
      
      if callback.hit {
        debugDraw.drawPoint(callback.point, 5.0, b2Color(0.4, 0.9, 0.4))
        debugDraw.drawSegment(point1, callback.point, b2Color(0.8, 0.8, 0.8))
        let head = callback.point + 0.5 * callback.normal
        debugDraw.drawSegment(callback.point, head, b2Color(0.9, 0.9, 0.4))
      }
      else {
        debugDraw.drawSegment(point1, point2, b2Color(0.8, 0.8, 0.8))
      }
    }
    else if mode == Mode.multiple {
      let callback = RayCastMultipleCallback()
      world.rayCast(callback: callback, point1: point1, point2: point2)
      debugDraw.drawSegment(point1, point2, b2Color(0.8, 0.8, 0.8))
      
      for i in 0 ..< callback.count {
        let p = callback.points[i]
        let n = callback.normals[i]
        debugDraw.drawPoint(p, 5.0, b2Color(0.4, 0.9, 0.4))
        debugDraw.drawSegment(point1, p, b2Color(0.8, 0.8, 0.8))
        let head = p + 0.5 * n
        debugDraw.drawSegment(p, head, b2Color(0.9, 0.9, 0.4))
      }
    }
    
    if advanceRay {
      angle += 0.25 * b2_pi / 180.0
    }
  }
  
  func create(index: Int) {
    let bd = b2BodyDef()
    let x = RandomFloat(-10.0, 10.0)
    assert(x >= -10.0 && x <= 10.0)
    let y = RandomFloat(0.0, 20.0)
    bd.position.set(x, y)
    bd.angle = RandomFloat(-b2_pi, b2_pi)
    bd.userData = NSNumber(integer: index)
    
    if index == 4 {
      bd.angularDamping = 0.02
    }
    let body = world.createBody(bd)
    if index < 4 {
      let fd = b2FixtureDef()
      fd.shape = polygons[index]
      fd.friction = 0.3
      body.createFixture(fd)
    }
    else if index < 5 {
      let fd = b2FixtureDef()
      fd.shape = circle
      fd.friction = 0.3
      body.createFixture(fd)
    }
    else {
      let fd = b2FixtureDef()
      fd.shape = edge
      fd.friction = 0.3
      body.createFixture(fd)
    }
    
    bodies.append((body, index))
  }
  
  func onDropStuff(sender: UIBarButtonItem) {
    dropVC.modalPresentationStyle = UIModalPresentationStyle.Popover
    let popPC = dropVC.popoverPresentationController
    popPC?.barButtonItem = sender
    popPC?.permittedArrowDirections = UIPopoverArrowDirection.Any
    self.presentViewController(dropVC, animated: true, completion: nil)
  }
  
  func onChangeMode(sender: UIBarButtonItem) {
    modeVC.modalPresentationStyle = UIModalPresentationStyle.Popover
    let popPC = modeVC.popoverPresentationController
    popPC?.barButtonItem = sender
    popPC?.permittedArrowDirections = UIPopoverArrowDirection.Any
    self.presentViewController(modeVC, animated: true, completion: nil)
  }
  
  func onDeleteStuff(sender: UIBarButtonItem) {
    if bodies.count == 0 {
      return
    }
    let body = bodies.first!.0
    world.destroyBody(body)
    bodies.removeAtIndex(0)
  }
  
  func textListDidSelect(name name: String, index: Int) {
    self.dismissViewControllerAnimated(true, completion: nil)
    if name == "Drop" {
      create(index)
    }
    else if name == "Mode" {
      if index == 0 {
        mode = Mode.closest
      }
      else if index == 1 {
        mode = Mode.any
      }
      else if index == 2 {
        mode = Mode.multiple
      }
    }
  }
}
