//
//  Forecast.swift
//  Weather
//
//  Created by Paulo Pão on 01/09/16.
//  Copyright © 2016 Paulo Pão. All rights reserved.
//

struct Forecast {
  var temperature:        String?
  var icon:               String?
  var weatherDescription: String?
  var feelsLike:          String?
  var precipitation:      String?
  var humidity:           String?
  var wind:               String?
  var pressure:           String?
  var observationTime:    String?
  
  init!(attributes: [String: AnyObject]) {    
    guard let aTemperature  = attributes["temp_C"] as? String,
      descObject            = attributes["weatherDesc"] as? [[String: String]],
      aWeatherDescription   = descObject[0]["value"],
      iconObject            = attributes["weatherIconUrl"] as? [[String: String]],
      aIcon                 = iconObject[0]["value"],
      aFeelsLike            = attributes["FeelsLikeC"] as? String,
      aPrecipitation        = attributes["precipMM"] as? String,
      aHumidity             = attributes["humidity"] as? String,
      aWind                 = attributes["windspeedKmph"] as? String,
      aPressure             = attributes["pressure"] as? String,
      aObservationTime      = attributes["observation_time"] as? String
      else {
        return nil
    }
    
    temperature         = aTemperature
    weatherDescription  = aWeatherDescription
    icon                = aIcon
    feelsLike           = aFeelsLike
    precipitation       = aPrecipitation
    humidity            = aHumidity
    wind                = aWind
    pressure            = aPressure
    observationTime     = aObservationTime
  }
}