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
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    settings = Settings()
    settingsVC = SettingViewController()
    
    debugDraw = RenderView(frame: CalculateRenderViewFrame(self.view))
    debugDraw.autoresizingMask = UIView.AutoresizingMask()
    debugDraw.SetFlags(settings.debugDrawFlag)
    self.view.addSubview(debugDraw)
    
    infoView = InfoView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
    infoView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
    self.view.addSubview(infoView)

    let pauseButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause,
      target: self, action: #selector(BaseViewController.onPause(_:)))
    let singleStepButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play,
      target: self, action: #selector(BaseViewController.onSingleStep(_:)))
    let flexibleButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    self.toolbarItems = [
      flexibleButton, pauseButton,
      flexibleButton, singleStepButton,
      flexibleButton
    ]
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItem.Style.plain, target: self, action: #selector(BaseViewController.onSettings(_:)))
    
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(BaseViewController.onPan(_:)))
    debugDraw.addGestureRecognizer(panGestureRecognizer)
    tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BaseViewController.onTap(_:)))
    debugDraw.addGestureRecognizer(tapGestureRecognizer)
  }

  func addToolbarItems(_ additionalToolbarItems: [UIBarButtonItem]) {
    var toolbarItems = [UIBarButtonItem]()
    toolbarItems += self.toolbarItems!
    toolbarItems += additionalToolbarItems
    self.toolbarItems = toolbarItems
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // World
    let gravity = b2Vec2(0.0, -10.0)
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    displayLink = CADisplayLink(target: self, selector: #selector(BaseViewController.simulationLoop))
    displayLink.preferredFramesPerSecond = Int(settings.hz)
    displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
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
  
  @objc func simulationLoop() {
    debugDraw.preRender()
    bombLauncher.render()
    let timeStep = settings.calcTimeStep()
    settings.apply(world)
    contactListener.clearPoints()
    world.step(timeStep: timeStep, velocityIterations: settings.velocityIterations, positionIterations: settings.positionIterations)
    world.drawDebugData()
    
    if timeStep > 0.0 {
      stepCount += 1
    }
    
    infoView.updateProfile(stepCount)
    contactListener.drawContactPoints(settings, renderView: debugDraw)
    
    step()
    
    debugDraw.postRender()
  }
  
  func step() {
  }
  
  @objc func onPause(_ sender: UIBarButtonItem) {
    settings.pause = !settings.pause
  }
  
  @objc func onSingleStep(_ sender: UIBarButtonItem) {
    settings.pause = true
    settings.singleStep = true
  }
  
  @objc func onSettings(_ sender: UIBarButtonItem) {
    settingsVC.settings = settings
    settingsVC.settingViewControllerDelegate = self
    settingsVC.modalPresentationStyle = UIModalPresentationStyle.popover
    let popPC = settingsVC.popoverPresentationController
    popPC?.barButtonItem = sender
    popPC?.permittedArrowDirections = UIPopoverArrowDirection.any
    self.present(settingsVC, animated: true, completion: nil)
  }

  func didSettingsChanged(_ settings: Settings) {
    self.settings = settings
    infoView.enableProfile = settings.drawProfile
    infoView.enableStats = settings.drawStats
    displayLink.preferredFramesPerSecond = Int(settings.hz)
    debugDraw.SetFlags(settings.debugDrawFlag)
  }

  @objc func onPan(_ gr: UIPanGestureRecognizer) {
    let p = gr.location(in: debugDraw)
    let wp = ConvertScreenToWorld(p, size: debugDraw.bounds.size, viewCenter: settings.viewCenter)
    
    switch gr.state {
    case .began:
      let d = b2Vec2(0.001, 0.001)
      var aabb = b2AABB()
      aabb.lowerBound = wp - d
      aabb.upperBound = wp + d
      let callback = QueryCallback(point: wp)
      world.queryAABB(callback: callback, aabb: aabb)
      if callback.fixture != nil {
        let body = callback.fixture!.body
        let md = b2MouseJointDef()
        md.bodyA = groundBody
        md.bodyB = body
        md.target = wp
        md.maxForce = 1000.0 * body.mass
        mouseJoint = world.createJoint(md)
        body.setAwake(true)
      }
      else {
        bombLauncher.onPan(gr)
      }
      
    case .changed:
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
  
  @objc func onTap(_ gr: UITapGestureRecognizer) {
    bombLauncher.onTap(gr)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
