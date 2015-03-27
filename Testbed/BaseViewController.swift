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

class BaseViewController: UIViewController, SettingViewControllerDelegate {
  var settings: Settings!
  var displayLink: CADisplayLink!
  var debugDraw: RenderView!
  var infoView: InfoView!
  var stepCount = 0
  var contactListener: ContactListener!
  var world: b2World!
  var settingsVC: SettingViewController!
  var bombLauncher: BombLauncher!
  var mouseJoint: b2MouseJoint? = nil
  var groundBody: b2Body!
  var panGestureRecognizer: UIPanGestureRecognizer!
  var tapGestureRecognizer: UITapGestureRecognizer!
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    settings = Settings()
    settingsVC = SettingViewController()
    
    debugDraw = RenderView(frame: CalculateRenderViewFrame(self.view))
    debugDraw.autoresizingMask = UIViewAutoresizing.None
    debugDraw.SetFlags(settings.debugDrawFlag)
    self.view.addSubview(debugDraw)
    
    infoView = InfoView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
    infoView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
    self.view.addSubview(infoView)

    let pauseButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause,
      target: self, action: "onPause:")
    let singleStepButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play,
      target: self, action: "onSingleStep:")
    let flexibleButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    self.toolbarItems = [
      flexibleButton, pauseButton,
      flexibleButton, singleStepButton,
      flexibleButton
    ]
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain, target: self, action: "onSettings:")
    
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onPan:")
    debugDraw.addGestureRecognizer(panGestureRecognizer)
    tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onTap:")
    debugDraw.addGestureRecognizer(tapGestureRecognizer)
  }

  func addToolbarItems(additionalToolbarItems: [AnyObject]) {
    var toolbarItems = [AnyObject]()
    toolbarItems += self.toolbarItems!
    toolbarItems += additionalToolbarItems
    self.toolbarItems = toolbarItems
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // World
    var gravity = b2Vec2(0.0, -10.0)
    world = b2World(gravity: gravity)
    contactListener = ContactListener()
    world.setContactListener(contactListener)
    world.setDebugDraw(debugDraw)
    bombLauncher = BombLauncher(world: world, renderView: debugDraw, viewCenter: settings.viewCenter)
    infoView.world = world
    
    let bodyDef = b2BodyDef()
    groundBody = world.createBody(bodyDef)
    
    prepare()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    displayLink = CADisplayLink(target: self, selector: "simulationLoop")
    displayLink.frameInterval = 60 / Int(settings.hz)
    displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
  }
  
  override func viewWillDisappear(animated: Bool) {
    if checkBackButton(self) {
      displayLink.invalidate()
      displayLink = nil
      
      world = nil
      bombLauncher = nil
      contactListener = nil
    }
  }

  override func viewDidLayoutSubviews() {
    debugDraw.frame = CalculateRenderViewFrame(self.view)
    let (lower, upper) = settings.calcViewBounds()
    debugDraw.setOrtho2D(left: lower.x, right: upper.x, bottom: lower.y, top: upper.y)
  }
  
  func prepare() {
  }
  
  func simulationLoop() {
    debugDraw.preRender()
    bombLauncher.render()
    let timeStep = settings.calcTimeStep()
    settings.apply(world)
    contactListener.clearPoints()
    world.step(timeStep: timeStep, velocityIterations: settings.velocityIterations, positionIterations: settings.positionIterations)
    world.drawDebugData()
    
    if timeStep > 0.0 {
      ++stepCount
    }
    
    infoView.updateProfile(stepCount)
    contactListener.drawContactPoints(settings, renderView: debugDraw)
    
    step()
    
    debugDraw.postRender()
  }
  
  func step() {
  }
  
  func onPause(sender: UIBarButtonItem) {
    settings.pause = !settings.pause
  }
  
  func onSingleStep(sender: UIBarButtonItem) {
    settings.pause = true
    settings.singleStep = true
  }
  
  func onSettings(sender: UIBarButtonItem) {
    settingsVC.settings = settings
    settingsVC.settingViewControllerDelegate = self
    settingsVC.modalPresentationStyle = UIModalPresentationStyle.Popover
    var popPC = settingsVC.popoverPresentationController
    popPC?.barButtonItem = sender
    popPC?.permittedArrowDirections = UIPopoverArrowDirection.Any
    self.presentViewController(settingsVC, animated: true, completion: nil)
  }

  func didSettingsChanged(settings: Settings) {
    self.settings = settings
    infoView.enableProfile = settings.drawProfile
    infoView.enableStats = settings.drawStats
    displayLink.frameInterval = 60 / Int(settings.hz)
    debugDraw.SetFlags(settings.debugDrawFlag)
  }

  func onPan(gr: UIPanGestureRecognizer) {
    let p = gr.locationInView(debugDraw)
    let wp = ConvertScreenToWorld(p, debugDraw.bounds.size, settings.viewCenter)
    
    switch gr.state {
    case .Began:
      let d = b2Vec2(0.001, 0.001)
      var aabb = b2AABB()
      aabb.lowerBound = wp - d
      aabb.upperBound = wp + d
      var callback = QueryCallback(point: wp)
      world.queryAABB(callback: callback, aabb: aabb)
      if callback.fixture != nil {
        let body = callback.fixture!.body
        var md = b2MouseJointDef()
        md.bodyA = groundBody
        md.bodyB = body
        md.target = wp
        md.maxForce = 1000.0 * body.mass
        mouseJoint = world.createJoint(md) as? b2MouseJoint
        body.setAwake(true)
      }
      else {
        bombLauncher.onPan(gr)
      }
      
    case .Changed:
      if mouseJoint != nil {
        mouseJoint!.setTarget(wp)
      }
      else {
        bombLauncher.onPan(gr)
      }
      
    default:
      if mouseJoint != nil {
        world.destroyJoint(mouseJoint!)
        mouseJoint = nil
      }
      else {
        bombLauncher.onPan(gr)
      }
    }
  }
  
  func onTap(gr: UITapGestureRecognizer) {
    bombLauncher.onTap(gr)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
