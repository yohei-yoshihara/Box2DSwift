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

class AdditionalInfoView: UIView {
  var label: UILabel!
  var s = String()
  var lastUpdate: CFTimeInterval = 0

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
    self.isUserInteractionEnabled = false
    
    let size = self.bounds.size
    label = UILabel(frame: CGRect(x: 0, y: size.height - 1, width: 1, height: 1))
    label.autoresizingMask = [UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleRightMargin]
    label.numberOfLines = 0
    label.backgroundColor = UIColor.clear
    label.isOpaque = false
    label.textColor = UIColor.white
    label.font = UIFont.systemFont(ofSize: 10)
    self.addSubview(label)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func begin() {
    s.removeAll(keepingCapacity: true)
  }
  
  func append(_ str: String) {
    s += str
  }
 
  func end() {
    if CACurrentMediaTime() - lastUpdate < 0.3 {
      return
    }
    
    label.text = s
    label.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
    label.sizeToFit()
    label.frame = CGRect(x: 0, y: self.bounds.size.height - label.frame.size.height,
      width: label.frame.size.width, height: label.frame.size.height)
    lastUpdate = CACurrentMediaTime()
  }
  
  override func layoutSubviews() {
    label.frame = CGRect(x: 0, y: self.bounds.size.height - label.frame.size.height,
      width: label.frame.size.width, height: label.frame.size.height)
  }
}
