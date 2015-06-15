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
    var testFile: String!
    var pubKeyFile: String!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testFile = NSBundle(forClass: self.dynamicType).pathForResource("signed-test-file", ofType: "txt")
        pubKeyFile = NSBundle(forClass: self.dynamicType).pathForResource("test-pubkey", ofType: "pem")
        
    }
    
    override func tearDown() {
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
        do {
            let pubkey = try String(contentsOfFile: self.pubKeyFile, encoding: NSASCIIStringEncoding)
            XCTAssertTrue(SUDSAVerifier.validatePath(self.testFile, withEncodedDSASignature: "MC0CFFMF3ha5kjvrJ9JTpTR8BenPN9QUAhUAzY06JRdtP17MJewxhK0twhvbKIE=", withPublicDSAKey: pubkey), "Expected valid signature")
        } catch {
            XCTAssert(false, "Error encountered opening file")
        }
    }
    
    func checkFile(aFile: String?, withPubKey pubKey:NSData?, signature sigString:String) ->Bool {
        if let v = SUDSAVerifier(publicKeyData: pubKey) {
            let sig = NSData(base64EncodedString: sigString, options: [])
            
            return v.verifyFileAtPath(aFile, signature: sig)
        } else {
            return false
        }
    }
}
