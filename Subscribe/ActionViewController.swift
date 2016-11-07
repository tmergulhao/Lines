//
//  ActionViewController.swift
//  Subscribe
//
//  Created by Tiago Mergulhão on 25/12/14.
//  Copyright (c) 2014 Tiago Mergulhão. All rights reserved.
//

import UIKit
import MobileCoreServices

//	TODO: Implement subscribe action using STNewsFeedDiscovery class
//	https://medium.com/ios-os-x-development/learnings-from-building-a-today-view-extension-in-ios-8-710d5f481594
//	http://swiftiostutorials.com/tutorial-creating-ios-app-extension-ios-8-perform-custom-actions-safari-content/
//	http://www.techotopia.com/index.php/Creating_an_iOS_8_Action_Extension
//	http://www.glimsoft.com/06/28/ios-8-today-extension-tutorial/
//	http://sundeepgupta.ca/posts/ios-8-share-extension-safari-url-example
//	http://stackoverflow.com/questions/24056024/sharing-extension-in-ios8-beta
//	http://developer.xamarin.com/samples/ios/iOS8/

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            println(item)
        }
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        var imageFound = false
        for item: AnyObject in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as! String) {
                    // This is an image. We'll load it, then place it in our image view.
                    weak var weakImageView = self.imageView
                    itemProvider.loadItemForTypeIdentifier(kUTTypeImage as! String, options: nil, completionHandler: { (image, error) in
                        if image != nil {
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                if let imageView = weakImageView {
                                    imageView.image = image as? UIImage
                                }
                            }
                        }
                    })
                    
                    imageFound = true
                    break
                }
            }
            
            if (imageFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }

}
