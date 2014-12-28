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

class ViewController: UITableViewController, STNewsFeedParserDelegate {
    
    var feeds : Dictionary<String, STNewsFeedParser> = [:]
    var entries : Array<STNewsFeedEntry> = []
    
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet var placeHolderText : UILabel!
    
    let favicon = UIImage(named: "Favicon")
    
    func refreshData () {
        
        for feed in self.feeds.values {
            feed.parse()
        }
        
        var formatter = NSDateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
        var title = "Last update: " + formatter.stringFromDate(NSDate())
        var attributedTitle = NSAttributedString(string: title)
        
        self.refreshControl?.attributedTitle = attributedTitle;
        
        self.refreshControl?.endRefreshing()
        
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
    }
    func newsFeed(feed: STNewsFeedParser, XMLParserError error: NSError) {
        if let errorDict = error.userInfo as? Dictionary<String, String> {
            error.code
            
            if let description = errorDict["description"] {
                println(description)
            }
        }
    }
    func newsFeed(feed: STNewsFeedParser, invalidAddress address: String, andError error: NSError) {
        if let errorDict = error.userInfo as? Dictionary<String, String> {
            error.code
            
            if let description = errorDict["description"] {
                println(description)
            }
        }
        
        feeds.removeValueForKey(feed.info.link)
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
        
        refreshControl?.addTarget(self, action: Selector("refreshData"), forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.estimatedRowHeight = 87
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentInset = UIEdgeInsetsZero
        
        CoreDataInterface().loadSession()
        
        var feeds = CoreDataInterface().listView
        
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
        
        let entry = entries[indexPath.row]
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.doesRelativeDateFormatting = true
        
//        let formatter = NSDateFormatter()
//        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        
        let date = entry.date
        
        if let simpleLink = entry.info.domain {
            cell.address.text = simpleLink + " — " + formatter.stringFromDate(date)
        } else {
            cell.address.text = entry.info.link + " — " + formatter.stringFromDate(date)
        }
        
        cell.title.text = entry.title
        cell.feedName.text = entry.info.title
        cell.favImage.image = favicon
        
        return cell
    }
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var readLaterRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Read later", handler:{action, indexpath in
            println("Read later");
            
            self.tableView.setEditing(false, animated: true)
        });
        
        var silenceRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Silence", handler:{action, indexpath in
            println("Silence");
            
            self.tableView.setEditing(false, animated: true)
            
            var target = self.entries[indexPath.row].info.title
            
            let alert = UIAlertView(title: "Silence for 24 hours", message: "\n\(target) is silenced for 24 hours.\nYou may turn it on again at the edit panel.\nHave a nice rest and keep reading.", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
            
            var i = 0
            var j = 0
            var indexPaths : Array<NSObject> = []
            
            for var i = 0, j = 0; i+j < self.entries.count; {
                
                if self.entries[i].info.title == target {
                    self.entries.removeAtIndex(i)
                    
                    indexPaths.append(NSIndexPath(forRow: i + j, inSection: indexpath.section))
                    
                    j++
                } else {
                    i++
                }
            }
            
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
            
            self.entries = self.entries.filter({
                $0.info.title != target
            })
            
            self.tableView.reloadData()
        });
        // readLaterRowAction.backgroundColor = UIColor.darkGrayColor()
        // silenceRowAction.backgroundColor = UIColor.purpleColor() // UIColor(patternImage: favicon!)
        
        return [readLaterRowAction, silenceRowAction];
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
