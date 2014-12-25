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
import STNewsFeed

class ViewController: UITableViewController, STNewsFeedParserDelegate {
    
    var secondaryQueue : dispatch_queue_t!
    
    var feeds : Dictionary<String, STNewsFeedParser> = [:]
    var entries : Array<STNewsFeedEntry> = []
    
    let favicon = UIImage(named: "Favicon")
    
    func refreshData () {
        entries.removeAll(keepCapacity: true)
        
        for feed in feeds.values {
            dispatch_async(secondaryQueue) {
                feed.parse()
            }
        }
        
        dispatch_async(secondaryQueue) {
            if self.refreshControl != nil {
                var formatter = NSDateFormatter()
                formatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
                var title = "Last update: " + formatter.stringFromDate(NSDate())
                var attributedTitle = NSAttributedString(string: title)
                self.refreshControl!.attributedTitle = attributedTitle;
                
                self.refreshControl!.endRefreshing()
            }
        }
    }
    
    // MARK: - NewsFeedDelegate
    func willBeginFeedParsing (parser : STNewsFeedParser) {}
    func didFinishFeedParsing (parser : STNewsFeedParser) {
        entries.extend(parser.entries)
        
        entries.sort { $0.date!.compare($1.date!) != NSComparisonResult.OrderedAscending }
        
        tableView.reloadData()
    }
    
    func newsFeed(feed: STNewsFeedParser, corruptFeed error: NSError) {
        if let errorDict = error.userInfo as? Dictionary<String, String> {
            error.code

            if let description = errorDict["description"] {
                println(description)
            }
        }
        
        feeds.removeValueForKey(feed.info.address)
    }
    func newsFeed(feed: STNewsFeedParser, XMLParserError error: NSError) {
        if let errorDict = error.userInfo as? Dictionary<String, String> {
            error.code
            
            if let description = errorDict["description"] {
                println(description)
            }
        }
        
        feeds.removeValueForKey(feed.info.address)
    }
    func newsFeed(feed: STNewsFeedParser, invalidAddress address: String, andError error: NSError) {
        if let errorDict = error.userInfo as? Dictionary<String, String> {
            error.code
            
            if let description = errorDict["description"] {
                println(description)
            }
        }
        
        feeds.removeValueForKey(feed.info.address)
    }
//    func newsFeed(feed: NewsFeedParser, unknownElement elementName: String, withAttributes attributeDict: NSDictionary, andError error: NSError) {
//        if let errorDict = error.userInfo as? Dictionary<String, String> {
//            error.code
//            
//            if let description = errorDict["description"] {
//                println(description)
//            }
//        }
//    }
    
    // MARK: ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        secondaryQueue = dispatch_queue_create("XMLRequest", DISPATCH_QUEUE_SERIAL)
        
        refreshControl?.addTarget(self, action: Selector("refreshData"), forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.estimatedRowHeight = 87
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentInset = UIEdgeInsetsZero
        
        CoreDataInterface().loadSession()
        var feeds = CoreDataInterface().listView
//
//        var feedAddresses = [
//            "http://daringfireball.net/feeds/main",
//            "http://feeds.gawker.com/lifehacker/full",
//            "http://www.swiss-miss.com/feed",
//            "http://nautil.us/rss/all",
//            "http://feeds.feedburner.com/zenhabits",
//            "http://feeds.feedburner.com/codinghorror",
//            "http://red-glasses.com/index.php/feed/",
//            "http://bldgblog.blogspot.com/feeds/posts/default?alt=rss",
//            "http://alistapart.com/site/rss"]
//       
//        for address in feedAddresses {
//            CoreDataInterface().addItem(ofAddress: address)
//        }
        
        for address in feeds {
            if let url = NSURL(string: address) {
                var feed = STNewsFeedParser(feedFromUrl: url)
                feed.delegate = self
                
                self.feeds[address] = feed
            }
        }
        
        refreshData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        feeds.removeAll(keepCapacity: false)
        entries.removeAll(keepCapacity: false)
    }
    
    // MARK: - UITableViewController
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCell", forIndexPath: indexPath) as CustomTableViewCell
        
        cell.title.text = entries[indexPath.row].title
        cell.feedName.text = entries[indexPath.row].info.title
        cell.address.text = entries[indexPath.row].info.address
        cell.favImage.image = favicon
        
        return cell
    }
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var readLaterRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Read later", handler:{action, indexpath in
            println("Read later");
            
            self.tableView.setEditing(false, animated: true)
        });
        // readLaterRowAction.backgroundColor = UIColor(patternImage: favicon!)
        
        return [readLaterRowAction];
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
