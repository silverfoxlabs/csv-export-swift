//
//  CSVExportSwiftTests.swift
//  CSVExportSwiftTests
//
//  Created by dcilia on 1/17/16.
//  Copyright © 2016 David Cilia. All rights reserved.
//

import XCTest
@testable import CSVExportSwift

struct CSVMock : CSVExporting {

    var city : String
    var state : String
    var zip : Int
    var country : String
    var notes: String
    
    static func templateString() -> String {
    
        return "City, State, Zip, Country\n"
    }
    
    func exportAsCommaSeparatedString() -> String {
        
        return "\(self.city),\(self.state),\(self.zip), \(self.country),\u{0022}\(self.notes)\u{0022}\n"
    }
    
    static func getNewMock() -> CSVMock {
        
        return CSVMock(city: "Manhatan", state: "New York", zip: 10001, country: "USA", notes: "The best city in the world!")
    }
    
    static func getNewMockArray(count : Int) -> [CSVMock] {
        
        var mocks = [CSVMock]()
        
        for var i = 0; i < count; i++ {
            
            mocks.append(self.getNewMock())
        }
        
        return mocks
    }
    
    static func reset() -> Void {
        
        let documents = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        guard let path = documents.first else { XCTAssert(false); return }
        let filePath = String(NSString(string:path).stringByAppendingPathComponent("test.csv"))
        
        guard let url = NSURL(string: filePath) else { XCTAssert(false); return }
        
        do {
            
           try NSFileManager.defaultManager().removeItemAtURL(url)
        }
        catch {
            
            print("error removing file at path, file does not exist at path or file already removed.")
        }
    }
}

class CSVExportTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
        CSVMock.reset()
    }
    
    func testThatCanCreateAValidInstance() -> Void {
        
        let mock = CSVMock.getNewMock()
        let export = CSVExporter(source: [mock], template: CSVMock.templateString())
        XCTAssertNotNil(export)
    }
    
    func testThatCanSetAndGetFilePath() -> Void {
        
        let mock = CSVMock.getNewMock()
        let export = CSVExporter(source: [mock], template: CSVMock.templateString())
        XCTAssertTrue(export.filePath.isEmpty)
        let documents = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        guard let path = documents.first else { XCTAssert(false); return }
        export.filePath = path
        XCTAssertEqual(export.filePath, path)
        
    }
    
    func testThatCanExportToFileSuccessfully() -> Void {
        
        let mock = CSVMock.getNewMock()
        let export = CSVExporter(source: [mock], template: CSVMock.templateString())
        XCTAssertTrue(export.filePath.isEmpty)
        let documents = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        guard let path = documents.first else { XCTAssert(false); return }
        let filePath = String(NSString(string:path).stringByAppendingPathComponent("test.csv"))
        export.filePath = filePath
        Swift.print(filePath)
        
        let expectation = self.expectationWithDescription("self")
        
        export.export { () -> Void in
            
            XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(filePath))
            XCTAssertNotNil(NSData(contentsOfFile: filePath))
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    
    
    func testPerfomanceExample() -> Void {
        
        self.measureBlock {
        
            let mock = CSVMock.getNewMockArray(100)
            let export = CSVExporter(source: mock, template: CSVMock.templateString())
            XCTAssertTrue(export.filePath.isEmpty)
            let documents = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            guard let path = documents.first else { XCTAssert(false); return }
            let filePath = String(NSString(string:path).stringByAppendingPathComponent("test.csv"))
            export.filePath = filePath
            Swift.print(filePath)
            
            let expectation = self.expectationWithDescription("self")
            
            export.export { () -> Void in
                
                XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(filePath))
                XCTAssertNotNil(NSData(contentsOfFile: filePath))
                expectation.fulfill()
            }
            
            self.waitForExpectationsWithTimeout(60, handler: nil)
        }
    }
    
    func testPerformanceExampleLargeAmount() -> Void {
        
        self.measureBlock {
            
            let mock = CSVMock.getNewMockArray(1000)
            let export = CSVExporter(source: mock, template: CSVMock.templateString())
            XCTAssertTrue(export.filePath.isEmpty)
            let documents = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            guard let path = documents.first else { XCTAssert(false); return }
            let filePath = String(NSString(string:path).stringByAppendingPathComponent("test.csv"))
            export.filePath = filePath
            Swift.print(filePath)
            
            let expectation = self.expectationWithDescription("com.csveport.export")
            
            export.export { () -> Void in
                
                XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(filePath))
                XCTAssertNotNil(NSData(contentsOfFile: filePath))
                expectation.fulfill()
            }
            
            self.waitForExpectationsWithTimeout(60, handler: nil)
        }
    }
}

class CSVOperationTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
        CSVMock.reset()
    }
    
    func testThatCanWriteCSVFile() -> Void {
        
        let mock = CSVMock.getNewMockArray(10)
        let export = CSVExporter(source: mock, template: CSVMock.templateString())
        XCTAssertTrue(export.filePath.isEmpty)
        let documents = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        guard let path = documents.first else { XCTAssert(false); return }
        let filePath = String(NSString(string:path).stringByAppendingPathComponent("test.csv"))
        
        guard let url = NSURL(string: filePath) else { XCTAssert(false); return }
        
        let operation = CSVOperation(filePath: url, source: mock)
        XCTAssertNotNil(operation)
        XCTAssertTrue(operation.ready)
        
        let expectation = self.expectationWithDescription("com.csvexport.operation.expectation")
        
        operation.completionBlock = {
        
            XCTAssertTrue(operation.finished)
            XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(filePath))
            XCTAssertNotNil(NSData(contentsOfFile: filePath))
            XCTAssertEqual(operation.finishedState, CSVFinishedState.Success)
            expectation.fulfill()
        }
        
        NSOperationQueue.mainQueue().addOperation(operation)
        self.waitForExpectationsWithTimeout(60, handler: nil)
        
    }
}


