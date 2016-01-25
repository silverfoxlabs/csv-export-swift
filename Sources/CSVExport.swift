//
//  CSVExport.swift
//  CSVExportSwift
//
//  Created by dcilia on 1/17/16.
//  Copyright © 2016 David Cilia. All rights reserved.
//

import Foundation

public protocol CSVExporting {
    
    /**
     Getting a formatted CSV string
     
     - returns: An instance of String with comma separated values.
     Must end in a newline \n !!
     */
    func exportAsCommaSeparatedString() -> String
    
    /**
     The template to which to map values to:
     make sure to end with a newline "\n"
     
     - Note:
     "Make,Model,Max_Speed,Year\n"
     */
    static func templateString() -> String
}

public class CSVExporter<T: CSVExporting> {
    
    var filePath : String = ""
    var rawData : NSData?
    
    private var _dataArray : [T]
    private var _csvString : String
    
    public init(source input: [T], template: String) {
        _dataArray = input
        _csvString = template
    }
    
    /**
     Creates a file at the specified path
     
     - parameter path: the path that you would like to create
     */
    private func _createFile(path: String) -> Void {
        
        let fileManager = NSFileManager.defaultManager()
        if fileManager.createFileAtPath(path, contents: nil, attributes: nil) {
            self.filePath = path
        }
    }
    
    /**
     Encodes the data array into a CSV NSData object.
     
     - returns: an instance of NSData (may be empty)
     */
    private func _encode() -> NSData {
        
        //CSV is a delimited data format that has fields/columns separated by the comma character and records/rows terminated by newlines.
        
        /*
        Year,Make,Model,Description,Price
        1997,Ford,E350,"ac, abs, moon",3000.00
        1999,Chevy,"Venture ""Extended Edition""","",4900.00
        1999,Chevy,"Venture ""Extended Edition, Very Large""",,5000.00
        1996,Jeep,Grand Cherokee,"MUST SELL!
        air, moon roof, loaded",4799.00
        */
        
        _dataArray.forEach {
            
            self._csvString += $0.exportAsCommaSeparatedString()
        }
        
        //Use NSFileHandle to write the data to disk
        guard let data = _csvString.dataUsingEncoding(NSUTF8StringEncoding) else {
            
            return NSData()
        }
        

        return data
    }
    
    /**
     Writes data to file
     
     - parameter data: an instance of NSData you want to write
     - parameter path: the path where to write to
     */
    private func _writeDataToFile(data: NSData, path: String) -> Void {
        
        self.rawData = data
        
        if let handle = NSFileHandle(forWritingAtPath: self.filePath) {
            
            handle.truncateFileAtOffset(handle.seekToEndOfFile())
            handle.writeData(data)
        }
    }
    
    func export(finishHandler: () -> Void) -> Void {
        
        _createFile(self.filePath)
        _writeDataToFile(_encode(), path: filePath)
        finishHandler()
    }
}


