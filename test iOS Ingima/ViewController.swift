//
//  ViewController.swift
//  test iOS Ingima
//
//  Created by Loic Sillere on 15/03/2017.
//  Copyright © 2017 Loic Sillere. All rights reserved.
//

import UIKit
import Alamofire
import Gloss
import CoreLocation

extension Date {
    func printTime() -> String? {
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: self) - 1
        let minutes = calendar.component(.minute, from: self)
        
        let strHour = String(format: "%02d", hour)
        let strMinutes = String(format: "%02d", minutes)
        
        return "\(strHour):\(strMinutes)"//self.components(separatedBy: "/").last?.components(separatedBy: ".").first.flatMap{Int($0)}
    }
    
    func getDayOfWeekName() -> String? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDayNumber = myCalendar.component(.weekday, from: self)
        //print("weekDay test :", weekDay)
        
        let weekdayName:String
        switch weekDayNumber {
        case 2:
            weekdayName = "Lundi"
        case 3:
            weekdayName = "Mardi"
        case 4:
            weekdayName = "Mercredi"
        case 5:
            weekdayName = "Jeudi"
        case 6:
            weekdayName = "Vendredi"
        case 7:
            weekdayName = "Samedi"
        case 1:
            weekdayName = "Dimanche"
        default:
            weekdayName = ""
        }
        
        return weekdayName
    }

}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var forecastDaily: Forecast?
    var todayWeather: Weather?
    let locationManager = CLLocationManager()
    var selectedCity: String?
    
    @IBOutlet weak var dailyForecastTableView: UITableView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var actualTempLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Ask for Authorisation from the User.
        /*self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }*/
        
        
        /*downloadTags(contentID: "test")
        downloadTodayWeather(contentID: "test")*/
        /*{ tags in
            completion(tags, [PhotoColor]())
        }*/
        
        if let city = selectedCity {
            let api = APIManager()
        
            // Get today weather
            var parameters = ["id" : city]
            api.download(request: "id",
                         url: "http://api.openweathermap.org/data/2.5/weather",
                         city: city,
                         parametersReceived : parameters,
                         completion: { json in
                            self.todayWeather = Weather.init(jsonToday: json)
                            self.labelMapping()
            })
            
            // Get forecast for next 10 days
            parameters["cnt"] = "10"
            api.download(request: "id",
                         url: "http://api.openweathermap.org/data/2.5/forecast/daily",
                         city: city,
                         parametersReceived : parameters,
                         completion: { json in
                            self.forecastDaily = Forecast.init(json: json)
                            self.dailyForecastTableView.reloadData()
            })
        }
        
        
        /*let date = Date()
        let weekdayName = date.getDayOfWeekName()
        print(weekdayName)
        
        print("selectedCity: ", selectedCity)*/
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dailyForecastTableView.dequeueReusableCell(withIdentifier: "temp", for: indexPath) as! WeatherTableViewCell
        
        if let tempMin = self.forecastDaily?.days?[indexPath.row].tempMin {
            cell.tempMin.text = "\(Int(round(tempMin)))°"
        }
        if let tempMax = self.forecastDaily?.days?[indexPath.row].tempMax {
            cell.tempMax.text = "\(Int(round(tempMax)))°"
        }

        if let date = self.forecastDaily!.days![indexPath.row].date {
             cell.day.text = date.getDayOfWeekName()
        }
        
        if let weatherIcon = self.forecastDaily?.days?[indexPath.row].getWeatherIcon() {
            cell.weatherIcon.image = UIImage(named: weatherIcon)
        }
        
        return cell
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = forecastDaily?.days?.count else {
            return 0
        }
        
        return count
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
        print("long : \(long), lat : \(lat)")
    }
    
    func labelMapping() {
        //cityNameLabel: UILabel!
        //weatherDescriptionLabel = todayWeather.
        if let pressure = todayWeather?.pressure?.description {
            pressureLabel.text = pressure + " hPa"
        }
        if let humidity = todayWeather?.humidity?.description {
            humidityLabel.text = humidity + " %"
        }
        if let wind = todayWeather?.windSpeed?.description {
            windLabel.text = wind + " km/h"
        }
        if let sunrise = todayWeather?.sunrise {
            sunriseLabel.text = sunrise.printTime()
        }
        if let sunset = todayWeather?.sunset {
            sunsetLabel.text = sunset.printTime()
        }
        if let actualTemp = todayWeather?.temp?.description {
            actualTempLabel.text = actualTemp + "°"
        }
        if let visibility = todayWeather?.visibility?.description {
            visibilityLabel.text = visibility
        }
        if let description = todayWeather?.weatherDescription {
            weatherDescriptionLabel.text = description
        }
    }
    
}

