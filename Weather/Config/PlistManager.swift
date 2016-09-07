//
//  PlistManager.swift
//  Weather
//
//  Created by Paulo Pão on 04/09/16.
//  Copyright © 2016 Paulo Pão. All rights reserved.
//

import Foundation

class PlistManager {
  let fileManager = NSFileManager.defaultManager()
  
  func getPath(type: PlistType) -> String! {
    let sourcePath = NSBundle.mainBundle().pathForResource(type.rawValue, ofType: "plist")
    let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    let destinationPath = dir.stringByAppendingPathComponent("\(type.rawValue).plist")
    
    if !fileManager.fileExistsAtPath(destinationPath) {
      do {
        try fileManager.copyItemAtPath(sourcePath!, toPath: destinationPath)
      } catch _ {
        print("Error occured when copying \(type.rawValue) plist")
        return nil
      }
    }
    
    return destinationPath
  }
  
  
  func fetchDatePlist() -> NSMutableDictionary? {
    let path = getPath(.LastRequest)
    
    if fileManager.fileExistsAtPath(path) {
      return NSMutableDictionary(contentsOfFile: path)
    }
    
    print("Could not retrieve plist")
    return nil
  }
  
  func cacheDate() {
    let path = getPath(.LastRequest)
    guard let dictionary = fetchDatePlist() else { return }
    
    dictionary.setValue(NSDate(), forKey: "date")
    
    if !dictionary.writeToFile(path, atomically: false) {
      print("Could not write date")
    }
  }
  
  func fetchForecastPlist() -> [[String: AnyObject]]? {
    let path = getPath(.Forecast)
    
    if fileManager.fileExistsAtPath(path) {
      guard let array = NSArray(contentsOfFile: path) as? [[String: AnyObject]] else {
        return nil
      }
      
      return array
    }
    
    print("Could not retrieve plist")
    return nil
  }
  
  func cacheForecast(data: [[String: AnyObject]]) {
    let path = getPath(.Forecast)
    let array: NSArray = data
    
    if !array.writeToFile(path, atomically: false) {
      print("Could not write forecast")
    }
  }
}