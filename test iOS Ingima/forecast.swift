//
//  weather.swift
//  test iOS Ingima
//
//  Created by Loic Sillere on 15/03/2017.
//  Copyright © 2017 Loic Sillere. All rights reserved.
//

import Foundation
import Gloss

public struct Forecast: Decodable {
    
    public let days: [Weather]?
    
    public init?(json: JSON) {
        days = "list" <~~ json
    }
    
}


/*public struct Days: Decodable {
    
    public let tempDay: Double?
    public let tempMin: Double?
    public let tempMax: Double?
    public let date: Date?
    public var weatherId: Int?
    
    public init?(json: JSON) {
        //temp = "temp" <~~ json
        //population = "population" <~~ json
        //print("entries: ", temp)
        guard let temp: JSON = "temp" <~~ json else {
                return nil
        }
        
        let weather: [Weather]?
        weather = "weather" <~~ json
        
        if let id = weather?[0].id {
            self.weatherId = id
        }
        
        /*guard let temp: JSON = "temp" <~~ container else {
                return nil
        }*/
        
        guard let tempDay: Double = "day" <~~ temp else {
            return nil
        }
        
        guard let tempMin: Double = "min" <~~ temp else {
            return nil
        }
        
        guard let tempMax: Double = "max" <~~ temp else {
            return nil
        }
        
        guard let date: Date = Date(timeIntervalSince1970: ("dt" <~~ json)!) else {
            return nil
        }
        
        self.tempDay = tempDay
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.date = date
    }
}*/



