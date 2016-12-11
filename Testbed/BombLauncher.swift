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

class BombLauncher : NSObject {
  unowned let world: b2World
  unowned let debugDraw: RenderView
  var viewCenter: b2Vec2
  var drawLine = false
  var lineStart = b2Vec2(), lineEnd = b2Vec2()
  var bomb: b2Body? = nil
 
  init(world: b2World, renderView: RenderView, viewCenter: b2Vec2) {
    self.world = world
    debugDraw = renderView
    self.viewCenter = viewCenter
    super.init()
  }
  
  func onTap(_ gr: UITapGestureRecognizer) {
    let tp = gr.location(in: self.debugDraw)
    let p = ConvertScreenToWorld(tp, size: debugDraw.bounds.size, viewCenter: self.viewCenter)
    LaunchBomb(p, b2Vec2(0.0, 0.0))
  }
  
  func onPan(_ gr: UIPanGestureRecognizer) {
    let tp = gr.location(in: self.debugDraw)
    let p = ConvertScreenToWorld(tp, size: debugDraw.bounds.size, viewCenter: self.viewCenter)
    
    switch gr.state {
    case .began:
      drawLine = true
      lineStart = p
      lineEnd = p
    case .changed:
      lineEnd = p
    case .ended:
      drawLine = false
      let multiplier: b2Float = 30.0
      var vel = lineStart - p
      vel *= multiplier
      LaunchBomb(lineStart, vel)
    case .possible:
      break
    default:
      drawLine = false
    }
  }
  
  func LaunchBomb() {
    let p = b2Vec2(RandomFloat(-15.0, 15.0), 30.0)
    let v = -5.0 * p
    LaunchBomb(p, v)
  }
  
  func LaunchBomb(_ position: b2Vec2, _ velocity: b2Vec2) {
    if bomb != nil {
      world.destroyBody(bomb!)
      bomb = nil
    }
    
    let bd = b2BodyDef()
    bd.type = b2BodyType.dynamicBody
    bd.position = position
    bd.bullet = true
    bomb = world.createBody(bd)
    bomb!.setLinearVelocity(velocity)
    
    let circle = b2CircleShape()
    circle.radius = 0.3
    
    let fd = b2FixtureDef()
    fd.shape = circle
    fd.density = 20.0
    fd.restitution = 0.0
    
    let minV = position - b2Vec2(0.3, 0.3)
    let maxV = position + b2Vec2(0.3, 0.3)
    
    var aabb = b2AABB()
    aabb.lowerBound = minV
    aabb.upperBound = maxV
    
    bomb!.createFixture(fd)
  }
  
  func render() {
    if drawLine {
      debugDraw.drawSegment(lineStart, lineEnd, b2Color(1, 1, 1))
    }
  }
}
