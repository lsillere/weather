//
//  APIManager.swift
//  test iOS Ingima
//
//  Created by Loic Sillere on 16/03/2017.
//  Copyright © 2017 Loic Sillere. All rights reserved.
//

import Foundation
import Alamofire

class APIManager {
    func download(request: String, url: String, city: String, parametersReceived: [String : String], completion: @escaping ([String: Any]) -> Void) {
        
        var parameters = parametersReceived
        parameters["units"] = "metric"
        parameters["APPID"] = "9e6f732dad3cc14c1004c9907e17f0cd"
        
        Alamofire.request(
            url,
            parameters: parameters)
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while fetching tags: \(response.result.error)")
                    completion([String: Any]())
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    print("Invalid tag information received from the service")
                    completion([String: Any]())
                    return
                }

                completion(responseJSON)
        }
    }

}
