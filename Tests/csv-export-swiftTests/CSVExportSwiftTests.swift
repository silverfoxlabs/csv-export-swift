//
//  CSVExportSwiftTests.swift
//  CSVExportSwiftTests
//
//  Created by dcilia on 1/17/16.
//  Copyright © 2016 David Cilia. All rights reserved.
//

import XCTest
@testable import CSVExporter

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
    
    static func getNewMockArray(_ count : Int) -> [CSVMock] {
        
        var mocks = [CSVMock]()
        
        for _ in 0 ..< count {
            
            mocks.append(self.getNewMock())
        }
        
        return mocks
    }
    
    static func reset() -> Void {
        
        let documents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        guard let path = documents.first else { XCTAssert(false); return }
        let filePath = String(NSString(string:path).appendingPathComponent("test.csv"))
        
        guard let url = URL(string: filePath) else { XCTAssert(false); return }
        
        do {
            
            try FileManager.default.removeItem(at: url)
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
        let documents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        guard let path = documents.first else { XCTAssert(false); return }
        export.filePath = path
        XCTAssertEqual(export.filePath, path)
        
    }
    
    func testThatCanExportToFileSuccessfully() -> Void {
        
        let mock = CSVMock.getNewMock()
        let export = CSVExporter(source: [mock], template: CSVMock.templateString())
        XCTAssertTrue(export.filePath.isEmpty)
        let documents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        guard let path = documents.first else { XCTAssert(false); return }
        let filePath = String(NSString(string:path).appendingPathComponent("test.csv"))
        export.filePath = filePath
        Swift.print(filePath)
        
        let expectation = self.expectation(description: "self")
        
        export.export { () -> Void in
            
            XCTAssertTrue(FileManager.default.fileExists(atPath: filePath))
            XCTAssertNotNil(try? Data(contentsOf: URL(fileURLWithPath: filePath)))
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 60, handler: nil)
    }
    
    
    
    func testPerfomanceExample() -> Void {
        
        self.measure {
        
            let mock = CSVMock.getNewMockArray(100)
            let export = CSVExporter(source: mock, template: CSVMock.templateString())
            XCTAssertTrue(export.filePath.isEmpty)
            let documents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            guard let path = documents.first else { XCTAssert(false); return }
            let filePath = String(NSString(string:path).appendingPathComponent("test.csv"))
            export.filePath = filePath
            Swift.print(filePath)
            
            let expectation = self.expectation(description: "self")
            
            export.export { () -> Void in
                
                XCTAssertTrue(FileManager.default.fileExists(atPath: filePath))
                XCTAssertNotNil(try? Data(contentsOf: URL(fileURLWithPath: filePath)))
                expectation.fulfill()
            }
            
            self.waitForExpectations(timeout: 60, handler: nil)
        }
    }
    
    func testPerformanceExampleLargeAmount() -> Void {
        
        self.measure {
            
            let mock = CSVMock.getNewMockArray(1000)
            let export = CSVExporter(source: mock, template: CSVMock.templateString())
            XCTAssertTrue(export.filePath.isEmpty)
            let documents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            guard let path = documents.first else { XCTAssert(false); return }
            let filePath = String(NSString(string:path).appendingPathComponent("test.csv"))
            export.filePath = filePath
            Swift.print(filePath)
            
            let expectation = self.expectation(description: "com.csveport.export")
            
            export.export { () -> Void in
                
                XCTAssertTrue(FileManager.default.fileExists(atPath: filePath))
                XCTAssertNotNil(try? Data(contentsOf: URL(fileURLWithPath: filePath)))
                expectation.fulfill()
            }
            
            self.waitForExpectations(timeout: 60, handler: nil)
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
        let documents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        guard let path = documents.first else { XCTAssert(false); return }
        let filePath = String(NSString(string:path).appendingPathComponent("test.csv"))
        
        guard let url = URL(string: filePath) else { XCTAssert(false); return }
        
        let operation = CSVOperation(filePath: url, source: mock)
        XCTAssertNotNil(operation)
        XCTAssertTrue(operation.isReady)
        
        let expectation = self.expectation(description: "com.csvexport.operation.expectation")
        
        operation.completionBlock = {
        
            XCTAssertTrue(operation.isFinished)
            XCTAssertTrue(FileManager.default.fileExists(atPath: filePath))
            XCTAssertNotNil(try? Data(contentsOf: URL(fileURLWithPath: filePath)))
            XCTAssertEqual(operation.finishedState, CSVFinishedState.success)
            expectation.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        self.waitForExpectations(timeout: 60, handler: nil)
        
    }
}


