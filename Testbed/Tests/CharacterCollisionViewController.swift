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

class CharacterCollisionViewController: BaseViewController {
  var character: b2Body!

  override func prepare() {
    // Ground body
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-20.0, 0.0), vertex2: b2Vec2(20.0, 0.0))
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    // Collinear edges with no adjacency information.
    // This shows the problematic case where a box shape can hit
    // an internal vertex.
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
      let shape = b2EdgeShape()
      shape.set(vertex1: b2Vec2(-8.0, 1.0), vertex2: b2Vec2(-6.0, 1.0))
      ground.createFixture(shape: shape, density: 0.0)
      shape.set(vertex1: b2Vec2(-6.0, 1.0), vertex2: b2Vec2(-4.0, 1.0))
      ground.createFixture(shape: shape, density: 0.0)
      shape.set(vertex1: b2Vec2(-4.0, 1.0), vertex2: b2Vec2(-2.0, 1.0))
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    // Chain shape
    b2Locally {
      let bd = b2BodyDef()
      bd.angle = 0.25 * b2_pi
      let ground = self.world.createBody(bd)
      
      var vs = [b2Vec2]()
      vs.append(b2Vec2(5.0, 7.0))
      vs.append(b2Vec2(6.0, 8.0))
      vs.append(b2Vec2(7.0, 8.0))
      vs.append(b2Vec2(8.0, 7.0))
      let shape = b2ChainShape()
      shape.createChain(vertices: vs)
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    // Square tiles. This shows that adjacency shapes may
    // have non-smooth collision. There is no solution
    // to this problem.
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 1.0, halfHeight: 1.0, center: b2Vec2(4.0, 3.0), angle: 0.0)
      ground.createFixture(shape: shape, density: 0.0)
      shape.setAsBox(halfWidth: 1.0, halfHeight: 1.0, center: b2Vec2(6.0, 3.0), angle: 0.0)
      ground.createFixture(shape: shape, density: 0.0)
      shape.setAsBox(halfWidth: 1.0, halfHeight: 1.0, center: b2Vec2(8.0, 3.0), angle: 0.0)
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    // Square made from an edge loop. Collision should be smooth.
    b2Locally {
      let bd = b2BodyDef()
      let ground = self.world.createBody(bd)
      
      var vs = [b2Vec2]()
      vs.append(b2Vec2(-1.0, 3.0))
      vs.append(b2Vec2(1.0, 3.0))
      vs.append(b2Vec2(1.0, 5.0))
      vs.append(b2Vec2(-1.0, 5.0))
      let shape = b2ChainShape()
      shape.createLoop(vertices: vs)
      ground.createFixture(shape: shape, density: 0.0)
    }

    // Edge loop. Collision should be smooth.
    b2Locally {
      let bd = b2BodyDef()
      bd.position.set(-10.0, 4.0)
      let ground = self.world.createBody(bd)
      
      var vs = [b2Vec2]()
      vs.append(b2Vec2(0.0, 0.0))
      vs.append(b2Vec2(6.0, 0.0))
      vs.append(b2Vec2(6.0, 2.0))
      vs.append(b2Vec2(4.0, 1.0))
      vs.append(b2Vec2(2.0, 2.0))
      vs.append(b2Vec2(0.0, 2.0))
      vs.append(b2Vec2(-2.0, 2.0))
      vs.append(b2Vec2(-4.0, 3.0))
      vs.append(b2Vec2(-6.0, 2.0))
      vs.append(b2Vec2(-6.0, 0.0))
      let shape = b2ChainShape()
      shape.createLoop(vertices: vs)
      ground.createFixture(shape: shape, density: 0.0)
    }
    
    // Square character 1
    b2Locally {
      let bd = b2BodyDef()
      bd.position.set(-3.0, 8.0)
      bd.type = b2BodyType.dynamicBody
      bd.fixedRotation = true
      bd.allowSleep = false
      
      let body = self.world.createBody(bd)
      
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.5, halfHeight: 0.5)
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 20.0
      body.createFixture(fd)
    }
    
    // Square character 2
    b2Locally {
      let bd = b2BodyDef()
      bd.position.set(-5.0, 5.0)
      bd.type = b2BodyType.dynamicBody
      bd.fixedRotation = true
      bd.allowSleep = false
      
      let body = self.world.createBody(bd)
      
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.25, halfHeight: 0.25)
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 20.0
      body.createFixture(fd)
    }

    // Hexagon character
    b2Locally {
      let bd = b2BodyDef()
      bd.position.set(-5.0, 8.0)
      bd.type = b2BodyType.dynamicBody
      bd.fixedRotation = true
      bd.allowSleep = false
      
      let body = self.world.createBody(bd)
      
      var angle: b2Float = 0.0
      let delta: b2Float = b2_pi / 3.0
      var vertices = [b2Vec2]()
      for _ in 0 ..< 6 {
        vertices.append(b2Vec2(0.5 * cos(angle), 0.5 * sin(angle)))
        angle += delta
      }
      
      let shape = b2PolygonShape()
      shape.set(vertices: vertices)
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 20.0
      body.createFixture(fd)
    }

    // Circle character
    b2Locally {
      let bd = b2BodyDef()
      bd.position.set(3.0, 5.0)
      bd.type = b2BodyType.dynamicBody
      bd.fixedRotation = true
      bd.allowSleep = false
      
      let body = self.world.createBody(bd)
      
      let shape = b2CircleShape()
      shape.radius = 0.5
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 20.0
      body.createFixture(fd)
    }

    // Circle character
    b2Locally {
      let bd = b2BodyDef()
      bd.position.set(-7.0, 6.0)
      bd.type = b2BodyType.dynamicBody
      bd.allowSleep = false
      
      self.character = self.world.createBody(bd)
      
      let shape = b2CircleShape()
      shape.radius = 0.25
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 20.0
      fd.friction = 1.0
      self.character.createFixture(fd)
    }
  }
  
  override func step() {
    /*var v = character.linearVelocity
    v.x = -5.0
    character.setLinearVelocity(v)*/
  }
  
}
