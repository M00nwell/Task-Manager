//
//  TaskEditViewController.swift
//  TaskManager
//
//  Created by Wenzhe on 21/2/16.
//  Copyright © 2016 Wenzhe. All rights reserved.
//
import UIKit
import CoreData

protocol TaskEditViewControllerDelegate {
    func taskEdited(taskEditer: TaskEditViewController, dic: [String:AnyObject])
}

class TaskEditViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var iSwitch: UISwitch!
    @IBOutlet weak var uSwitch: UISwitch!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var rSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var listCategory: Int!
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var delegate: TaskEditViewControllerDelegate?
    var task: Task? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iSwitch.setOn(false, animated: false)
        uSwitch.setOn(false, animated: false)
        titleTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    //textfield delegate///////
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    ///////////////////////////
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func donePressed(sender: UIBarButtonItem) {
        let dic: [String : AnyObject] = [
            Task.Keys.Title : titleTextField.text!,
            Task.Keys.Category : listCategory!,
            Task.Keys.Urgent : uSwitch.on,
            Task.Keys.Important : iSwitch.on,
            Task.Keys.Content : contentTextView.text,
            Task.Keys.Reminder : rSwitch.on,
            Task.Keys.Deadline : datePicker.date
        ]
        delegate?.taskEdited(self, dic: dic)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
