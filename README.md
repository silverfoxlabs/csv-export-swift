
[![Language Swift 2](https://img.shields.io/badge/Language-Swift%202-orange.svg)](https://developer.apple.com/swift) [![Language Swift 3](https://img.shields.io/badge/Language-Swift%203-orange.svg)](https://developer.apple.com/swift)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


# csv-export-swift
### Lightweight CSV export library written in Swift

Unit Tests are in the Xcode project.

Now supporting ```Swift 4``` in ``` master ```

1 universal framework you can import into your project.

#### Carthage:
``` "github dcilia/csv-export-swift" ```

#### Swift Package Manager:
``` $ swift build ``` will build a module
``` CSVExport.a ```

#### Subproject:

Drag and drop the ```.xcodeproj``` into your ```.xcworkspace```.

#### Supported Platforms:
``` macOS 10.10+ ```

``` iOS 8.0+ ```

``` tvOS 9.0+ ```

``` watchOS 2.0+ ```

Feel free to contribute any bug fixes, or features or submit requests.

##### Example Usage:

Have your class / struct conform to CSVExporting

``` 
struct Car : CSVExporting {
    
    var make : String
    var model : String
    var year : String
    
    static func templateString() -> String {
        
        return "Manufacturer, Model, Year\n"
    }
    
    
    func exportAsCommaSeparatedString() -> String {
        
        return "\(self.make), \(self.model), \(self.year)\n"
    }
}

```
Create an NSOperation and run the export

``` 
 let documents = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
         guard let path = documents.first else { return }
         let filePath = String(NSString(string:path).stringByAppendingPathComponent("Cars.csv"))
         
         guard let url = NSURL(string: filePath) else { return }
         
         let items = [
             
             Car(make: "BMW", model: "325", year: "1999"),
             Car(make: "Toyota", model: "Rav4", year: "2003"),
             Car(make: "Hyundai", model: "Elantra", year: "2011"),
             Car(make: "Tesla", model: "Model 3", year: "2017")
         ]
         
         let operation = CSVOperation(filePath: url, source: items)

         operation.completionBlock = {
                     
            if operation.finishedState == .Success {
                         
              //File has been saved to disk ...

             }
          }
         
         NSOperationQueue().addOperation(operation)
         
```
