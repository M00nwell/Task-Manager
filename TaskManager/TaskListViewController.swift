//
//  TaskListViewController.swift
//  TaskManager
//
//  Created by Wenzhe on 21/2/16.
//  Copyright © 2016 Wenzhe. All rights reserved.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController, NSFetchedResultsControllerDelegate, TaskEditViewControllerDelegate {
    
    var listCategory:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch(listCategory!){
        case Task.TODO:
            navigationItem.title = "ToDo"
            break
        case Task.DOING:
            navigationItem.title = "Doing"
            break
        case Task.DONE:
            navigationItem.title = "Done"
            break
        default:
            print("wrong list catefory, \(listCategory)")
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTask")
       
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "urgent", ascending: false), NSSortDescriptor(key: "important", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "category == %d", self.listCategory);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
    // table view delegate/////////////////////
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let CellIdentifier = "TaskTableCell"
            
            let task = fetchedResultsController.objectAtIndexPath(indexPath) as! Task
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as!
            TaskTableCell
            
            configureCell(cell, withTask: task)
            return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let controller =
            storyboard!.instantiateViewControllerWithIdentifier("TaskDetailVC") as! TaskDetailViewController
            let task = fetchedResultsController.objectAtIndexPath(indexPath) as! Task
            controller.task = task            
            self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let move = UITableViewRowAction(style: .Normal, title: "Move") { action, index in
            let menu = UIAlertController(title: nil, message: "Move To", preferredStyle: .ActionSheet)
            let todoAction = UIAlertAction(title: "TO DO", style: UIAlertActionStyle.Default, handler: { _ in self.moveTask(indexPath, destination: Task.TODO)})
            let doingAction = UIAlertAction(title: "DOING", style: UIAlertActionStyle.Default, handler: { _ in self.moveTask(indexPath, destination: Task.DOING)})
            let doneAction = UIAlertAction(title: "DONE", style: UIAlertActionStyle.Default, handler: { _ in self.moveTask(indexPath, destination: Task.DONE)})
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            switch(self.listCategory){
            case Task.TODO:
                menu.addAction(doingAction)
                menu.addAction(doneAction)
                break
            case Task.DOING:
                menu.addAction(todoAction)
                menu.addAction(doneAction)
                break
            case Task.DONE:
                menu.addAction(todoAction)
                menu.addAction(doingAction)
                break
            default:
                break
            }
            menu.addAction(cancelAction)
            self.presentViewController(menu, animated: true, completion: nil)
        }
        move.backgroundColor = UIColor.orangeColor()
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            self.deleteTask(indexPath)
        }
        delete.backgroundColor = UIColor.lightGrayColor()

        return [delete, move]
    }
    

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    ///////////////////////////////
    
    // TaskEditViewController Delegate////////////////
    func taskEdited(taskEditer: TaskEditViewController, dic: [String : AnyObject]) {
        let _ = Task(dictionary: dic, context: sharedContext)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    //////////////////////////////
    
    // helper functions////////////////////////////
    func addTask() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TaskEditVC") as! TaskEditViewController
        controller.delegate = self
        controller.listCategory = self.listCategory
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func configureCell(cell: TaskTableCell, withTask: Task){
        cell.titleLabel.text = withTask.title
        cell.iImageView.hidden = !(withTask.important as Bool)
        cell.uImageView.hidden = !(withTask.urgent as Bool)
    }
    
    func deleteTask(indexPath: NSIndexPath){
        let task = fetchedResultsController.objectAtIndexPath(indexPath) as! Task
        sharedContext.deleteObject(task)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func moveTask(indexPath: NSIndexPath, destination: Int){
        let task = fetchedResultsController.objectAtIndexPath(indexPath) as! Task
        task.category = destination
        CoreDataStackManager.sharedInstance().saveContext()
        //tableView.reloadData()
    }
    
    //////////////////////////////////
    
    // fetch result controller protocol////////////////
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                
            case .Update:
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! TaskTableCell
                let task = controller.objectAtIndexPath(indexPath!) as! Task
                self.configureCell(cell, withTask: task)
                
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    /////////////////////////////////////////
}