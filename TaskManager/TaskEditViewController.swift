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

class TaskEditViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIToolbarDelegate, DeadlineViewControllerDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var iSwitch: UISwitch!
    @IBOutlet weak var uSwitch: UISwitch!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var deadLineView: UIView!
    @IBOutlet weak var addDeadlineButton: UIButton!
    @IBOutlet weak var alarmButton: UIButton!
    @IBOutlet weak var deadlineButton: UIButton!
    @IBOutlet weak var topBar: UIToolbar!
    
    var listCategory: Int!
    var deadline : NSDate = NSDate.distantFuture()
    var bReminder: Bool = false
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    var delegate: TaskEditViewControllerDelegate?
    var task: Task?
    var containerView = UIView()
    var deadLineVC: DeadlineViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iSwitch.setOn(false, animated: false)
        uSwitch.setOn(false, animated: false)
        alarmButton.hidden = true
        deadlineButton.hidden = true
        if let mytask = task {
            titleTextField.text = mytask.title
            contentTextView.text = mytask.content
            
            iSwitch.setOn(mytask.important as Bool, animated: false)
            uSwitch.setOn(mytask.urgent as Bool, animated: false)
            listCategory = mytask.category as Int
            if(mytask.deadline != NSDate.distantFuture()){
                saveDeadline(mytask.deadline, reminder: mytask.reminder as Bool)
            }
        }
 
        titleTextField.delegate = self
        contentTextView.delegate = self
        topBar.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        deadLineView.frame.origin.y = self.view.frame.size.height
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = UIColor(hex: 0x888888, alpha: 0.5)
        view.addSubview(containerView)
        containerView.hidden = true
        
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotification()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "embedded"){
            print("segueing")
            deadLineVC = segue.destinationViewController as? DeadlineViewController
            deadLineVC!.delegate = self
            if(task != nil)
            {
                if(task?.deadline != NSDate.distantFuture()){
                    deadLineVC!.deadline = task?.deadline
                    deadLineVC!.reminder = task?.reminder as? Bool
                }
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
    
    // UIToolBarDelegate ////////////////
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    /////////////////////////////////////////////
    
    //textfield delegate///////
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 50
    }
    ///////////////////////////
    
    // textView delegate////////
    
    func textViewDidChange(textView: UITextView) {
        let line = textView.caretRectForPosition((textView.selectedTextRange?.start)!)
        let overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top )
        if (overflow > 0){
            var offset = textView.contentOffset
            offset.y += overflow + 7
            //UIView.animateWithDuration(0.2, animations: { () -> Void in
                textView.setContentOffset(offset, animated: true)
            //})
        }
    }
    
    ////////////////////////////////////
    
    // To shift view up when editing bottom textfield
    func keyboardWillShow(notification: NSNotification){
        if(contentTextView.isFirstResponder()){
            view.frame.origin.y = -getKeyboardHeight(notification) + (view.frame.height - contentTextView.frame.origin.y - contentTextView.frame.height)
            topBar.frame.origin.y = 0
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    ////////////////////////////////////////
    
    
    //deadline view controller delegate//////
    func saveDeadline(deadline: NSDate, reminder: Bool){
        self.deadline = deadline
        self.bReminder = reminder
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy MMM dd, hh:mm a"
        deadlineButton.setTitle("Deadline: " + dateFormatter.stringFromDate(deadline), forState: .Normal)
        deadlineButton.hidden = false
        alarmButton.hidden = false
        if(reminder){
            alarmButton.alpha = 1
        }else{
            alarmButton.alpha = 0.2
        }
       
        addDeadlineButton.hidden = true
        hideDeadlineMenu()
    }
    func cancelDeadline(){
        hideDeadlineMenu()
    }
    func removeDeadline(){
        self.deadline = NSDate.distantFuture()
        self.bReminder = false
        
        deadlineButton.hidden = true
        alarmButton.hidden = true
        addDeadlineButton.hidden = false
        hideDeadlineMenu()
    }
    ///////////////////////////
    
    
    //helper functions////////////////////
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func shakeWarning(txtField: UITextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(txtField.center.x - 10, txtField.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(txtField.center.x + 10, txtField.center.y))
        txtField.layer.addAnimation(animation, forKey: "position")
    }
    
    func showDeadlineMenu(){
        containerView.hidden = false
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: { () -> Void in
            self.deadLineView.frame.origin.y -= self.deadLineView.frame.height
            self.containerView.frame.origin.y -= self.deadLineView.frame.height
            }, completion: nil)
    }
    
    func hideDeadlineMenu(){
        containerView.hidden = true
        containerView.frame = view.frame
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: { () -> Void in
            self.deadLineView.frame.origin.y = self.view.frame.size.height
            }, completion: nil)
    }
    ///////////////////////////////
    
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showDeadLine(sender: AnyObject) {
        deadLineVC!.rSwitch.setOn(false, animated: false)
        deadLineVC!.removeButton.hidden = true
        showDeadlineMenu()
    }
    
    @IBAction func alarmPressed(sender: AnyObject) {
        if(bReminder){
            bReminder = false
            alarmButton.alpha = 0.2
        }else{
            guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
            if settings.types == .None {
                let ac = UIAlertController(title: "Can't Set Reminder", message: "Please configure in Settings to allow Task Manager to send notifications", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(ac, animated: true, completion: nil)
            }else{
                bReminder = true
                alarmButton.alpha = 1
            }
        }
    }
    
    @IBAction func editDeadline(sender: AnyObject) {
        deadLineVC!.rSwitch.setOn(bReminder, animated: false)
        deadLineVC!.removeButton.hidden = false
        showDeadlineMenu()
    }
    
    @IBAction func donePressed(sender: UIBarButtonItem) {
        if(titleTextField.text == ""){
            shakeWarning(titleTextField)
            return
        }
        let dic: [String : AnyObject] = [
            Task.Keys.Title : titleTextField.text!,
            Task.Keys.Category : listCategory!,
            Task.Keys.Urgent : uSwitch.on,
            Task.Keys.Important : iSwitch.on,
            Task.Keys.Content : contentTextView.text,
            Task.Keys.Reminder : bReminder,
            Task.Keys.Deadline : deadline
        ]
        delegate?.taskEdited(self, dic: dic)
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if(bReminder){
            let notification = UILocalNotification()
            notification.fireDate = deadline
            notification.alertBody = "Deadline of Task: \"" + titleTextField.text! + "\""
            notification.alertAction = "check task"
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = ["CustomField1": "w00t"]
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
