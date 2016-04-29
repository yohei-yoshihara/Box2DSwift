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

class DistanceTestViewController: BaseViewController {
  var positionB = b2Vec2()
  var angleB: b2Float = 0
  
  var transformA = b2Transform()
  var transformB = b2Transform()
  var polygonA = b2PolygonShape()
  var polygonB = b2PolygonShape()

  override func prepare() {
    transformA.setIdentity()
    transformA.p.set(0.0, -0.2)
    polygonA.setAsBox(halfWidth: 10.0, halfHeight: 0.2)
    
    positionB.set(12.017401, 0.13678508)
    angleB = -0.0109265
    transformB.set(positionB, angle: angleB)
    
    polygonB.setAsBox(halfWidth: 2.0, halfHeight: 0.1)
  }
  
  override func step() {
    var input = b2DistanceInput()
    input.proxyA.set(polygonA, 0)
    input.proxyB.set(polygonB, 0)
    input.transformA = transformA
    input.transformB = transformB
    input.useRadii = true
    var cache = b2SimplexCache()
    cache.count = 0
    var output = b2DistanceOutput()
    b2Distance(&output, cache: &cache, input: input)
    
//    debugDraw.DrawString(5, m_textLine, "distance = %g", output.distance)
//    m_textLine += DRAW_STRING_NEW_LINE
//    
//    debugDraw.DrawString(5, m_textLine, "iterations = %d", output.iterations)
//    m_textLine += DRAW_STRING_NEW_LINE
    
    b2Locally {
      let color = b2Color(0.9, 0.9, 0.9)
      var v = [b2Vec2]()
      for i in 0 ..< self.polygonA.count {
        v.append(b2Mul(self.transformA, self.polygonA.vertices[i]))
      }
      self.debugDraw.drawPolygon(v, color)
      
      for i in 0 ..< self.polygonB.count {
        v.append(b2Mul(self.transformB, self.polygonB.vertices[i]))
      }
      self.debugDraw.drawPolygon(v, color)
    }
    
    let x1 = output.pointA
    let x2 = output.pointB
    
    let c1 = b2Color(1.0, 0.0, 0.0)
    debugDraw.drawPoint(x1, 4.0, c1)
    
    let c2 = b2Color(1.0, 1.0, 0.0)
    debugDraw.drawPoint(x2, 4.0, c2)
  }
}
