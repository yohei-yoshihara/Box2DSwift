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

class PolyCollisionViewController: BaseViewController {
  var polygonA: b2PolygonShape!
  var polygonB: b2PolygonShape!
  
  var transformA = b2Transform()
  var transformB = b2Transform()
  
  var positionB = b2Vec2()
  var angleB: b2Float = 0
  
  var additionalInfoView: AdditionalInfoView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TODO: must add controller
    
    additionalInfoView = AdditionalInfoView(frame: self.view.bounds)
    self.view.addSubview(additionalInfoView)
  }
  
  override func prepare() {
    polygonA = b2PolygonShape()
    polygonA.setAsBox(halfWidth: 0.2, halfHeight: 0.4)
    transformA.set(b2Vec2(0.0, 0.0), angle: 0.0)
    
    polygonB = b2PolygonShape()
    polygonB.setAsBox(halfWidth: 0.5, halfHeight: 0.5)
    positionB.set(19.345284, 1.5632932)
    angleB = 1.9160721
    transformB.set(positionB, angle: angleB)
  }
  
  override func step() {
    var manifold = b2Manifold()
    b2CollidePolygons(manifold: &manifold,
      polygonA: polygonA, transformA: transformA,
      polygonB: polygonB, transformB: transformB)
    
    let worldManifold = b2WorldManifold()
    worldManifold.initialize(manifold: manifold,
      transformA: transformA, radiusA: polygonA.radius,
      transformB: transformB, radiusB: polygonB.radius)
    
    additionalInfoView.begin()
    additionalInfoView.append(String(format: "point count = %d", manifold.pointCount))
    additionalInfoView.end()
    
    let color = b2Color(0.9, 0.9, 0.9)
    var v = [b2Vec2]()
    for i in 0 ..< polygonA.count {
      v.append(b2Mul(transformA, polygonA.vertices[i]))
    }
    debugDraw.drawPolygon(v, color)
      
    for i in 0 ..< polygonB.count {
      v.append(b2Mul(transformB, polygonB.vertices[i]))
    }
    debugDraw.drawPolygon(v, color)
    
    for i in 0 ..< manifold.pointCount {
      debugDraw.drawPoint(worldManifold.points[i], 4.0, b2Color(0.9, 0.3, 0.3))
    }
  }
}
