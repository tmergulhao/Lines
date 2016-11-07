//
//  AppDelegate.swift
//  Lines
//
//  Created by Tiago Mergulhão on 20/12/14.
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
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // In the storyboard, uncheck the "Is initial View Controller" attribute from the first view controller.
        // In the app's setting, go to your target and the Info tab. There clear the value of Main storyboard file base name. On the General tab, clear the value for Main Interface. This will remove the warning.
        // https://stackoverflow.com/questions/10428629/programatically-set-the-initial-view-controller-using-storyboards/14926009#14926009
        
        /*
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var someStoryboardView : SomeViewClass = storyboard.instantiateViewControllerWithIdentifier("someView")
        var mainStoryboardView : MainViewClass = storyboard.instantiateInitialViewController()
        
        
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
        bundle: nil];
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        self.window?.rootViewController = ViewController()
        
        self.window?.makeKeyAndVisible()
        */
		
		return true
    }
}

