//
//  MyCityListTableViewController.swift
//  test iOS Ingima
//
//  Created by Loic Sillere on 16/03/2017.
//  Copyright © 2017 Loic Sillere. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class MyCityListTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var savedCitiesCoreData: [NSManagedObject] = []
    var savedCities: [CitySaved] = []
    let locationManager = CLLocationManager()
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    internal let refreshControlAction = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* --------------------------------- Set up Cities -------------------------------*/
        let coreData = coredataManager()
        savedCitiesCoreData = coreData.getMyCities()
        
        for city in savedCitiesCoreData {
            if let city = CitySaved.init(id: city.value(forKeyPath: "id") as! Int) {
                self.savedCities.append(city)
            }
        }


        /* --------------------------------- Set up location -------------------------------*/
        // Ask for Authorisation from the user
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
                if let city = CitySaved.init(lat: "", long: "") {
                    savedCities.insert(city, at: 0)
                }
            }
        } else {
            print("Location services are not enabled")
        }
        
        /* --------------------------------- Set up refresh control -------------------------*/
        self.refreshControlAction.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControlAction.addTarget(self, action: #selector(refreshData(sender:)), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControlAction)
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedCities.count//savedCities.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CitiesTableViewCell
        let api = APIManager()
        
        // First city come from my location dans can be founc from lat and lon
        if(indexPath.row == 0 && (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse)) {
            if let long = self.long,
                let lat = self.lat {
            
                let parameters = ["lat" : lat.description, "lon" : long.description]
                api.download(request: "id",
                             url: "http://api.openweathermap.org/data/2.5/weather",
                             city: "",
                             parametersReceived: parameters,
                             completion: { json in
                                let todayWeather = Weather.init(jsonToday: json)!
                                self.savedCities[indexPath.row].id = todayWeather.cityId
                                self.setLabel(todayWeather: todayWeather, cell: cell, isUserLocation: true)
                })
            }
        } else { // Other cities comes from CoreData and can be found from id
            if let cityId = savedCities[indexPath.row].id {
                let parameters = ["id" : String(describing: cityId)]
                api.download(request: "id",
                             url: "http://api.openweathermap.org/data/2.5/weather",
                             city: "",
                             parametersReceived: parameters,
                             completion: { json in
                                let todayWeather = Weather.init(jsonToday: json)!
                                self.setLabel(todayWeather: todayWeather, cell: cell, isUserLocation: false)
                })
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if !(indexPath.row == 0 && (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse)) {
                
                let coreData = coredataManager()
                if savedCities.count > savedCitiesCoreData.count {
                    coreData.delete(objectToDelete: savedCitiesCoreData[indexPath.row - 1])
                    savedCitiesCoreData.remove(at: indexPath.row - 1)
                } else {
                    coreData.delete(objectToDelete: savedCitiesCoreData[indexPath.row])
                    savedCitiesCoreData.remove(at: indexPath.row)
                }
                
                savedCities.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func refreshData(sender: UIRefreshControl) {
        tableView.reloadData()
        refreshControlAction.endRefreshing()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude
        let lat = userLocation.coordinate.latitude

        // If position change we reload first line on tab
        if(self.lat != lat || self.long != long) {
            self.lat = lat
            self.long = long
            let indexPath = IndexPath(item: 0, section: 0)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickedCity" {
            let selectedCell = sender as! UITableViewCell
            let index = tableView.indexPath(for: selectedCell)
            if let indexPath = index?.row {
                if let id = savedCities[indexPath].id {
                    let viewController = segue.destination as! DetailCityViewController
                    viewController.selectedCity = String(id)
                }
            }
        }
    }
    
    func setLabel(todayWeather: Weather, cell: CitiesTableViewCell, isUserLocation: Bool) {
        if let cityName = todayWeather.cityName {
            cell.cityNameLabel.text = cityName
            
            if let actualTemp = todayWeather.temp {
                cell.actualTempLabel.text = actualTemp.description + "°"
            }else  {
                cell.actualTempLabel.text = "-"
            }
            
            if let weatherIcon = todayWeather.getWeatherIcon() {
                cell.weatherIcon.image = UIImage(named: weatherIcon)
            }
            
            if let country = todayWeather.countryCode {
                cell.countryCodeLabel.text = country
            }
            
            if isUserLocation {
                cell.locationArrowImage.isHidden = false
            }
            
        } else {
            cell.cityNameLabel.text = ""
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
