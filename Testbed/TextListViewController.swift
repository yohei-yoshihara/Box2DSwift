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

protocol TextListViewControllerDelegate {
  func textListDidSelect(name: String, index: Int)
}

class TextListViewController: UINavigationController {
  var textListName = ""
  var textList: [String] = []
  var textListDelegate: TextListViewControllerDelegate? = nil
  fileprivate var tableVC: TextListTableViewController! = nil
 
  override func viewDidLoad() {
    super.viewDidLoad()
    tableVC = TextListTableViewController()
    tableVC.title = title
    tableVC.textListName = textListName
    tableVC.textList = textList
    tableVC.delegate = textListDelegate
    self.show(tableVC, sender: self)
  }
}

private class TextListTableViewController: UITableViewController {
  let cellId = "CELL_ID"
  var textListName = ""
  var textList: [String] = []
  var delegate: TextListViewControllerDelegate? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
  }

  // UITableViewDataSource
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return textList.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: cellId)! 
    cell.textLabel!.text = textList[indexPath.row]
    return cell
  }
  
  // UITableViewDelegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.textListDidSelect(name: textListName, index: indexPath.row)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
