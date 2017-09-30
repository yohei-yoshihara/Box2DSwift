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

class VerticalStackViewController: BaseViewController {
  let columnCount = 5
  let rowCount = 16
  
  var bullet: b2Body? = nil
  var bodies = [b2Body]()
  var indices = [Int]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let shootButton = UIBarButtonItem(title: "Shoot", style: UIBarButtonItemStyle.plain, target: self, action: #selector(VerticalStackViewController.onShoot(_:)))
    let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    self.addToolbarItems([shootButton, flexible])
  }

  override func prepare() {
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-40.0, 0.0), vertex2: b2Vec2(40.0, 0.0))
      ground.createFixture(shape: shape, density: 0.0)
      
      shape.set(vertex1: b2Vec2(20.0, 0.0), vertex2: b2Vec2(20.0, 20.0))
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    let xs: [b2Float] = [0.0, -10.0, -5.0, 5.0, 10.0]
    
    for j in 0 ..< self.columnCount {
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.5, halfHeight: 0.5)
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 1.0
      fd.friction = 0.3
      
      for i in 0 ..< self.rowCount {
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        
        let n = j * self.rowCount + i
        assert(n < self.rowCount * self.columnCount)
        indices.append(n)
        bd.userData = NSNumber(value: indices.last! as Int)
        
        let x: b2Float = 0.0
        //float32 x = RandomFloat(-0.02f, 0.02f);
        //float32 x = i % 2 == 0 ? -0.025f : 0.025f;
        bd.position.set(xs[j] + x, 0.752 + 1.54 * b2Float(i))
        let body = world.createBody(bd)
        
        bodies.append(body)
        
        body.createFixture(fd)
      }
    }
    
    bullet = nil
  }
  
  @objc func onShoot(_ sender: UIBarButtonItem) {
    if bullet != nil {
      world.destroyBody(bullet!)
      bullet = nil
    }
    
    b2Locally {
      let shape = b2CircleShape()
      shape.radius = 0.25
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 20.0
      fd.restitution = 0.05
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.bullet = true
      bd.position.set(-31.0, 5.0)
      
      self.bullet = self.world.createBody(bd)
      self.bullet!.createFixture(fd)
      
      self.bullet!.setLinearVelocity(b2Vec2(400.0, 0.0))
    }
  }
}
