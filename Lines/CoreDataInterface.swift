//
//  CoreDataInterface.swift
//  Lines
//
//  Created by Tiago Mergulhão on 23/12/14.
//  Copyright (c) 2014 Tiago Mergulhão. All rights reserved.
//

import UIKit
import CoreData

public class CoreDataInterface : NSObject {
    public struct Environment {
        
        static var environmentDelegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        static var managedContext : NSManagedObjectContext = environmentDelegate.managedObjectContext!
        
        static var feeds : Array<NSManagedObject> = []
        
    }
    
    public var listView : [String] {
        return Environment.feeds.map({
            $0.valueForKey("address") as String
        })
    }
    
    public func loadSession () {
        let request = NSFetchRequest(entityName: "Feeds")
        
        var error : NSError?
        Environment.feeds = Environment.managedContext.executeFetchRequest(request, error: &error) as [NSManagedObject]
        
        if error != nil {
            println(error!.description)
        }
    }
    
    public func addItem (ofAddress address : String) {
        let entity = NSEntityDescription.entityForName("Feeds", inManagedObjectContext: Environment.managedContext)
        let feed = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: Environment.managedContext)
        
        feed.setValue(address, forKey: "address")
        
        
        Environment.feeds.append(feed)
        
        var error : NSError?
        
        if !Environment.managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
//    public func removeItem (ofIndex index : Int) {
//        
//        var feed = Environment.feeds.removeAtIndex(index)
//        
//        Environment.managedContext.deleteObject(feed)
//        
//        var error : NSError?
//        
//        if !Environment.managedContext.save(&error) {
//            println("Could not save \(error), \(error?.userInfo)")
//        }
//        
//    }
}
