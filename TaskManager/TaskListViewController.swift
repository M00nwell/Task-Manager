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
            //let controller =
            //storyboard!.instantiateViewControllerWithIdentifier("MovieListViewController")
             //   as! MovieListViewController
            
            // Similar to the method above
            //let actor = fetchedResultsController.objectAtIndexPath(indexPath) as! Person
            
            //controller.actor = actor
            
            //self.navigationController!.pushViewController(controller, animated: true)
    }
    
    ///////////////////////////////
    
    //TaskEditViewController Delegate////////////////
    func taskEdited(taskEditer: TaskEditViewController, dic: [String : AnyObject]) {
        let _ = Task(dictionary: dic, context: sharedContext)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
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