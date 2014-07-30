//
//  SUSwiftUpdaterTest.swift
//  Sparkle
//
//  Created by C.W. Betts on 7/29/14.
//  Copyright (c) 2014 Sparkle Project. All rights reserved.
//

import Cocoa
import Sparkle
import XCTest

class SUSwiftUpdaterTest: XCTestCase, SUUpdaterDelegate {
    var queue: NSOperationQueue!;
    var updater: SUUpdater!;
    
    override func setUp() {
        super.setUp()
        self.queue = NSOperationQueue();
        self.updater = SUUpdater();
        self.updater.delegate = self;
    }
    override func tearDown() {
        self.updater = nil;
        self.queue = nil;
        super.tearDown()
    }
    
    func feedURLStringForUpdater(unused: SUUpdater) -> String {
        return ""
    }

    /*
    func testFeedURL() {
        self.updater.feedURL // this WON'T throw
        
        self.queue.addOperationWithBlock({
            XCTAssertTrue(!NSThread.isMainThread());
            try {
                self.updater.feedURL()
                XCTFail("feedURL did not throw an exception when called on a secondary thread");
            }
            catch (exception: NSException) {
                NSLog("%@", exception);
            }
            });
        self.queue.waitUntilAllOperationsAreFinished()
    }
    */
}
