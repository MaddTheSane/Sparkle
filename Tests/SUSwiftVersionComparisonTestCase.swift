//
//  SUSwiftVersionComparisonTestCase.swift
//  Sparkle
//
//  Created by C.W. Betts on 7/30/14.
//  Copyright (c) 2014 Sparkle Project. All rights reserved.
//

import Cocoa
import XCTest
import Sparkle


class SUSwiftVersionComparisonTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func SUAssertOrder(a:String, _ b:String, _ c:NSComparisonResult) {
        XCTAssertTrue(SUStandardVersionComparator.defaultComparator().compareVersion(a, toVersion: b) == c, "b should be newer than a!")
    }
    
    func SUAssertAscending(a: String, _ b: String) {
        SUAssertOrder(a, b, .OrderedAscending)
    }
    
    func SUAssertDescending(a: String, _ b: String) {
        SUAssertOrder(a, b, .OrderedDescending)
    }
    
    func SUAssertEqual(a: String, _ b: String) {
        SUAssertOrder(a, b, .OrderedSame)
    }
    
    func testNumbers() {
        //XCTAssertTrue(SUStandardVersionComparator.defaultComparator().compareVersion("1.0", toVersion: "1.1") == .OrderedAscending, "b should be newer than a!")
        SUAssertAscending("1.0", "1.1");
        SUAssertEqual("1.0", "1.0");
        SUAssertDescending("2.0", "1.1");
        SUAssertDescending("0.1", "0.0.1");
        //SUAssertDescending(".1", "0.0.1"); Known bug, but I'm not sure I care.
        SUAssertAscending("0.1", "0.1.2");
    }
    
    func testPrereleases() {
        SUAssertAscending("1.0a1", "1.0b1");
        SUAssertAscending("1.0b1", "1.0");
        SUAssertAscending("0.9", "1.0a1");
        SUAssertAscending("1.0b", "1.0b2");
        SUAssertAscending("1.0b10", "1.0b11");
        SUAssertAscending("1.0b9", "1.0b10");
        SUAssertAscending("1.0rc", "1.0");
        SUAssertAscending("1.0b", "1.0");
        SUAssertAscending("1.0pre1", "1.0");
    }
    
    func testVersionsWithBuildNumbers() {
        SUAssertAscending("1.0 (1234)", "1.0 (1235)");
        SUAssertAscending("1.0b1 (1234)", "1.0 (1234)");
        SUAssertAscending("1.0b5 (1234)", "1.0b5 (1235)");
        SUAssertAscending("1.0b5 (1234)", "1.0.1b5 (1234)");
        SUAssertAscending("1.0.1b5 (1234)", "1.0.1b6 (1234)");
        SUAssertAscending("2.0.0.2429", "2.0.0.2430");
        SUAssertAscending("1.1.1.1818", "2.0.0.2430");
        
        SUAssertAscending("3.3 (5847)", "3.3.1b1 (5902)");
    }
    
    func testWordsWithSpaceInFront() {
        //SUAssertAscending("1.0 beta", "1.0");
        //SUAssertAscending("1.0  - beta", "1.0");
        //SUAssertAscending("1.0 alpha", "1.0 beta");
        //SUAssertEqual("1.0  - beta", "1.0beta");
        //SUAssertEqual("1.0  - beta", "1.0 beta");
    }
    
    func testVersionsWithReverseDateBasedNumbers() {
        SUAssertAscending("201210251627", "201211051041");
    }
    
}
