//
//  SUSwiftDSAVerifierTest.swift
//  Sparkle
//
//  Created by C.W. Betts on 7/29/14.
//  Copyright (c) 2014 Sparkle Project. All rights reserved.
//

import Cocoa
import XCTest

class SUSwiftDSAVerifierTest: XCTestCase {
    var testDir: String!
    var testFile: String!
    var pubKeyFile: String!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.testDir = __FILE__.stringByDeletingLastPathComponent
        self.testFile = self.testDir.stringByAppendingPathComponent("signed_test_file")
        self.pubKeyFile = self.testDir.stringByAppendingPathComponent("test_pubkey")
    }
    
    override func tearDown() {
        self.testDir = nil
        self.testFile = nil
        self.pubKeyFile = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testVerifyFileAtPath() {
        let pubKey = NSData(contentsOfFile: self.pubKeyFile)
        XCTAssertNotNil(pubKey, "Public key must be readable");
        
        let validSig = "MCwCFCIHCIYYkfZavNzTitTW5tlRp/k5AhQ40poFytqcVhIYdCxQznaXeJPJDQ==";
        
        XCTAssertTrue(checkFile(testFile, withPubKey: pubKey, signature: validSig),
            "Expected valid signature")
        
        XCTAssertFalse(checkFile(testFile, withPubKey: "lol".dataUsingEncoding(NSUTF8StringEncoding), signature: validSig),
            "Invalid pubkey")
        
        XCTAssertFalse(checkFile(pubKeyFile, withPubKey: pubKey, signature: validSig), "Wrong file checked")
        
        XCTAssertFalse(checkFile(testFile, withPubKey: pubKey, signature: "MCwCFCIHCiYYkfZavNzTitTW5tlRp/k5AhQ40poFytqcVhIYdCxQznaXeJPJDQ=="),
            "Expected invalid signature")
        
        XCTAssertTrue(checkFile(testFile, withPubKey: pubKey, signature: "MC0CFAsKO7cq2q7L5/FWe6ybVIQkwAwSAhUA2Q8GKsE309eugi/v3Kh1W3w3N8c="),
            "Expected valid signature")
        
        XCTAssertFalse(checkFile(testFile, withPubKey: pubKey, signature: "MC0CFAsKO7cq2q7L5/FWe6ybVIQkwAwSAhUA2Q8GKsE309eugi/v3Kh1W3w3N8"),
            "Expected invalid signature")
    }
    
    func testValidatePath() {
        let pubkey = NSString(contentsOfFile: self.pubKeyFile, encoding: NSASCIIStringEncoding, error: nil)
        
        XCTAssertTrue(SUDSAVerifier.validatePath(self.testFile, withEncodedDSASignature: "MC0CFFMF3ha5kjvrJ9JTpTR8BenPN9QUAhUAzY06JRdtP17MJewxhK0twhvbKIE=", withPublicDSAKey: pubkey), "Expected valid signature")
    }
    
    func checkFile(aFile: String?, withPubKey pubKey:NSData?, signature sigString:String) ->Bool {
        var v:SUDSAVerifier? = SUDSAVerifier(publicKeyData:pubKey)
        if (!v) {
            return false
        }
        
        let sig = NSData(base64EncodedString: sigString, options: NSDataBase64DecodingOptions(0))
        
        return v!.verifyFileAtPath(aFile, signature: sig)
    }
}
