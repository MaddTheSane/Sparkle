//
//  AppDelegate.swift
//  Swift Test App
//
//  Created by C.W. Betts on 7/29/14.
//  Copyright (c) 2014 Sparkle Project. All rights reserved.
//

import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SUUpdaterDelegate {
    
    @IBOutlet weak var updater: SUUpdater!
	@IBOutlet weak var window: NSWindow!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        updater.delegate = self
    }

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

    func updater(updater: SUUpdater!, didAbortWithError error: NSError!) {
        if updater === self.updater {
            print(error)
        } else {
            print("Unknown updater")
        }
    }
}

