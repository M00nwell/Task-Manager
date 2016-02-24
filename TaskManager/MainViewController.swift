//
//  MainViewController.swift
//  TaskManager
//
//  Created by Wenzhe on 31/1/16.
//  Copyright © 2016 Wenzhe. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func toDoPressed(sender: UIButton) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TaskListVC") as! TaskListViewController
        vc.listCategory = Task.TODO
        navigationController!.pushViewController(vc, animated: true)
    }

    @IBAction func doingPressed(sender: UIButton) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TaskListVC") as! TaskListViewController
        vc.listCategory = Task.DOING
        navigationController!.pushViewController(vc, animated: true)
    }
    @IBAction func donePressed(sender: UIButton) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TaskListVC") as! TaskListViewController
        vc.listCategory = Task.DONE
        navigationController!.pushViewController(vc, animated: true)
    }

}

