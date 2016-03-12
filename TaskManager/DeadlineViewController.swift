//
//  DeadlineViewController.swift
//  TaskManager
//
//  Created by Wenzhe on 28/2/16.
//  Copyright © 2016 Wenzhe. All rights reserved.
//

import UIKit

protocol DeadlineViewControllerDelegate {
    func saveDeadline(deadline: NSDate, reminder: Bool)
    func cancelDeadline()
    func removeDeadline()
}

class DeadlineViewController: UIViewController {
    
    var delegate : DeadlineViewControllerDelegate?
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var rSwitch: UISwitch!
    @IBOutlet weak var topLabel: UILabel!
    var deadline : NSDate?
    var reminder : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(deadline != nil){
            removeButton.hidden = false
            topLabel.text = "Edit Deadline"
            datePicker.date = deadline!
            rSwitch.setOn(reminder!, animated: false)
        }else{
            removeButton.hidden = true
            topLabel.text = "Add Deadline"
            rSwitch.setOn(false, animated: false)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
    
    @IBAction func rSwitchToggled(sender: AnyObject) {
        if(rSwitch.on)
        {
            guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
            if settings.types == .None {
                let ac = UIAlertController(title: "Can't Set Reminder", message: "Please configure in Settings to allow Task Manager to send notifications", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(ac, animated: true, completion: nil)
                rSwitch.setOn(false, animated: false)
            }
        }
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        delegate?.saveDeadline(datePicker.date, reminder: rSwitch.on)
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        delegate?.cancelDeadline()
    }
    
    @IBAction func removePressed(sender: AnyObject) {
        delegate?.removeDeadline()
        datePicker.date = NSDate()
    }
    
    
}
