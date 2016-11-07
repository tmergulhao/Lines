//
//  ViewController.swift
//  Lines
//
//  Created by Tiago Mergulhão on 16/12/14.
//  Copyright (c) 2014 Tiago Mergulhão. All rights reserved.
//

//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import UIKit

import STNewsFeedParser

//	TODO: Implement feed list view

//	TODO: Look for UITableView tweaks
//	https://github.com/Dimillian/SwiftHN
//	http://www.codingexplorer.com/sharing-swift-app-uiactivityviewcontroller/
//	https://github.com/suryakants/TableViewOperationInSwift
//	https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/TableViewCells/TableViewCells.html

//	TODO: Auto-Layout tweaks
//	https://github.com/smileyborg/TableViewCellWithAutoLayoutiOS8

//	TODO: Add placeholder image and message for no feeds
//	Try to use IBOutlets placeholderImage and placeholderText
//	http://www.thinkandbuild.it/learn-to-love-auto-layout-programmatically/
//	https://medium.com/swift-programming/dynamic-layouts-in-swift-b56cf8049b08

//	TODO: Multi line transitions
//	http://www.appcoda.com/custom-segue-animations/


// MARK: - ViewController

class ViewController: UITableViewController {
	
	var dataSource : DataSource!
    
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet var placeholderText : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.tintColor = UIColor.orangeColor()
		
		self.dataSource = DataSource(tableView: self.tableView, withCellId: "EntryCell")
		
		tableView.estimatedRowHeight = 87
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentInset = UIEdgeInsetsZero
        
		var addresses = [
			"http://daringfireball.net/feeds/main",
			"http://www.swiss-miss.com/feed",
			"http://nautil.us/rss/all",
			"http://feeds.feedburner.com/zenhabits",
			"http://feeds.feedburner.com/codinghorror",
			"http://red-glasses.com/index.php/feed/",
			"http://bldgblog.blogspot.com/feeds/posts/default?alt=rss",
			"http://alistapart.com/site/rss"
		]
		
        for address in addresses {
            if let url = NSURL(string: address) {
                let feed = STNewsFeedParser(feedFromUrl: url, concurrencyType: STNewsFeedParserConcurrencyType.PrivateQueue)
				
                feed.delegate = dataSource
                
                dataSource.feeds.append(feed)
            }
        }
        
        dataSource.refreshData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
		
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewController
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		// UIApplication.sharedApplication().openURL(<#url: NSURL#>)
		
		println(indexPath)
	}
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var readLaterRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Read later", handler:{action, indexpath in
            
            self.tableView.setEditing(false, animated: true)
        });
        
        var silenceRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Mute", handler:{
			action, indexpath in
            
            self.tableView.setEditing(false, animated: true)
            
            var target = self.dataSource.entries[indexPath.row].info.title
            
            let alert = UIAlertView(title: "\(target) is muted", message: "You may unmute it on at the subscriptions panel.\nHave a nice rest and keep reading.", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
            
            var i = 0
            var j = 0
            var indexPaths : Array<NSObject> = []
            
            for var i = 0, j = 0; i+j < self.dataSource.entries.count; {
                
                if self.dataSource.entries[i].info.title == target {
                    self.dataSource.entries.removeAtIndex(i)
                    
                    indexPaths.append(NSIndexPath(forRow: i + j, inSection: indexpath.section))
                    
                    j++
                } else {
                    i++
                }
            }
            
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
            
            self.dataSource.entries = self.dataSource.entries.filter({
                $0.info.title != target
            })
			
            self.tableView.reloadData()
        });
        // readLaterRowAction.backgroundColor = UIColor.darkGrayColor()
        // silenceRowAction.backgroundColor = UIColor.purpleColor() // UIColor(patternImage: favicon!)
        
        return [readLaterRowAction, silenceRowAction];
    }
	
//	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {}
	
//	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {	return true }
    
}
