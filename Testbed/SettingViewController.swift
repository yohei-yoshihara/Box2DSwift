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

class IterationCell: UITableViewCell {
  static let cellId = "IterationCell"
  @IBOutlet weak var propertyNameLabel: UILabel!
  @IBOutlet weak var stepper: UIStepper!
  
  init() {
    super.init(style: UITableViewCellStyle.default, reuseIdentifier: IterationCell.cellId)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

class SwitchCell: UITableViewCell {
  static let cellId = "SwitchCell"
  @IBOutlet weak var propertyNameLabel: UILabel!
  @IBOutlet weak var propertySwitch: UISwitch!
  
  init() {
    super.init(style: UITableViewCellStyle.default, reuseIdentifier: SwitchCell.cellId)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

class HertzCell: UITableViewCell {
  static let cellId = "HertzCell"
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  init() {
    super.init(style: UITableViewCellStyle.default, reuseIdentifier: HertzCell.cellId)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

protocol SettingViewControllerDelegate {
  func didSettingsChanged(_ settings: Settings)
}

class SettingViewController: UINavigationController {
  fileprivate var tableVC: SettingTableViewController! = nil
  var settings: Settings!
  var settingViewControllerDelegate: SettingViewControllerDelegate? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableVC = SettingTableViewController()
    tableVC.settings = settings
    tableVC.settingViewControllerDelegate = settingViewControllerDelegate
    self.show(tableVC, sender: self)
  }
}

class SettingTableViewController: UITableViewController {
  var settings: Settings!
  var settingViewControllerDelegate: SettingViewControllerDelegate? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Settings"
    
    let interationCellNib = UINib(nibName: IterationCell.cellId, bundle: nil)
    self.tableView.register(interationCellNib, forCellReuseIdentifier: IterationCell.cellId)
    let switchCellNib = UINib(nibName: SwitchCell.cellId, bundle: nil)
    self.tableView.register(switchCellNib, forCellReuseIdentifier: SwitchCell.cellId)
    let hertzCellNib = UINib(nibName: HertzCell.cellId, bundle: nil)
    self.tableView.register(hertzCellNib, forCellReuseIdentifier: HertzCell.cellId)
    
    self.tableView.dataSource = self
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(SettingTableViewController.onDone(_:)))
  }
  
  @objc func onDone(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
// UITableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 7
    }
    else if section == 1 {
      return 10
    }
    return 0
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var _cell: UITableViewCell! = nil
    if indexPath.section == 0 {
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: IterationCell.cellId, for: indexPath) as! IterationCell
        cell.propertyNameLabel.text = "Velocity Iterations \(settings.velocityIterations)"
        cell.stepper.value = Double(settings.velocityIterations)
        cell.stepper.minimumValue = 1
        cell.stepper.tag = 0
        cell.stepper.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: IterationCell.cellId, for: indexPath) as! IterationCell
        cell.propertyNameLabel.text = "Position Iterations \(settings.positionIterations)"
        cell.stepper.value = Double(settings.positionIterations)
        cell.stepper.minimumValue = 1
        cell.stepper.tag = 1
        cell.stepper.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 2 {
        let cell = tableView.dequeueReusableCell(withIdentifier: HertzCell.cellId, for: indexPath) as! HertzCell
        cell.segmentedControl.selectedSegmentIndex = settings.hz == 30.0 ? 0 : 1
        cell.segmentedControl.tag = 2
        cell.segmentedControl.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 3 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Sleep"
        cell.propertySwitch.isOn = settings.enableSleep
        cell.propertySwitch.tag = 3
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 4 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Warm Starting"
        cell.propertySwitch.isOn = settings.enableWarmStarting
        cell.propertySwitch.tag = 4
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 5 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Time of Impact"
        cell.propertySwitch.isOn = settings.enableContinuous
        cell.propertySwitch.tag = 5
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 6 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Sub-Stepping"
        cell.propertySwitch.isOn = settings.enableSubStepping
        cell.propertySwitch.tag = 6
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
    }
    else {
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Shapes"
        cell.propertySwitch.isOn = settings.drawShapes
        cell.propertySwitch.tag = 7
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Joints"
        cell.propertySwitch.isOn = settings.drawJoints
        cell.propertySwitch.tag = 8
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 2 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "AABBs"
        cell.propertySwitch.isOn = settings.drawAABBs
        cell.propertySwitch.tag = 9
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 3 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Contact Points"
        cell.propertySwitch.isOn = settings.drawContactPoints
        cell.propertySwitch.tag = 10
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 4 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Contact Normals"
        cell.propertySwitch.isOn = settings.drawContactNormals
        cell.propertySwitch.tag = 11
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 5 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Contact Impulses"
        cell.propertySwitch.isOn = settings.drawContactImpulse
        cell.propertySwitch.tag = 12
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 6 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Friction Impulses"
        cell.propertySwitch.isOn = settings.drawFrictionImpulse
        cell.propertySwitch.tag = 13
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 7 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Center of Masses"
        cell.propertySwitch.isOn = settings.drawCOMs
        cell.propertySwitch.tag = 14
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 8 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Statistics"
        cell.propertySwitch.isOn = settings.drawStats
        cell.propertySwitch.tag = 15
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
      else if indexPath.row == 9 {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.cellId, for: indexPath) as! SwitchCell
        cell.propertyNameLabel.text = "Profile"
        cell.propertySwitch.isOn = settings.drawProfile
        cell.propertySwitch.tag = 16
        cell.propertySwitch.addTarget(self, action: #selector(SettingTableViewController.onValueChanged(_:)), for: UIControlEvents.valueChanged)
        _cell = cell
      }
    }
    return _cell
  }
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "BASIC"
    }
    else {
      return "DRAW"
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44
  }
  
  @objc func onValueChanged(_ sender: UIControl) {
    if sender.tag == 0 {
      let stepper = sender as! UIStepper
      let value = Int(stepper.value)
      settings.velocityIterations = value
      let indexPath = IndexPath(row: 0, section: 0)
      self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    else if sender.tag == 1 {
      let stepper = sender as! UIStepper
      let value = Int(stepper.value)
      settings.positionIterations = value
      let indexPath = IndexPath(row: 1, section: 0)
      self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    else if sender.tag == 2 {
      let segmentedControl = sender as! UISegmentedControl
      settings.hz = segmentedControl.selectedSegmentIndex == 0 ? b2Float(30) : b2Float(60)
    }
    else if sender.tag == 3 {
      let switchControl = sender as! UISwitch
      settings.enableSleep = switchControl.isOn
    }
    else if sender.tag == 4 {
      let switchControl = sender as! UISwitch
      settings.enableWarmStarting = switchControl.isOn
    }
    else if sender.tag == 5 {
      let switchControl = sender as! UISwitch
      settings.enableContinuous = switchControl.isOn
    }
    else if sender.tag == 6 {
      let switchControl = sender as! UISwitch
      settings.enableSubStepping = switchControl.isOn
    }
    else if sender.tag == 7 {
      let switchControl = sender as! UISwitch
      settings.drawShapes = switchControl.isOn
    }
    else if sender.tag == 8 {
      let switchControl = sender as! UISwitch
      settings.drawJoints = switchControl.isOn
    }
    else if sender.tag == 9 {
      let switchControl = sender as! UISwitch
      settings.drawAABBs = switchControl.isOn
    }
    else if sender.tag == 10 {
      let switchControl = sender as! UISwitch
      settings.drawContactPoints = switchControl.isOn
    }
    else if sender.tag == 11 {
      let switchControl = sender as! UISwitch
      settings.drawContactNormals = switchControl.isOn
    }
    else if sender.tag == 12 {
      let switchControl = sender as! UISwitch
      settings.drawContactImpulse = switchControl.isOn
    }
    else if sender.tag == 13 {
      let switchControl = sender as! UISwitch
      settings.drawFrictionImpulse = switchControl.isOn
    }
    else if sender.tag == 14 {
      let switchControl = sender as! UISwitch
      settings.drawCOMs = switchControl.isOn
    }
    else if sender.tag == 15 {
      let switchControl = sender as! UISwitch
      settings.drawStats = switchControl.isOn
    }
    else if sender.tag == 16 {
      let switchControl = sender as! UISwitch
      settings.drawProfile = switchControl.isOn
    }
    settingViewControllerDelegate?.didSettingsChanged(settings)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
