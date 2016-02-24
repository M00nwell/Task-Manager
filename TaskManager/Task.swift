//
//  Task.swift
//  TaskManager
//
//  Created by Wenzhe on 31/1/16.
//  Copyright © 2016 Wenzhe. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Task: NSManagedObject {
    
    static let TODO : Int = 1
    static let DOING : Int = 2
    static let DONE : Int = 3
    
    struct Keys {
        static let Title = "title"
        static let Content = "content"
        static let Deadline = "deadline"
        static let Reminder = "reminder"
        static let Urgent = "urgent"
        static let Important = "important"
        static let Category = "category"
    }
    
    @NSManaged var title: String
    @NSManaged var content: String
    @NSManaged var deadline: NSDate
    @NSManaged var reminder: NSNumber
    @NSManaged var urgent: NSNumber
    @NSManaged var important: NSNumber
    @NSManaged var category: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext){
        let entity =  NSEntityDescription.entityForName("Task", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        title = dictionary[Keys.Title] as! String
        content = dictionary[Keys.Content] as! String
        deadline = dictionary[Keys.Deadline] as! NSDate
        reminder = dictionary[Keys.Reminder] as! Bool
        important = dictionary[Keys.Important] as! Bool
        urgent = dictionary[Keys.Urgent] as! Bool
        category = dictionary[Keys.Category] as! Int
    }
}

