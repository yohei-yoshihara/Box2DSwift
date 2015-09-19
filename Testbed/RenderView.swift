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
import QuartzCore
import Box2D
import OpenGLES
import GLKit

class RenderView: UIView, b2Draw {
  var renderer: Renderer!
  var vertexData = [Vertex]()
  var left: b2Float = -1
  var right: b2Float = 1
  var bottom: b2Float = -1
  var top: b2Float = 1
  
  override class func layerClass() -> AnyClass {
    return CAEAGLLayer.self
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    // Get the layer
    let eaglLayer = self.layer as! CAEAGLLayer
    
    // set content scale
    self.contentScaleFactor = UIScreen.mainScreen().scale
    eaglLayer.contentsScale = UIScreen.mainScreen().scale
    
    // set opaque is NO
    self.opaque = false
    eaglLayer.opaque = false
    
    // retained backing is YES
    eaglLayer.drawableProperties = [kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8]
    
    renderer = Renderer()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  deinit {
  }
  
  override func layoutSubviews() {
    renderer.resizeFromLayer(self.layer as! CAEAGLLayer)
  }
  
  func preRender() {
    renderer.preRender()
    renderer.setOrtho2D(left: left, right: right, bottom: bottom, top: top)
  }
  
  func postRender() {
    renderer.postRender()
  }
  
  func setOrtho2D(left left: b2Float, right: b2Float, bottom: b2Float, top: b2Float) {
    self.left = left
    self.right = right
    self.bottom = bottom
    self.top = top
  }
  
  // MARK: - b2Draw
  
  /// Set the drawing flags.
  func SetFlags(flags : UInt32) {
    m_drawFlags = flags
  }
  
  /// Get the drawing flags.
  var flags: UInt32 {
    get {
      return m_drawFlags
    }
  }
  
  /// Append flags to the current flags.
  func AppendFlags(flags : UInt32) {
    m_drawFlags |= flags
  }
  
  /// Clear flags from the current flags.
  func ClearFlags(flags : UInt32) {
    m_drawFlags &= ~flags
  }
  
  /// Draw a closed polygon provided in CCW order.
  func drawPolygon(vertices: [b2Vec2], _ color: b2Color) {
    vertexData.removeAll(keepCapacity: true)
    for v in vertices {
      vertexData.append(Vertex(x: v.x, y: v.y))
    }
    renderer.setColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
    renderer.setVertexData(&vertexData)
    renderer.draw(GL_LINE_LOOP, count: vertexData.count)
  }
  
  /// Draw a solid closed polygon provided in CCW order.
  func drawSolidPolygon(vertices: [b2Vec2], _ color: b2Color) {
    vertexData.removeAll(keepCapacity: true)
    for v in vertices {
      vertexData.append(Vertex(x: v.x, y: v.y))
    }
    renderer.setVertexData(&vertexData)
    renderer.enableBlend()
    renderer.setColor(red: 0.5 * color.r, green: 0.5 * color.g, blue: 0.5 * color.b, alpha: 0.5)
    renderer.draw(GL_TRIANGLE_FAN, count: vertexData.count)
    renderer.disableBlend()
    
    renderer.setColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
    renderer.draw(GL_LINE_LOOP, count: vertexData.count)
  }
  
  /// Draw a circle.
  func drawCircle(center: b2Vec2, _ radius: b2Float, _ color: b2Color) {
    let k_segments = 16
    let k_increment: b2Float = b2Float(2.0 * 3.14159265) / b2Float(k_segments)
    var theta: b2Float = 0.0
    vertexData.removeAll(keepCapacity: true)
    for _ in 0 ..< k_segments {
      let v = center + radius * b2Vec2(cosf(theta), sinf(theta))
      vertexData.append(Vertex(x: v.x, y: v.y))
      theta += k_increment
    }
    renderer.setColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
    renderer.setVertexData(&vertexData)
    renderer.draw(GL_LINE_LOOP, count: vertexData.count)
  }
  
  /// Draw a solid circle.
  func drawSolidCircle(center: b2Vec2, _ radius: b2Float, _ axis: b2Vec2, _ color: b2Color) {
    let k_segments = 16
    let k_increment: b2Float = b2Float(2.0 * 3.14159265) / b2Float(k_segments)
    var theta: b2Float = 0.0
    vertexData.removeAll(keepCapacity: true)
    for _ in 0 ..< k_segments {
      let v = center + radius * b2Vec2(cosf(theta), sinf(theta))
      vertexData.append(Vertex(x: v.x, y: v.y))
      theta += k_increment
    }
    renderer.setVertexData(&vertexData)
    
    renderer.enableBlend()
    renderer.setColor(red: 0.5 * color.r, green: 0.5 * color.g, blue: 0.5 * color.b, alpha: 0.5)
    renderer.draw(GL_TRIANGLE_FAN, count: vertexData.count)
    renderer.disableBlend()

    renderer.setColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
    renderer.draw(GL_LINE_LOOP, count: vertexData.count)
    
    let p = center + radius * axis
    vertexData.removeAll(keepCapacity: true)
    vertexData.append(Vertex(x: center.x, y: center.y))
    vertexData.append(Vertex(x: p.x, y: p.y))
    renderer.setVertexData(&vertexData)
    
    renderer.setColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
    renderer.draw(GL_LINES, count: vertexData.count)
  }
  
  /// Draw a line segment.
  func drawSegment(p1: b2Vec2, _ p2: b2Vec2, _ color: b2Color) {
    vertexData.removeAll(keepCapacity: true)
    vertexData.append(Vertex(x: p1.x, y: p1.y))
    vertexData.append(Vertex(x: p2.x, y: p2.y))
    renderer.setVertexData(&vertexData)
    renderer.setColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
    renderer.draw(GL_LINES, count: vertexData.count)
  }
  
  /// Draw a transform. Choose your own length scale.
  /// @param xf a transform.
  func drawTransform(xf: b2Transform) {
    let p1 = xf.p
    var p2: b2Vec2
    let k_axisScale: b2Float = 0.4
    vertexData.removeAll(keepCapacity: true)
    vertexData.append(Vertex(x: p1.x, y: p1.y))
    p2 = p1 + k_axisScale * xf.q.xAxis
    vertexData.append(Vertex(x: p2.x, y: p2.y))
    renderer.setVertexData(&vertexData)
    renderer.setColor(red: 1, green: 0, blue: 0, alpha: 1.0)
    renderer.draw(GL_LINES, count: vertexData.count)
    
    vertexData.removeAll(keepCapacity: true)
    vertexData.append(Vertex(x: p1.x, y: p1.y))
    p2 = p1 + k_axisScale * xf.q.yAxis
    vertexData.append(Vertex(x: p2.x, y: p2.y))
    renderer.setVertexData(&vertexData)
    renderer.setColor(red: 0, green: 1, blue: 0, alpha: 1.0)
    renderer.draw(GL_LINES, count: vertexData.count)
  }
  
  func drawPoint(p: b2Vec2, _ size: b2Float, _ color: b2Color) {
    vertexData.removeAll(keepCapacity: true)
    vertexData.append(Vertex(x: p.x, y: p.y))
    renderer.setVertexData(&vertexData)
    renderer.setColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
    renderer.setPointSize(size)
    renderer.draw(GL_POINTS, count: 1)
    renderer.setPointSize(0)
  }
  
  func drawAABB(aabb: b2AABB, _ color: b2Color) {
    vertexData.removeAll(keepCapacity: true)
    vertexData.append(Vertex(x: aabb.lowerBound.x, y: aabb.lowerBound.y))
    vertexData.append(Vertex(x: aabb.upperBound.x, y: aabb.lowerBound.y))
    vertexData.append(Vertex(x: aabb.upperBound.x, y: aabb.upperBound.y))
    vertexData.append(Vertex(x: aabb.lowerBound.x, y: aabb.upperBound.y))
    renderer.setVertexData(&vertexData)
    renderer.setColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
    renderer.draw(GL_LINE_LOOP, count: vertexData.count)
  }
  
  var m_drawFlags : UInt32 = 0
}
