//
//  Forecast.swift
//  MyLocations
//
//  Created by mac on 4/21/17.
//  Copyright © 2017 damneed. All rights reserved.
//



import UIKit
import Alamofire

class Forecast {
    private var _date: String!
    private var _weatherType: String!
    private var _highTemp: Double!
    private var _lowTemp: Double!
    
    var date: String{
        if _date == nil {
            _date = ""
        }
        return _date
    }
    var weatherType: String {
        if _weatherType == nil {
            _weatherType = ""
        }
        return _weatherType
    }
    
    var highTemp: Double {
        if _highTemp == nil {
            _highTemp = 0.0
        }
        
        _highTemp = Double(round(10*_highTemp)/10)
        
        return _highTemp
    }
    
    var lowTemp: Double {
        if _lowTemp == nil {
            _lowTemp = 0.0
        }
        
        _lowTemp = Double(round(10*_lowTemp)/10)
        
        return _lowTemp
    }
    
    init(weatherDictionary: Dictionary<String,AnyObject>){
        if let temp = weatherDictionary["temp"] as? Dictionary<String,AnyObject>{
            if let min = temp["min"] as? Double {
                let celsiusFromKelvin = min - 273.15
                //                        let fahrenheitFromCelsius = celsiusFromKelvin * 9/5 + 32
                self._lowTemp = celsiusFromKelvin
            }
            
            if let max = temp["max"] as? Double {
                let celsiusFromKelvin = max - 273.15
                //                        let fahrenheitFromCelsius = celsiusFromKelvin * 9/5 + 32
                self._highTemp = celsiusFromKelvin
            }
        }
        
        if let weather = weatherDictionary["weather"] as? [Dictionary<String,AnyObject>]{
            let main = weather[0]["main"] as? String
            self._weatherType = main
        }
        
        if let date = weatherDictionary["dt"] as? Double {
            let unixConvertedDate = Date(timeIntervalSince1970: date)
            self._date = unixConvertedDate.dayOfTheWeek()
        }
        
    }
}

extension Date {
    func dayOfTheWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
}


