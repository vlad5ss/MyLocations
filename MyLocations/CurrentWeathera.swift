//
//  CurrentWeathera.swift
//  MyLocations
//
//  Created by mac on 4/21/17.
//  Copyright © 2017 damneed. All rights reserved.
//

import UIKit
import Alamofire

class CurrentWeather {
    private var _date: String!
    private var _cityName: String!
    private var _weatherType: String!
    private var _currentTemp: Double!
    
    var date: String {
        if _date == nil{
            _date = ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        let currentDate = dateFormatter.string(from: Date())
        _date = "Today, \(currentDate)"
        
        return _date
    }
    
    var cityName: String {
        if _cityName == nil{
            _cityName = ""
        }
        
        return _cityName
    }
    
    var weatherType: String {
        if _weatherType == nil{
            _weatherType = ""
        }
        
        return _weatherType
    }
    
    var currentTemp: String {
        if _currentTemp == nil{
            _currentTemp = 0.0
        }
        
        _currentTemp = Double(round(10*_currentTemp)/10)
        
        return "\(_currentTemp!)°C"
    }
    
    func downloadWeatherData(completed: @escaping DownloadComplete){
        
        let currentWeatherURL = URL(string: CURRENT_WEATHER_URL)!
        
        //AlamoFire download
        Alamofire.request(currentWeatherURL).responseJSON {
            response in
            let result = response.result
            if let dictionary = result.value as? Dictionary<String,AnyObject>{
                if let name = dictionary["name"] as? String{
                    self._cityName = name.capitalized
                }
                
                if let weather = dictionary["weather"] as? [Dictionary<String,AnyObject>]{
                    if let main = weather[0]["main"] as? String{
                        self._weatherType = main.capitalized
                    }
                }
                
                if let main = dictionary["main"] as? Dictionary<String,AnyObject>{
                    if let temperature = main["temp"] as? Double{
                        let celsiusFromKelvin = temperature - 273.15
                        //                        let fahrenheitFromCelsius = celsiusFromKelvin * 9/5 + 32
                        self._currentTemp = celsiusFromKelvin
                    }
                }
                
            }
            completed()
        }
    }
}
