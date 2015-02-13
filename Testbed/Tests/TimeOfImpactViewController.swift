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

class TimeOfImpactViewController: BaseViewController {
  var m_shapeA: b2PolygonShape!
  var m_shapeB: b2PolygonShape!

  override func prepare() {
    m_shapeA = b2PolygonShape()
    m_shapeA.setAsBox(halfWidth: 25.0, halfHeight: 5.0)
    m_shapeB = b2PolygonShape()
    m_shapeB.setAsBox(halfWidth: 2.5, halfHeight: 2.5)
  }

  override func step() {
    var sweepA = b2Sweep()
    sweepA.c0.set(24.0, -60.0)
    sweepA.a0 = 2.95
    sweepA.c = sweepA.c0
    sweepA.a = sweepA.a0
    sweepA.localCenter.setZero()
    
    var sweepB = b2Sweep()
    sweepB.c0.set(53.474274, -50.252514)
    sweepB.a0 = 513.36676 // - 162.0f * b2_pi;
    sweepB.c.set(54.595478, -51.083473)
    sweepB.a = 513.62781; //  - 162.0f * b2_pi;
    sweepB.localCenter.setZero()
    
    //sweepB.a0 -= 300.0f * b2_pi;
    //sweepB.a -= 300.0f * b2_pi;
    
    var input = b2TOIInput()
    input.proxyA.set(m_shapeA, 0)
    input.proxyB.set(m_shapeB, 0)
    input.sweepA = sweepA
    input.sweepB = sweepB
    input.tMax = 1.0
    
    var output = b2TOIOutput()
    
    b2TimeOfImpact(&output, input)
    /*
    debugDraw.DrawString(5, m_textLine, "toi = %g", output.t);
    m_textLine += DRAW_STRING_NEW_LINE;
    
    extern int32 b2_toiMaxIters, b2_toiMaxRootIters;
    debugDraw.DrawString(5, m_textLine, "max toi iters = %d, max root iters = %d", b2_toiMaxIters, b2_toiMaxRootIters);
    m_textLine += DRAW_STRING_NEW_LINE;
    */
    var vertices = [b2Vec2]() // [b2_maxPolygonVertices];
    
    var transformA = sweepA.getTransform(beta: 0.0)
    
    for i in 0 ..< m_shapeA.count {
      vertices.append(b2Mul(transformA, m_shapeA.vertices[i]))
    }
    debugDraw.drawPolygon(vertices, b2Color(0.9, 0.9, 0.9))
    vertices.removeAll(keepCapacity: true)
    
    var transformB = sweepB.getTransform(beta: 0.0)
    let localPoint = b2Vec2(2.0, -0.1)
    
    for i in 0 ..< m_shapeB.count {
      vertices.append(b2Mul(transformB, m_shapeB.vertices[i]))
    }
    debugDraw.drawPolygon(vertices, b2Color(0.5, 0.9, 0.5))
    vertices.removeAll(keepCapacity: true)
    
    transformB = sweepB.getTransform(beta: output.t)
    for i in 0 ..< m_shapeB.count {
      vertices.append(b2Mul(transformB, m_shapeB.vertices[i]))
    }
    debugDraw.drawPolygon(vertices, b2Color(0.5, 0.7, 0.9))
    vertices.removeAll(keepCapacity: true)
    
    transformB = sweepB.getTransform(beta: 1.0)
    for i in 0 ..< m_shapeB.count {
      vertices.append(b2Mul(transformB, m_shapeB.vertices[i]))
    }
    debugDraw.drawPolygon(vertices, b2Color(0.9, 0.5, 0.5))
    vertices.removeAll(keepCapacity: true)
    /*
    #if false
      for (float32 t = 0.0f; t < 1.0f; t += 0.1f)
      {
      sweepB.GetTransform(&transformB, t);
      for (int32 i = 0; i < m_shapeB.m_count; ++i)
      {
      vertices[i] = b2Mul(transformB, m_shapeB.m_vertices[i]);
      }
      debugDraw.drawPolygon(vertices, m_shapeB.m_count, b2Color(0.9f, 0.5f, 0.5f));
      }
    #endif
*/
  }

}
