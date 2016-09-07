//
//  ViewController.swift
//  Weather
//
//  Created by Paulo Pão on 01/09/16.
//  Copyright © 2016 Paulo Pão. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  var forecasts: [Forecast] = []
  var timer: NSTimer!
  var updateSeconds = 600.0
  var requestGroup = dispatch_group_create()
  var cities: [City] = [
    .Sydney,
    .Melbourne,
    .Brisbane,
    .Adelaide,
    .Perth,
    .Hobart,
    .Darwin
  ]
  
  lazy var plist = PlistManager()
  
  lazy var refreshControlItem: UIRefreshControl = {
    let item = UIRefreshControl()
    item.backgroundColor = .clearColor()
    item.tintColor = UIColor.grayColor()
    item.addTarget(self,
      action: #selector(ViewController.refreshForecast),
      forControlEvents: UIControlEvents.ValueChanged
    )
    return item
  }()
  
  lazy var mask: UIView = {
    let view = UIView()
    view.backgroundColor = .whiteColor()
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    getForecast()
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = 145
    tableView.estimatedRowHeight = 145
    tableView.separatorStyle = .SingleLine
    tableView.backgroundColor = .whiteColor()
    tableView.tableFooterView = mask
    tableView.addSubview(refreshControlItem)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidLayoutSubviews() {
    tableView.layoutIfNeeded()
  }
  
  func setRefreshTimer(interval: Double) {
    timer = NSTimer.scheduledTimerWithTimeInterval(interval,
      target: self,
      selector: #selector(ViewController.fetchForecast),
      userInfo: nil,
      repeats: true
    )
  }
  
  func getForecast() {
    guard let datePlist = plist.fetchDatePlist(),
      date = datePlist.valueForKey("date") as? NSDate else {
      return fetchForecast()
    }
    
    let interval = NSDate().timeIntervalSinceDate(date)
    
    if interval < updateSeconds {
      setRefreshTimer(interval)
      
      return loadForecast()
    }
    
    fetchForecast()
  }
  
  func loadForecast() {
    guard let forecastPlist = plist.fetchForecastPlist() else { return }
    
    for forecast in forecastPlist {
      forecasts.append(Forecast(attributes: forecast))
    }
    
    tableView.reloadData()
  }
  
  func fetchForecast() {
    var cacheArray: [[String: AnyObject]] = []
    forecasts.removeAll()
    
    for city in cities {
      dispatch_group_enter(requestGroup)
      Service.fetchData(city.rawValue) { (data) in
        guard let returnedData = data["data"] as? [String: AnyObject],
          currentConditionArray = returnedData["current_condition"] as? [[String: AnyObject]],
          currentConditionDict = Forecast(attributes: currentConditionArray[0]) else {
            return
        }
        
        cacheArray.append(currentConditionArray[0])
        self.forecasts.append(currentConditionDict)
        dispatch_group_leave(self.requestGroup)
      }
    }
    
    dispatch_group_notify(requestGroup, dispatch_get_main_queue(), {
      self.plist.cacheDate()
      self.setRefreshTimer(self.updateSeconds)
      self.plist.cacheForecast(cacheArray)
      self.refreshControlItem.endRefreshing()
      self.tableView.reloadData()
    })
  }
  
  func refreshForecast() {
    fetchForecast()
  }
  
  func getForecastFor(indexPath: NSIndexPath) -> Forecast? {
    if forecasts.count == 0 { return nil }
    
    return forecasts[indexPath.row]
  }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return forecasts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ForecastCell", forIndexPath: indexPath) as! ForecastCell
    
    cell.city     = cities[indexPath.row]
    cell.forecast = getForecastFor(indexPath)
    
    if let iconUrl = cell.forecast?.icon,
      url = NSURL(string: iconUrl) {
      
      dispatch_async(dispatch_get_main_queue(), {
        Service.fetchImage(url, completion: { (image) in
          dispatch_async(dispatch_get_main_queue(), {
            cell.iconView.image = image
          })
        })
      })
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? ForecastCell else { return }
    
    cell.backgroundColor = .grayColor()
    cell.expandAdditionalInfoView()
  }
  
  func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? ForecastCell else { return }
    
    cell.backgroundColor = .whiteColor()
    cell.collapseAdditionalInfoView()
  }
}