//
//  TaskDetailViewController.swift
//  TaskManager
//
//  Created by Wenzhe on 21/2/16.
//  Copyright © 2016 Wenzhe. All rights reserved.
//

import UIKit
import CoreData

class TaskDetailViewController: UIViewController, TaskEditViewControllerDelegate {
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var importantImage: UIImageView!
    @IBOutlet weak var urgentImage: UIImageView!
    @IBOutlet weak var alarmImage: UIImageView!
    @IBOutlet weak var deadlineLable: UILabel!
    @IBOutlet weak var contentField: UITextView!
    
    let secondsInDay : Double = 60*60*24
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentField.text = ""
        updatePage()
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "composePressed")]
    }
    
    override func viewDidLayoutSubviews() {
        contentField.setContentOffset(CGPointZero, animated: false)
    }
    
    ///task edit view controller delegate
    func taskEdited(taskEditer: TaskEditViewController, dic: [String : AnyObject]) {
        task?.title = dic[Task.Keys.Title] as! String
        task?.deadline = dic[Task.Keys.Deadline] as! NSDate
        task?.content = dic[Task.Keys.Content] as! String
        task?.urgent = dic[Task.Keys.Urgent] as! Bool
        task?.important = dic[Task.Keys.Important] as! Bool
        task?.reminder = dic[Task.Keys.Reminder] as! Bool
        CoreDataStackManager.sharedInstance().saveContext()
        updatePage()
    }
    

    
    
    ///helper function to update view
    func updatePage(){
        if let myTask = task {
            taskLabel.text = myTask.title
            importantImage.hidden = !(myTask.important as Bool)
            urgentImage.hidden = !(myTask.urgent as Bool)
            contentField.text = myTask.content
            if(myTask.reminder as Bool){
                alarmImage.alpha = 1
            }else{
                alarmImage.alpha = 0.3
            }
            if(myTask.deadline != NSDate.distantFuture()){
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy MMM dd, hh:mm a"
                deadlineLable.text = dateFormatter.stringFromDate(myTask.deadline)
                updateDeadlineColor(myTask.deadline)
            }else{
                deadlineLable.text = "No Deadline"
                deadlineLable.textColor = UIColor(hex: 0x6c6c6c, alpha: 1)
                alarmImage.alpha = 0.3
            }
        }
    }
    
    ///helper function to update dead line text color
    func updateDeadlineColor(date: NSDate){
        let now = NSDate()
        if(date.timeIntervalSince1970 >= now.timeIntervalSince1970 + 4*secondsInDay){
            deadlineLable.textColor = UIColor(hex: 0x306616, alpha: 1)
        }else if(date.timeIntervalSince1970 >= now.timeIntervalSince1970 + 3*secondsInDay){
            deadlineLable.textColor = UIColor(hex: 0x636616, alpha: 1)
        }else if(date.timeIntervalSince1970 >= now.timeIntervalSince1970 + 2*secondsInDay){
            deadlineLable.textColor = UIColor(hex: 0x8a6616, alpha: 1)
        }else if(date.timeIntervalSince1970 >= now.timeIntervalSince1970 + 1*secondsInDay){
            deadlineLable.textColor = UIColor(hex: 0xc14c16, alpha: 1)
        }else if(date.timeIntervalSince1970 >= now.timeIntervalSince1970){
            deadlineLable.textColor = UIColor(hex: 0xc91416, alpha: 1)
        }else{
            deadlineLable.textColor = UIColor(hex: 0x6c6c6c, alpha: 1)
        }
        
    }
    
    
    
    ///compose button action
    func composePressed() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TaskEditVC") as! TaskEditViewController
        controller.delegate = self
        controller.task = task
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
}