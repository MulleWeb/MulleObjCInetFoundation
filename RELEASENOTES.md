## 0.20.0


* Document NSURL file URL support methods (-fileSystemRepresentation, -getFileSystemRepresentation:maxLength:, +fileURLWithPath:, +fileURLWithPath:isDirectory:, +fileURLWithPathComponents:)
* Document the NSData(NSURL) category for reading and writing data via URLs
* Document the NSURLFileScheme global and correct the dependency name to MulleFoundation


feature: add file URL support and NSData URL category

* NSURL gains file: scheme support with `+fileURLWithPath:`, `+fileURLWithPath:isDirectory:`, `+fileURLWithPathComponents:`, `-fileSystemRepresentation` and `-getFileSystemRepresentation:maxLength:`, plus the `NSURLFileScheme` global
* new `NSData(NSURL)` category adds `+dataWithContentsOfURL:`, `+dataWithContentsOfURL:options:error:`, `-initWithContentsOfURL:` and `-writeToURL:atomically:`
* `NSHost` gains `+currentHost`


### 0.19.2

Various small improvements

### 0.19.1


feature: NSHost conforms to MulleObjCFuture protocol

* NSHost now declares conformance to the MulleObjCFuture protocol
