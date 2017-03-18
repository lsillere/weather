//
//  todayWeather.swift
//  test iOS Ingima
//
//  Created by Loic Sillere on 15/03/2017.
//  Copyright © 2017 Loic Sillere. All rights reserved.
//

import Foundation
import Gloss

public struct Weather:Decodable {
    
    public var cityName: String?
    public var windSpeed: Int?
    public var windDeg: Int?
    public var weatherDescription: String?
    public var temp: Int?
    public var pressure: Int?
    public var humidity: Int?
    public var sunrise: Date?
    public var sunset: Date?
    public var visibility: Int?
    public var cityId: Int?
    
    public var tempMin: Double?
    public var tempMax: Double?
    public var date: Date?
    public var weatherId: Int?
    
    public init?(jsonToday: JSON) {
        if let sys: JSON = "sys" <~~ jsonToday {
            if let sunrise: Double = "sunrise" <~~ sys {
                self.sunrise = Date(timeIntervalSince1970: sunrise)
            }
            if let sunset: Double = "sunset" <~~ sys {
                self.sunset = Date(timeIntervalSince1970: sunset)
            }
        }
        
        if let wind: JSON = "wind" <~~ jsonToday {
            if let windDeg: Int = "deg" <~~ wind {
                self.windDeg = windDeg
            }
            if let windSpeed: Int = "speed" <~~ wind {
                self.windSpeed = windSpeed
            }
        }
        
        if let main: JSON = "main" <~~ jsonToday {
            if let temp: Int = "temp" <~~ main{
                self.temp = temp
            }
            if let pressure: Int = "pressure" <~~ main {
                self.pressure = pressure
            }
            if let humidity: Int = "humidity" <~~ main {
                self.humidity = humidity
            }
        }
        
        if let cityId: Int = "id" <~~ jsonToday {
            self.cityId = cityId
        }
        
        let weather: [WeatherInfo]?
        weather = "weather" <~~ jsonToday
        
        if let id = weather?[0].id {
            self.weatherId = id
        }
        if let description = weather?[0].description {
            self.weatherDescription = description
        }
        
        /*if let weather: JSON = "weather" <~~ jsonToday {
            print("test ID")
            if let description: String = "description" <~~ weather{
                self.weatherDescription = description
            }
            if let id: Int = "id" <~~ weather {
                self.weatherId = id
            }
        }*/
        
        if let cityName: String = "name" <~~ jsonToday {
            self.cityName = cityName
        }
        
        if let visibility: Int = "visibility" <~~ jsonToday {
            self.visibility = visibility
        }
        
    }
    
    public init?(json: JSON) {

        guard let temp: JSON = "temp" <~~ json else {
            return nil
        }
        
        if let tempDay: Int = "day" <~~ temp {
            self.temp = tempDay
        }
        
        if let tempMin: Double = "min" <~~ temp {
            self.tempMin = tempMin
        }
        
        if let tempMax: Double = "max" <~~ temp {
            self.tempMax = tempMax
        }
        
        if let date: Date = Date(timeIntervalSince1970: ("dt" <~~ json)!) {
            self.date = date
        }
        
        let weather: [WeatherInfo]?
        weather = "weather" <~~ json
        if let id = weather?[0].id {
            self.weatherId = id
        }
    }
    
    func getWeatherIcon() -> String? {
        
        guard let weatherId = weatherId else {
            return nil
        }
        
        if(weatherId >= 200 && weatherId < 300 ){
            return "strom"
        } else if(weatherId >= 300 && weatherId < 400 ){
            return "shower-rain"
        } else if(weatherId >= 500 && weatherId < 600 ){
            return "rain"
        } else if(weatherId >= 600 && weatherId < 700 ){
            return "snow"
        } else if(weatherId >= 700 && weatherId < 800 ){
            return "mist"
        } else if(weatherId == 800) {
            return "sun"
        } else if(weatherId == 801) {
            return "cloudy"
        } else if(weatherId == 802) {
            return "cloud"
        } else if(weatherId == 803 || weatherId == 804) {
            return "lot-of-cloud"
        } else {
            return nil
        }
    }
}

public struct WeatherInfo: Decodable {
    public var id: Int?
    public var description: String?
    
    public init?(json: JSON) {
        if let id: Int = "id" <~~ json {
            self.id = id
        }
        if let description: String = "description" <~~ json {
            self.description = description
        }
    }
}
