//
//  LoginViewController.swift
//  TaskManager
//
//  Created by Wenzhe on 18/2/16.
//  Copyright © 2016 Wenzhe. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func offlinePressed(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("mainVC") as! MainViewController
        navigationController!.pushViewController(vc, animated: true)
    }
    
    
}
