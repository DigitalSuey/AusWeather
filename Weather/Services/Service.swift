//
//  Service.swift
//  Weather
//
//  Created by Paulo Pão on 01/09/16.
//  Copyright © 2016 Paulo Pão. All rights reserved.
//

import Foundation
import UIKit

class Service: NSObject {
  class func URLforPath(city: String) -> NSURL! {
    guard let apiPath = NSBundle.mainBundle().objectForInfoDictionaryKey("ApiPath") as? String else {
      return nil
    }
    
    let url = NSURL(string: apiPath)
    let query = queryString(city)
    
    return NSURL(string: query, relativeToURL: url)!
  }
  
  class func queryString(city: String) -> String! {
    
    guard let apiKey = NSBundle.mainBundle().objectForInfoDictionaryKey("ApiKey") as? String else {
      return nil
    }
    
    let queryObject = [
      "q": "\(city),australia",
      "format": "json",
      "num_of_days": "1",
      "key": apiKey
    ]
    
    var queryString = "?"
    
    for (key, value) in queryObject {
      queryString.appendContentsOf("\(key)=\(value)&")
    }
    
    queryString = queryString.substringToIndex(queryString.endIndex.predecessor())
    
    return queryString
  }
  
  class func fetchData(query: String, completion: (([String: AnyObject]) -> Void)) {
    showNetworkActivityIndicator()
    
    let url = URLforPath(query)
    let request = NSURLRequest(URL: url)
    let urlSession = NSURLSession.sharedSession()
    let dataTask = urlSession.dataTaskWithRequest(request) { (data: NSData?, response, error) in
      hideNetworkActivityIndicator()
      
      guard error == nil else {
        return print(error)
      }
      
      guard data != nil else {
        return print("No data returned!")
      }
      
      let responseObject: [String: AnyObject]!
      
      do {
        responseObject = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String: AnyObject]
      } catch _ {
        responseObject = nil
      }
      
      completion(responseObject)
    }
    
    dataTask.resume()
  }
  
  class func fetchImage(url: NSURL, completion: ((image: UIImage) -> Void)) {
    let request = NSURLRequest(URL: url)
    let urlSession = NSURLSession.sharedSession()
    let dataTask = urlSession.dataTaskWithRequest(request) { (data: NSData?, response, error) in
      hideNetworkActivityIndicator()
      
      guard error == nil else {
        return print(error)
      }
      
      guard data != nil else {
        return print("No data returned!")
      }
      
      guard let image = UIImage(data: data!) else {
        return print("Error converting data to image!")
      }
      
      completion(image: image)
    }
    
    dataTask.resume()
  }
  
  class func showNetworkActivityIndicator() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
  }
  
  class func hideNetworkActivityIndicator() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  }
}
