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

class InfoView: UIView {
  var label: UILabel!
  var enableStats = false
  var enableProfile = false
  weak var world: b2World? = nil
  var maxProfile = b2Profile()
  var totalProfile = b2Profile()
  var lastTimestamp: CFTimeInterval = 0
  var s = String()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.isUserInteractionEnabled = false
    self.backgroundColor = nil
    self.isOpaque = false
    label = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byTruncatingHead
    label.autoresizingMask = [UIView.AutoresizingMask.flexibleRightMargin, UIView.AutoresizingMask.flexibleBottomMargin]
    label.backgroundColor = nil
    label.isOpaque = false
    label.textColor = UIColor.white
    label.font = UIFont.systemFont(ofSize: 9)
    addSubview(label)
    lastTimestamp = CACurrentMediaTime()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func updateProfile(_ stepCount: Int) {
    if world == nil {
      return
    }
    
    let profile = world!.profile
    
    maxProfile.step = max(maxProfile.step, profile.step)
    maxProfile.collide = max(maxProfile.collide, profile.collide)
    maxProfile.solve = max(maxProfile.solve, profile.solve)
    maxProfile.solveInit = max(maxProfile.solveInit, profile.solveInit)
    maxProfile.solveVelocity = max(maxProfile.solveVelocity, profile.solveVelocity)
    maxProfile.solvePosition = max(maxProfile.solvePosition, profile.solvePosition)
    maxProfile.solveTOI = max(maxProfile.solveTOI, profile.solveTOI)
    maxProfile.broadphase = max(maxProfile.broadphase, profile.broadphase)
    
    totalProfile.step += profile.step
    totalProfile.collide += profile.collide
    totalProfile.solve += profile.solve
    totalProfile.solveInit += profile.solveInit
    totalProfile.solveVelocity += profile.solveVelocity
    totalProfile.solvePosition += profile.solvePosition
    totalProfile.solveTOI += profile.solveTOI
    totalProfile.broadphase += profile.broadphase
    
    if enableStats == false && enableProfile == false {
      if label.text?.isEmpty == false {
        label.text = ""
      }
      return
    }
    if CACurrentMediaTime() - lastTimestamp < 1.0 {
      return
    }
    
    s.removeAll(keepingCapacity: true)
    
    if enableStats && world != nil {
      let bodyCount = world!.bodyCount
      let contactCount = world!.contactCount
      let jointCount = world!.jointCount
      s += String(format:"bodies/contacts/joints = %d/%d/%d\n", bodyCount, contactCount, jointCount)
      
      let proxyCount = world!.proxyCount
      let height = world!.treeHeight
      let balance = world!.treeBalance
      let quality = world!.treeQuality
      s += String(format:"proxies/height/balance/quality = %d/%d/%d/%g\n", proxyCount, height, balance, quality)
    }
    
    if enableProfile {
      var aveProfile = b2Profile()
      if stepCount > 0 {
        let scale = b2Float(1.0) / b2Float(stepCount)
        aveProfile.step = scale * totalProfile.step
        aveProfile.collide = scale * totalProfile.collide
        aveProfile.solve = scale * totalProfile.solve
        aveProfile.solveInit = scale * totalProfile.solveInit
        aveProfile.solveVelocity = scale * totalProfile.solveVelocity
        aveProfile.solvePosition = scale * totalProfile.solvePosition
        aveProfile.solveTOI = scale * totalProfile.solveTOI
        aveProfile.broadphase = scale * totalProfile.broadphase
      }
      
      s += String(format: "step [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.step, aveProfile.step, maxProfile.step)
      s += String(format:  "collide [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.collide, aveProfile.collide, maxProfile.collide)
      s += String(format:  "solve [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.solve, aveProfile.solve, maxProfile.solve)
      s += String(format:  "solve init [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.solveInit, aveProfile.solveInit, maxProfile.solveInit)
      s += String(format:  "solve velocity [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.solveVelocity, aveProfile.solveVelocity, maxProfile.solveVelocity)
      s += String(format:  "solve position [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.solvePosition, aveProfile.solvePosition, maxProfile.solvePosition)
      s += String(format:  "solveTOI [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.solveTOI, aveProfile.solveTOI, maxProfile.solveTOI)
      s += String(format:  "broad-phase [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.broadphase, aveProfile.broadphase, maxProfile.broadphase)
    }
    
    label.text = s
    label.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
    label.sizeToFit()
    lastTimestamp = CACurrentMediaTime()
  }
}
