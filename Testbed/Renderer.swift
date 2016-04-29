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
import GLKit
import OpenGLES
import QuartzCore

let VertexAttributeLocation: GLuint = 0

struct Vertex {
  var x: GLfloat
  var y: GLfloat
}

class Renderer {
  var m_context: EAGLContext!
  var m_program: GLuint = 0
  var m_mvpUniform: Int32 = 0
  var m_colorUniform: Int32 = 0
  var m_pointSizeUniform: Int32 = 0
  var m_backingWidth: GLint = 0
  var m_backingHeight: GLint = 0
  var m_framebuffer: GLuint = 0
  var m_renderbuffer: GLuint = 0
  var m_vertexBuffer: GLuint = 0
  
  init() {
    m_context = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    EAGLContext.setCurrentContext(m_context)
    
    if loadShaders(vertexShaderName: "render", fragmentShaderName: "render") != true {
      fatalError("failed to load shaders")
    }
    
    glGenFramebuffers(1, &m_framebuffer)
    glGenRenderbuffers(1, &m_renderbuffer)
    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), m_framebuffer)
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), m_renderbuffer)
    glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), m_renderbuffer)
    glGenBuffers(1, &m_vertexBuffer)
  }
  
  deinit {
    if m_vertexBuffer != 0 {
      glDeleteBuffers(1, &m_vertexBuffer)
    }
    
    if m_framebuffer != 0 {
      glDeleteFramebuffers(1, &m_framebuffer)
    }
    if m_renderbuffer != 0 {
      glDeleteRenderbuffers(1, &m_renderbuffer)
    }
    
    if m_program != 0 {
      glDeleteProgram(m_program)
    }
    
    if EAGLContext.currentContext() == m_context {
      EAGLContext.setCurrentContext(nil)
    }
    m_context = nil
  }
  
  func preRender() {
    EAGLContext.setCurrentContext(m_context)
    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), m_framebuffer)
    glViewport(0, 0, m_backingWidth, m_backingHeight)
    glUseProgram(m_program)
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glClear(GLenum(GL_COLOR_BUFFER_BIT))
  }
  
  func postRender() {
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), m_renderbuffer)
    m_context.presentRenderbuffer(Int(GL_RENDERBUFFER))
  }
  
  func setOrtho2D(left left: GLfloat, right: GLfloat, bottom: GLfloat, top: GLfloat) {
//    let zNear: GLfloat = -1.0
//    let zFar: GLfloat = 1.0
//    let inv_z: GLfloat = 1.0 / (zFar - zNear)
    let inv_y: GLfloat = 1.0 / (top - bottom)
    let inv_x: GLfloat = 1.0 / (right - left)
    var mat33: [GLfloat] = [
      2.0 * inv_x,
      0.0,
      0.0,
      
      0.0,
      2.0 * inv_y,
      0.0,
      
      -(right + left) * inv_x,
      -(top + bottom) * inv_y,
      1.0
    ]
    glUniformMatrix3fv(m_mvpUniform, 1, GLboolean(GL_FALSE), &mat33)
  }
  
  func setColor(red red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) {
    glUniform4f(m_colorUniform, red, green, blue, alpha)
  }
  
  func setPointSize(pointSize: GLfloat) {
    glUniform1f(m_pointSizeUniform, pointSize)
  }
  
  func setVertexData(inout vertexData: [Vertex]) {
    glBindBuffer(GLenum(GL_ARRAY_BUFFER), m_vertexBuffer)
    glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(Vertex) * vertexData.count, &vertexData, GLenum(GL_STATIC_DRAW))
    glEnableVertexAttribArray(VertexAttributeLocation)
    glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, UnsafePointer(bitPattern: 0))
  }
  
  func enableBlend() {
    glEnable(GLenum(GL_BLEND))
    glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
  }
  
  func disableBlend() {
    glDisable(GLenum(GL_BLEND))
  }
  
  func draw(mode: Int32, count: Int) {
    glDrawArrays(GLenum(mode), 0, GLsizei(count))
  }

  func resizeFromLayer(layer: CAEAGLLayer) -> Bool {
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), m_renderbuffer)
    m_context.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable: layer)
    glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &m_backingWidth)
    glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &m_backingHeight)
    if glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) != GLenum(GL_FRAMEBUFFER_COMPLETE) {
      print("ERROR: failed to make complete framebuffer object")
      return false
    }
    return true
  }
  
  func loadShaders(vertexShaderName vertexShaderName: String, fragmentShaderName: String) -> Bool {
    m_program = glCreateProgram()
    var vertexShader: GLuint = 0
    var fragmentShader: GLuint = 0

    let vertexShaderPath = NSBundle.mainBundle().pathForResource(vertexShaderName, ofType: "vsh")
    if Renderer.compileShader(&vertexShader, type: GLenum(GL_VERTEX_SHADER), file: vertexShaderPath!) != true {
      Renderer.destroyShaders(vertexShader: vertexShader, fragmentShader: fragmentShader, program: m_program)
      return false
    }
    
    let fragmentShaderPath = NSBundle.mainBundle().pathForResource(fragmentShaderName, ofType: "fsh")
    if Renderer.compileShader(&fragmentShader, type: GLenum(GL_FRAGMENT_SHADER), file: fragmentShaderPath!) != true {
      Renderer.destroyShaders(vertexShader: vertexShader, fragmentShader: fragmentShader, program: m_program)
      return false
    }
    
    glAttachShader(m_program, vertexShader)
    glAttachShader(m_program, fragmentShader)
    
    glBindAttribLocation(m_program, VertexAttributeLocation, ("a_vertex" as NSString).UTF8String)
    
    if Renderer.linkProgram(m_program) != true {
      Renderer.destroyShaders(vertexShader: vertexShader, fragmentShader: fragmentShader, program: m_program)
      return false
    }
    
    m_mvpUniform = glGetUniformLocation(m_program, ("u_mvp" as NSString).UTF8String)
    m_colorUniform = glGetUniformLocation(m_program, ("u_color" as NSString).UTF8String)
    m_pointSizeUniform = glGetUniformLocation(m_program, ("u_pointSize" as NSString).UTF8String)
    
    Renderer.destroyShaders(vertexShader: vertexShader, fragmentShader: fragmentShader, program: nil)
    return true
  }
  
  class func compileShader(inout shader: GLuint, type: GLenum, file: String) -> Bool {
    var error: NSError? = nil
    let s: NSString?
    do {
      s = try NSString(contentsOfFile: file, encoding: NSUTF8StringEncoding)
    } catch let error1 as NSError {
      error = error1
      s = nil
    }
    if s == nil || error != nil {
      print("ERROR: shader load error")
      return false
    }
    var shaderStringUTF8: UnsafePointer<Int8> = s!.UTF8String
    shader = glCreateShader(type)
    glShaderSource(shader, 1, &shaderStringUTF8, nil)
    glCompileShader(shader)
    
    var status: GLint = 0
    glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
    if status == GL_FALSE {
      print("ERROR: failed to compile shader")
      return false
    }
    return true
  }
  
  class func linkProgram(program: GLuint) -> Bool {
    glLinkProgram(program)
    var status: GLint = 0
    glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
    if status == GL_FALSE {
      print("ERROR: failed to link prrogram")
      return false
    }
    return true
  }
  
  class func destroyShaders(vertexShader vertexShader: GLuint, fragmentShader: GLuint, program: GLuint?) {
    if vertexShader != 0 {
      glDeleteShader(vertexShader)
    }
    if fragmentShader != 0 {
      glDeleteShader(fragmentShader)
    }
    if program != nil && program! != 0 {
      glDeleteShader(program!)
    }
  }
  
}


