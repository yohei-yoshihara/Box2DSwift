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

import Foundation
import Box2D

func randomFloat() -> b2Float {
  var rand = b2Float(arc4random_uniform(1000)) / b2Float(1000)
  rand = b2Float(2.0) * rand - b2Float(1.0)
  return rand
}

func RandomFloat(low: b2Float, _ high: b2Float) -> b2Float {
  let rand = (b2Float(arc4random_uniform(1000)) / b2Float(1000)) * (high - low) + low
  return rand
}

func ConvertScreenToWorld(tp: CGPoint, size: CGSize, viewCenter: b2Vec2) -> b2Vec2 {
  let u = b2Float(tp.x / size.width)
  let v = b2Float((size.height - tp.y) / size.height)
  let extents = b2Vec2(25.0, 25.0)
  let lower = viewCenter - extents
  let upper = viewCenter + extents
  var p = b2Vec2()
  p.x = (1.0 - u) * lower.x + b2Float(u) * upper.x
  p.y = (1.0 - v) * lower.y + b2Float(v) * upper.y
  return p
}

func CalculateRenderViewFrame(parentView: UIView) -> CGRect {
  let margin: CGFloat = 8
  let d = min(parentView.bounds.size.width, parentView.bounds.size.height) - margin
  let x = (parentView.bounds.size.width - d) / 2.0
  let y = (parentView.bounds.size.height - d) / 2.0
  return CGRect(x: x, y: y, width: d, height: d)
}

func checkBackButton(viewController: UIViewController) -> Bool {
  let vcs: [AnyObject]? = viewController.navigationController?.viewControllers
  if vcs != nil {
    var found = false
    for vc in vcs! {
      if vc === viewController {
        found = true
        break
      }
    }
    return found == false
  }
  return false
}

class Settings : CustomStringConvertible {
  init() {
    viewCenter = b2Vec2(0.0, 20.0)
    hz = b2Float(60.0)
    velocityIterations = 8
    positionIterations = 3
    drawShapes = true
    drawJoints = true
    drawAABBs = false
    drawContactPoints = false
    drawContactNormals = false
    drawContactImpulse = false
    drawFrictionImpulse = false
    drawCOMs = false
    drawStats = false
    drawProfile = false
    enableWarmStarting = true
    enableContinuous = true
    enableSubStepping = false
    enableSleep = true
    pause = false
    singleStep = false
  }
  var viewCenter = b2Vec2(0.0, 20.0)
  var hz: b2Float = 60.0
  var velocityIterations = 8
  var positionIterations = 3
  var drawShapes = true
  var drawJoints = true
  var drawAABBs = false
  var drawContactPoints = false
  var drawContactNormals = false
  var drawContactImpulse = false
  var drawFrictionImpulse = false
  var drawCOMs = false
  var drawStats = false
  var drawProfile = false
  var enableWarmStarting = true
  var enableContinuous = true
  var enableSubStepping = false
  var enableSleep = true
  var pause = false
  var singleStep = false
  
  func calcViewBounds() -> (lower: b2Vec2, upper: b2Vec2) {
    let extents = b2Vec2(25.0, 25.0)
    let lower = viewCenter - extents
    let upper = viewCenter + extents
    return (lower, upper)
  }
  
  func calcTimeStep() -> b2Float {
    var timeStep: b2Float = hz > 0.0 ? b2Float(1.0) / hz : b2Float(0.0)
    if pause {
      if singleStep {
        singleStep = false
      }
      else {
        timeStep = b2Float(0.0)
      }
    }
    return timeStep
  }
  
  var debugDrawFlag : UInt32 {
    var flags: UInt32 = 0
    if drawShapes {
      flags |= b2DrawFlags.shapeBit
    }
    if drawJoints {
      flags |= b2DrawFlags.jointBit
    }
    if drawAABBs {
      flags |= b2DrawFlags.aabbBit
    }
    if drawCOMs {
      flags |= b2DrawFlags.centerOfMassBit
    }
    return flags
  }
  
  func apply(world: b2World) {
    world.setAllowSleeping(enableSleep)
    world.setWarmStarting(enableWarmStarting)
    world.setContinuousPhysics(enableContinuous)
    world.setSubStepping(enableSubStepping)
  }
  
  var description: String {
    return "Settings[viewCenter=\(viewCenter),hz=\(hz),velocityIterations=\(velocityIterations),positionIterations=\(positionIterations),drawShapes=\(drawShapes),drawJoints=\(drawJoints),drawAABBs=\(drawAABBs),drawContactPoints=\(drawContactPoints),drawContactNormals=\(drawContactNormals),drawFrictionImpulse=\(drawFrictionImpulse),drawCOMs=\(drawCOMs),drawStats=\(drawStats),drawProfile=\(drawProfile),enableWarmStarting=\(enableWarmStarting),enableContinuous=\(enableContinuous),enableSubStepping=\(enableSubStepping),enableSleep=\(enableSleep),pause=\(pause),singleStep=\(singleStep)]"
  }
}

struct ContactPoint {
  weak var fixtureA: b2Fixture? = nil
  weak var fixtureB: b2Fixture? = nil
  var normal = b2Vec2()
  var position = b2Vec2()
  var state = b2PointState.nullState
  var normalImpulse: b2Float = 0.0
  var tangentImpulse: b2Float = 0.0
  var separation: b2Float = 0.0
}

class QueryCallback : b2QueryCallback {
  init(point: b2Vec2) {
    self.point = point
    fixture = nil
  }
  
  func reportFixture(fixture: b2Fixture) -> Bool {
    let body = fixture.body
    if body.type == b2BodyType.dynamicBody {
      let inside = fixture.testPoint(self.point)
      if inside {
        self.fixture = fixture
        // We are done, terminate the query.
        return false
      }
    }
    // Continue the query.
    return true
  }
  
  var point: b2Vec2
  var fixture: b2Fixture? = nil
}

class DestructionListener : b2DestructionListener {
  func sayGoodbye(fixture: Box2D.b2Fixture) {}
  func sayGoodbye(joint: Box2D.b2Joint) {}
}

class ContactListener : b2ContactListener {
  var m_points = [ContactPoint]()
  
  func clearPoints() {
    m_points.removeAll(keepCapacity: true)
  }
  
  func drawContactPoints(settings: Settings, renderView: RenderView) {
    if settings.drawContactPoints {
      let k_impulseScale: b2Float = 0.1
      let k_axisScale: b2Float = 0.3
      
      for point in m_points {
        if point.state == b2PointState.addState {
          // Add
          renderView.drawPoint(point.position, 10.0, b2Color(0.3, 0.95, 0.3))
        }
        else if point.state == b2PointState.persistState {
          // Persist
          renderView.drawPoint(point.position, 5.0, b2Color(0.3, 0.3, 0.95))
        }
        
        if settings.drawContactNormals {
          let p1 = point.position
          let p2 = p1 + k_axisScale * point.normal
          renderView.drawSegment(p1, p2, b2Color(0.9, 0.9, 0.9))
        }
        else if settings.drawContactImpulse {
          let p1 = point.position
          let p2 = p1 + k_impulseScale * point.normalImpulse * point.normal
          renderView.drawSegment(p1, p2, b2Color(0.9, 0.9, 0.3))
        }
        
        if settings.drawFrictionImpulse {
          let tangent = b2Cross(point.normal, 1.0)
          let p1 = point.position
          let p2 = p1 + k_impulseScale * point.tangentImpulse * tangent
          renderView.drawSegment(p1, p2, b2Color(0.9, 0.9, 0.3))
        }
      }
    }
  }
  
  func beginContact(contact : b2Contact) {}
  func endContact(contact: b2Contact) {}
  
  func preSolve(contact: b2Contact, oldManifold: b2Manifold) {
    let manifold = contact.manifold
    if manifold.pointCount == 0 {
      return
    }
    
    let fixtureA = contact.fixtureA
    let fixtureB = contact.fixtureB
    let (_/*state1*/, state2) = b2GetPointStates(manifold1: oldManifold, manifold2: manifold)
    let worldManifold = contact.worldManifold
    
    for (var i = 0; i < manifold.pointCount; ++i) {
      var cp = ContactPoint()
      cp.fixtureA = fixtureA
      cp.fixtureB = fixtureB
      cp.position = worldManifold.points[i]
      cp.normal = worldManifold.normal
      cp.state = state2[i]
      cp.normalImpulse = manifold.points[i].normalImpulse
      cp.tangentImpulse = manifold.points[i].tangentImpulse
      cp.separation = worldManifold.separations[i]
      m_points.append(cp)
    }
  }
  
  func postSolve(contact: b2Contact, impulse: b2ContactImpulse) {}
}


