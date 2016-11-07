//
//  DataSource.swift
//  Lines
//
//  Created by Tiago Mergulhão on 27/01/15.
//  Copyright (c) 2015 Tiago Mergulhão. All rights reserved.
//

import UIKit

import STNewsFeedParser

class DataSource : NSObject, UITableViewDataSource, STNewsFeedParserDelegate {
	
	var tableView : UITableView!
	var cellReuseId : String!
	
	let favicon = UIImage(named: "Favicon")
	
	init (tableView : UITableView, withCellId cellId : String) {
		super.init()
		
		self.cellReuseId = cellId
		
		self.tableView = tableView
		self.tableView.dataSource = self
		
	}
	
	func refreshData () {
		for feed in feeds {
			feed.parse()
		}
	}
	
	//	MARK: - UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
		//  Locks tableView:cellForRowAtIndexPath while extending and sorting newEntries avoiding entries[indexPath.row] to be out of range.
		//  UIView uses dispatch blocks so you have to take into account thread unsafety on your data model.
		//  http://stackoverflow.com/questions/2275626/how-to-stop-uitableview-from-loading-until-data-has-been-fetched
		
		if newEntries.isEmpty == false {
			
			entries.extend(newEntries)
			newEntries.removeAll(keepCapacity: false)
			
			entries.sort { $0.date.compare($1.date) != NSComparisonResult.OrderedAscending }
		}
		
		return entries.count
		
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell  {
		
		let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseId, forIndexPath: indexPath) as! CustomTableViewCell
		
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
	
	// MARK: - UITableViewDataSource, optional
	/*
	func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 3 }
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return "New"
		case 1: return "Today"
		case 2: return "Older"
		}
	}
	*/
	
	//	MARK: - NewsFeedParserDelegate
	
	var feeds : Array<STNewsFeedParser> = []
	
	var newEntries : Array<STNewsFeedEntry> = []
	var entries : Array<STNewsFeedEntry> = []
	
	func newsFeed(didFinishFeedParsing feed: STNewsFeedParser, withInfo info: STNewsFeedEntry, withEntries entries: Array<STNewsFeedEntry>) {
		if entries.isEmpty == false {
			
			newEntries.extend(entries)
			
			tableView.reloadData()
			
		}
	}
	
	func newsFeed(XMLParserErrorOn feed: STNewsFeedParser, withError error: NSError) {
		/*
		println("Domain :  \(error.domain)\n" +
				"Code: \(error.code)\n" +
				"DataObject: \(error.userInfo)")
		*/
	}
	
	func newsFeed(corruptFeed feed: STNewsFeedParser, withError error: NSError) {
		/*println("Domain :  \(error.domain)\n" +
				"Code: \(error.code)\n" +
				"DataObject: \(error.userInfo)")*/
	}
}
