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
    
    public var cities: [CitySaved]?
    
    public required init?(json: JSON) {
        cities = "cities" <~~ json
    }
    
}


public class CitySaved: Decodable {
    public var id: Int?
    public var country: String?
    public var name: String?
    public var lat: String?
    public var long: String?
    
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
}

