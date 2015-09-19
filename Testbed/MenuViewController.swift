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

typealias VCGen = () -> BaseViewController

class MenuViewController: UITableViewController {
  let cellId = "CELL_ID"
  let list: [(label: String, gen: VCGen)] = [
    ("Ray-Cast", {() in return RayCastViewController()}),
    ("Dump Shell", {() in return DumpShellViewController()}),
    ("Apply Force", {() in return ApplyForceViewController()}),
    ("Continuous Test", {() in return ContinuousTestViewController()}),
//    ("Time of Impact", {() in return TimeOfImpactViewController()}),
    ("Motor Joint", {() in return MotorJointViewController()}),
    ("One-Sided Platform", {() in return OneSidedPlatformViewController()}),
    ("Mobile", {() in return MobileViewController()}),
    ("MobileBalanced", {() in return MobileBalancedViewController()}),
    ("Conveyor Belt", {() in return ConveyorBeltViewController()}),
    ("Gear", {() in return GearViewController()}),
    ("Varying Restitution", {() in return VaryingRestitutionViewController()}),
    ("Tumbler", {() in return TumblerViewController()}),
    ("Tiles", {() in return TilesViewController()}),
    ("Cantilever", {() in return CantileverViewController()}),
    ("Character Collision", {() in return CharacterCollisionViewController()}),
    ("Edge Test", {() in return EdgeTestViewController()}),
    ("Body Types", {() in return BodyTypesViewController()}),
    ("Shape Editing", {() in return ShapeEditingViewController()}),
    ("Car", {() in return CarViewController()}),
    ("Prismatic", {() in return PrismaticViewController()}),
    ("Vertical Stack", {() in return VerticalStackViewController()}),
    ("Sphere Stack", {() in return SphereStackViewController()}),
    ("Revolute", {() in return RevoluteViewController()}),
    ("Pulleys", {() in return PulleysViewController()}),
    ("Polygon Shapes", {() in return PolyShapesViewController()}),
    ("Web", {() in return WebViewController()}),
    ("Rope Joint", {() in return RopeJointViewController()}),
    ("Pinball", {() in return PinballViewController()}),
    ("Bullet Test", {() in return BulletTestViewController()}),
    ("Confined", {() in return ConfinedViewController()}),
    ("Pyramid", {() in return PyramidViewController()}),
    ("Theo Jansen's Walker", {() in return TheoJansenViewController()}),
    ("Edge Shapes", {() in return EdgeShapesViewController()}),
    ("Poly Collision", {() in return PolyCollisionViewController()}),
    ("Bridge", {() in return BridgeViewController()}),
    ("Breakable", {() in return BreakableViewController()}),
    ("Chain", {() in return ChainViewController()}),
    ("Collision Filtering", {() in return CollisionFilteringViewController()}),
    ("Collision Processing", {() in return CollisionProcessingViewController()}),
    ("Compound Shapes", {() in return CompoundShapesViewController()}),
    ("Distance Test", {() in return DistanceTestViewController()}),
    ("Dominos", {() in return DominosViewController()}),
    ("Dynamic Tree", {() in return DynamicTreeTestViewController()}),
    ("Sensor Test", {() in return SensorTestViewController()}),
    ("Slider Crank", {() in return SliderCrankViewController()}),
    ("Varying Friction", {() in return VaryingFrictionViewController()}),
    ("Add Pair Stress Test", {() in return AddPairViewController()}),
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Testbed"
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellId)
  }
  
  // MARK: - UITableViewDataSource
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return list.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCellWithIdentifier(cellId)! 
    cell.textLabel!.text = list[indexPath.row].label
    return cell
  }
  
  // MARK: - UITableViewDelegate
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let vc = list[indexPath.row].gen()
    vc.title = list[indexPath.row].label
    self.showViewController(vc, sender: self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
