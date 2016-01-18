//
//  CSVExportOperation.swift
//  CSVExportSwift
//
//  Created by dcilia on 1/17/16.
//  Copyright © 2016 David Cilia. All rights reserved.
//

import Foundation

/**
Encapsulates exporting to a CSV file and writing to disk in an NSOperation
 
 - Note: The NSOperation is not concurrent, and meant to be used with
 NSOperationQueue.
 
*/
public class CSVOperation< T : CSVExporting> : NSOperation {
    
    private var _source : [T]
    private var _filePath : NSURL
    
    private var _executing : Bool = false {
        didSet {
            self.didChangeValueForKey("executing")
        }
    }
    private var _finished : Bool = false {
        didSet {
            self.didChangeValueForKey("finished")
        }
    }
    private var _cancelled : Bool = false {
        didSet {
            self.didChangeValueForKey("cancelled")
        }
    }
    private var _ready : Bool = false {
        didSet {
            self.didChangeValueForKey("ready")
        }
    }
    
    override public var ready : Bool { return _ready }
    override public var finished : Bool { return _finished }
    override public var cancelled : Bool { return _cancelled }
    override public var executing : Bool { return _executing }
    
    /**
    The finished state of the CSVExport
     
     - Note: Possible values are: (CSVFinishedState)
     Success, FilePathError, DataEmptyError, Cancelled, Unknown
     
    */
    var finishedState : CSVFinishedState = .Unknown
    
    /**
     Initializing a new CSVOperation
     
     - parameter filePath: the path to the file, must include the filename and
     extension (.csv)
     - parameter source:   an instance that conforms to CSVExporting
     
     - returns: a ready to execute CSVOperation.
     
     - Note: To begin and execute the operation, you must add it to an
     NSOperationQueue.
     
     */
    init(filePath : NSURL, source: [T]) {
        
        _filePath = filePath
        _source = source
        _ready = true
        
        super.init()
        
        
    }
    
    override public func main() {
        
        if cancelled == true { return }
        
        _executing = true
        
        //Run the export
        let exporter = CSVExporter(source: _source, template: T.templateString())
        exporter.filePath = _filePath.path!
        exporter.export {
            
            if exporter.filePath.isEmpty {
                
                self.finishedState = .FilePathError
            }
            
            if let _ = exporter.rawData {
            
                self.finishedState = .Success
            }
            else {
                
                self.finishedState = .DataEmptyError
            }
            
            self._finished = true
        }
    }
    
    override public func cancel() {
        
        super.cancel()
        
        _cancelled = true
        _executing = false
        finishedState = .Cancelled
        
    }
}

/**
 The finished state of the CSV export.
 
 - Success:        The export was successful with no issues.
 - FilePathError:  The export was unsuccessful due to a file path error.
 - DataEmptyError: The export was unsuccessful due to empty data.
 - Cancelled:      The operation was cancelled.
 - Unknown:        An unknown error occured.
 */
enum CSVFinishedState : Int {

    case Success, FilePathError, DataEmptyError, Cancelled, Unknown
}


