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
import XCTest
import Box2D

class A {
  var x = 0
  var y = 0
}

let expected: [b2Float] = [
  0.000000, 3.997222, 0.000000,
  0.000000, 3.991667, 0.000000,
  0.000000, 3.983333, 0.000000,
  0.000000, 3.972222, 0.000000,
  0.000000, 3.958333, 0.000000,
  0.000000, 3.941667, 0.000000,
  0.000000, 3.922222, 0.000000,
  0.000000, 3.900000, 0.000000,
  0.000000, 3.875000, 0.000000,
  0.000000, 3.847222, 0.000000,
  0.000000, 3.816667, 0.000000,
  0.000000, 3.783333, 0.000000,
  0.000000, 3.747222, 0.000000,
  0.000000, 3.708333, 0.000000,
  0.000000, 3.666667, 0.000000,
  0.000000, 3.622222, 0.000000,
  0.000000, 3.575000, 0.000000,
  0.000000, 3.525000, 0.000000,
  0.000000, 3.472222, 0.000000,
  0.000000, 3.416667, 0.000000,
  0.000000, 3.358333, 0.000000,
  0.000000, 3.297222, 0.000000,
  0.000000, 3.233333, 0.000000,
  0.000000, 3.166667, 0.000000,
  0.000000, 3.097222, 0.000000,
  0.000000, 3.025000, 0.000000,
  0.000000, 2.950000, 0.000000,
  0.000000, 2.872222, 0.000000,
  0.000000, 2.791667, 0.000000,
  0.000000, 2.708333, 0.000000,
  0.000000, 2.622222, 0.000000,
  0.000000, 2.533333, 0.000000,
  0.000000, 2.441667, 0.000000,
  0.000000, 2.347222, 0.000000,
  0.000000, 2.250000, 0.000000,
  0.000000, 2.150000, 0.000000,
  0.000000, 2.047222, 0.000000,
  0.000000, 1.941667, 0.000000,
  0.000000, 1.833333, 0.000000,
  0.000000, 1.722222, 0.000000,
  0.000000, 1.608334, 0.000000,
  0.000000, 1.491667, 0.000000,
  0.000000, 1.372223, 0.000000,
  0.000000, 1.250000, 0.000000,
  0.000000, 1.125000, 0.000000,
  0.000000, 1.014582, 0.000141,
  0.000000, 1.014651, 0.000110,
  0.000000, 1.014708, 0.000086,
  0.000000, 1.014756, 0.000067,
  0.000000, 1.014796, 0.000052,
  0.000000, 1.014830, 0.000041,
  0.000000, 1.014858, 0.000032,
  0.000000, 1.014881, 0.000025,
  0.000000, 1.014900, 0.000020,
  0.000000, 1.014917, 0.000016,
  0.000000, 1.014930, 0.000012,
  0.000000, 1.014942, 0.000010,
  0.000000, 1.014951, 0.000008,
  0.000000, 1.014959, 0.000006,
  0.000000, 1.014966, 0.000005,
]

class Box2DTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testExample() {
    // Define the gravity vector.
    let gravity = b2Vec2(0.0, -10.0)
    
    // Construct a world object, which will hold and simulate the rigid bodies.
    let world = b2World(gravity: gravity)
    
    // Define the ground body.
    let groundBodyDef = b2BodyDef()
    groundBodyDef.position.set(0.0, -10.0)
    
    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    let groundBody = world.createBody(groundBodyDef)
    
    // Define the ground box shape.
    let groundBox = b2PolygonShape()
    
    // The extents are the half-widths of the box.
    groundBox.setAsBox(halfWidth: 50.0, halfHeight: 10.0)
    
    // Add the ground fixture to the ground body.
    groundBody.createFixture(shape: groundBox, density: 0.0)
    
    // Define the dynamic body. We set its position and call the body factory.
    let bodyDef = b2BodyDef()
    bodyDef.type = b2BodyType.dynamicBody
    bodyDef.position.set(0.0, 4.0)
    let body = world.createBody(bodyDef)
    
    // Define another box shape for our dynamic body.
    let dynamicBox = b2PolygonShape()
    dynamicBox.setAsBox(halfWidth: 1.0, halfHeight: 1.0)
    
    // Define the dynamic body fixture.
    let fixtureDef = b2FixtureDef()
    fixtureDef.shape = dynamicBox
    
    // Set the box density to be non-zero, so it will be dynamic.
    fixtureDef.density = 1.0
    
    // Override the default friction.
    fixtureDef.friction = 0.3
    
    // Add the shape to the body.
    body.createFixture(fixtureDef)
    
    // Prepare for simulation. Typically we use a time step of 1/60 of a
    // second (60Hz) and 10 iterations. This provides a high quality simulation
    // in most game scenarios.
    let timeStep: b2Float = 1.0 / 60.0
    let velocityIterations = 6
    let positionIterations = 2
    
    // This is our little game loop.
    for i in 0 ..< 60 {
      if i == 45 {
        print("stop")
      }
      // Instruct the world to perform a single step of simulation.
      // It is generally best to keep the time step and iterations fixed.
      world.step(timeStep: timeStep, velocityIterations: velocityIterations, positionIterations: positionIterations)
      //world.dump()
      
      // Now print the position and angle of the body.
      //body.dump()
      let position = body.position
      let angle = body.angle
      
      //world.dump()
      print("\(i): \(position.x) \(position.y) \(angle)")
      
      let expectedX: b2Float = expected[i * 3 + 0]
      let expectedY: b2Float = expected[i * 3 + 1]
      let expectedAngle: b2Float = expected[i * 3 + 2]
      XCTAssertEqual(body.position.x, expectedX, accuracy: 1e-5);
      XCTAssertEqual(body.position.y, expectedY, accuracy: 1e-5);
      XCTAssertEqual(body.angle, expectedAngle, accuracy: 1e-5);
    }
    XCTAssertEqual(body.position.x, b2Float(0.0), accuracy: 1e-4);
    XCTAssertEqual(body.position.y, b2Float(1.014966), accuracy: 1e-4);
    XCTAssertEqual(body.angle, b2Float(0.0), accuracy: 1e-4);
    // When the world destructor is called, all bodies and joints are freed. This can
    // When the world destructor is called, all bodies and joints are freed. This can
    // create orphaned pointers, so be careful about your world management.
  }
}
