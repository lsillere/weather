//
//  city.swift
//  test iOS Ingima
//
//  Created by Loic Sillere on 16/03/2017.
//  Copyright © 2017 Loic Sillere. All rights reserved.
//

import Foundation
import Gloss

public class Cities: Decodable {
    
    public var cities: [City]?
    
    public required init?(json: JSON) {
        cities = "cities" <~~ json
    }
    
}

public class City: Decodable {
    public var id: Int?
    public var country: String?
    public var name: String?
    public var lat: String?
    public var long: String?
    public var weather: Weather?
    var test = ""
    
    public required init?(json: JSON) {
        self.id = ("_id" <~~ json)!
        self.country = ("country" <~~ json)!
        self.name = ("name" <~~ json)!
    }
    
    public init?(id: Int) {
        self.id = id
    }
    
    public init?(lat: String, long: String) {
        self.lat = lat
        self.long = long
    }
    
    func fetchWeather(completion: @escaping () -> Void) {
        let api = APIManager()
        
        if let lat = self.lat,
            let long = self.long {
            let parameters = ["lat" : lat.description, "lon" : long.description]
            api.download(request: "id",
                         url: "http://api.openweathermap.org/data/2.5/weather",
                         city: "",
                         parametersReceived: parameters,
                         completion: { json in
                            self.weather  = Weather.init(jsonToday: json)!
            })
        } else if let id = self.id {
            print("test id: ", String(describing: id))
            let parameters = ["id" : String(describing: id)]
            api.download(request: "id",
                         url: "http://api.openweathermap.org/data/2.5/weather",
                         city: "",
                         parametersReceived: parameters,
                         completion: { json in
                            self.weather  = Weather.init(jsonToday: json)!
                            
            })
            print("json", self.weather)
        }
    }
}

