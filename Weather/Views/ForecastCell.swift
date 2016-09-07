//
//  ForecastCell.swift
//  Weather
//
//  Created by Paulo Pão on 02/09/16.
//  Copyright © 2016 Paulo Pão. All rights reserved.
//

import Foundation
import UIKit

class ForecastCell: UITableViewCell {
  @IBOutlet weak var iconView:            UIImageView!
  @IBOutlet weak var cityLabel:           UILabel!
  @IBOutlet weak var temperatureLabel:    UILabel!
  @IBOutlet weak var descriptionLabel:    UILabel!
  @IBOutlet weak var feelsLabel:          UILabel!
  @IBOutlet weak var precipitationLabel:  UILabel!
  @IBOutlet weak var humidityLabel:       UILabel!
  @IBOutlet weak var pressureLabel:       UILabel!
  @IBOutlet weak var windLabel:           UILabel!
  @IBOutlet weak var timeLabel:           UILabel!
  @IBOutlet weak var additionalInfoHeightConstraint: NSLayoutConstraint!
  
  var city: City?
  
  var forecast: Forecast? {
    didSet {
      if let forecast = forecast {
        if let city = city?.rawValue {
          cityLabel.text = city
        }
        
        guard let temperature = forecast.temperature,
          weatherDescription = forecast.weatherDescription,
          feelsLike = forecast.feelsLike,
          precipitation = forecast.precipitation,
          humidity = forecast.humidity,
          pressure = forecast.pressure,
          wind = forecast.wind,
          observationTime = forecast.observationTime else {
            return
        }
        
        temperatureLabel.text   = "\(temperature)°"
        descriptionLabel.text   = "\(weatherDescription)"
        feelsLabel.text         = "Feels like \(feelsLike)°"
        precipitationLabel.text = "Prec. \(precipitation)mm"
        humidityLabel.text      = "Humidity: \(humidity)%"
        pressureLabel.text      = "Barom: \(pressure)"
        windLabel.text          = "Wind speed: \(wind) km/h"
        timeLabel.text          = "Observed at \(observationTime)"
      }
    }
  }
  
  func collapseAdditionalInfoView() {
    humidityLabel.hidden  = true
    pressureLabel.hidden  = true
    windLabel.hidden      = true
    additionalInfoHeightConstraint.constant = 0
  }
  
  func expandAdditionalInfoView() {
    humidityLabel.hidden  = false
    pressureLabel.hidden  = false
    windLabel.hidden      = false
    additionalInfoHeightConstraint.constant = 20
  }
}