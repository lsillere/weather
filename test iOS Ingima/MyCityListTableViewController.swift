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
    
    //var savedCitiesId: [Int] = []
    var savedCitiesCoreData: [NSManagedObject] = []
    var savedCities: [City] = []
    let locationManager = CLLocationManager()
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    internal let refreshControlAction = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        let coreData = coredataManager()
        savedCitiesCoreData = coreData.getMyCities()
        
        for i in 0...savedCitiesCoreData.count - 1 {
            if let city = City.init(id: savedCitiesCoreData[i].value(forKeyPath: "id") as! Int) {
                savedCities.append(city)
            }
        }
        /*for city in savedCitiesCoreData {
            if let city = City.init(id: city.value(forKeyPath: "id") as! Int) {
                savedCities.append(city)
            }
        }*/
        
        tableView.reloadData()

        /* --------------------------------- Set up location -------------------------------*/
        // Ask for Authorisation from the User.
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
                if let city = City.init(lat: "", long: "") {
                    savedCities.insert(city, at: 0)
                }
            }
        } else {
            print("Location services are not enabled")
        }
        
        
        //setWeatherForCity()
        
        /* --------------------------------- Set up refresh control -------------------------*/
        self.refreshControlAction.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControlAction.addTarget(self, action: #selector(refreshData(sender:)), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControlAction)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(false, animated:true)
        super.viewWillDisappear(animated)
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
        
        /*if let weather = savedCities[indexPath.row].weather {
            print("test weather exist")
            self.setLabel(todayWeather: weather, cell: cell)
        }*/
        
        if(indexPath.row == 0 && (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse)) {
            if let long = self.long,
                let lat = self.lat {
                //print("long : \(long.description), lat : \(lat.description)")
            
                let parameters = ["lat" : lat.description, "lon" : long.description]
                api.download(request: "id",
                             url: "http://api.openweathermap.org/data/2.5/weather",
                             city: "",
                             parametersReceived: parameters,
                             completion: { json in
                                let todayWeather = Weather.init(jsonToday: json)!
                                self.savedCities[indexPath.row].id = todayWeather.cityId
                                print("today weather ID : ", todayWeather.cityId)
                                self.setLabel(todayWeather: todayWeather, cell: cell)
                })
            }
        } else {
            print("id:", String(describing: savedCities[indexPath.row].id))
            if let cityId = savedCities[indexPath.row].id {
                //self.setLabel(todayWeather: savedCities[indexPath.row].weather!, cell: cell)
                let parameters = ["id" : String(describing: cityId)]
                api.download(request: "id",
                             url: "http://api.openweathermap.org/data/2.5/weather",
                             city: "",
                             parametersReceived: parameters,
                             completion: { json in
                                let todayWeather = Weather.init(jsonToday: json)!
                                self.setLabel(todayWeather: todayWeather, cell: cell)
                })
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.row == 0 && (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
                
            } else {
                let coreData = coredataManager()
                if savedCities.count > savedCitiesCoreData.count {
                    coreData.delete(objectToDelete: savedCitiesCoreData[indexPath.row - 1])
                    savedCitiesCoreData.remove(at: indexPath.row - 1)
                } else {
                    coreData.delete(objectToDelete: savedCitiesCoreData[indexPath.row])
                    savedCitiesCoreData.remove(at: indexPath.row)
                }
            }
            
            savedCities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func refreshData(sender: UIRefreshControl) {
        //fetchFixtures()
        
        refreshControlAction.endRefreshing()
    }
    
    func fetchWeatherForCity() {
        let api = APIManager()
        
        for i in 0...savedCities.count {
            if(i == 0 && (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse)) {
                if let long = self.long,
                    let lat = self.lat {
                    
                    let parameters = ["lat" : lat.description, "lon" : long.description]
                    api.download(request: "id",
                                 url: "http://api.openweathermap.org/data/2.5/weather",
                                 city: "",
                                 parametersReceived: parameters,
                                 completion: { json in
                                    self.savedCities[i].weather = Weather.init(jsonToday: json)!
                                    //let todayWeather = Weather.init(jsonToday: json)!
                                    self.savedCities[i].id = self.savedCities[i].id
                                    //print("today weather ID : ", todayWeather.cityId)
                                    //self.setLabel(todayWeather: todayWeather, cell: cell)
                    })
                }
            } else {
                print("id:", String(describing: savedCities[i].id))
                if let cityId = savedCities[i].id {
                    //self.setLabel(todayWeather: savedCities[indexPath.row].weather!, cell: cell)
                    let parameters = ["id" : String(describing: cityId)]
                     api.download(request: "id",
                                  url: "http://api.openweathermap.org/data/2.5/weather",
                                  city: "",
                                  parametersReceived: parameters,
                                  completion: { json in
                                    self.savedCities[i].weather = Weather.init(jsonToday: json)!
                     //let todayWeather = Weather.init(jsonToday: json)!
                     //self.setLabel(todayWeather: todayWeather, cell: cell)
                     })
                }
            }

        }
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
                    let viewController = segue.destination as! ViewController
                    viewController.selectedCity = String(id)
                }
                /*if searchController.isActive && searchController.searchBar.text != "" {
                    tableVC.selectedCamera = filteredCameras[indexPath]
                    // test with unwind segue : pickedCamera = filteredCameras[indexPath]
                } else {
                    tableVC.selectedCamera = cameras[indexPath]
                    // test with unwind segue : pickedCamera = cameras[indexPath]
                }*/
            }
        }
    }
    
    func setLabel(todayWeather: Weather, cell: CitiesTableViewCell) {
        if let cityName = todayWeather.cityName {
            cell.cityNameLabel.text = cityName
            
            if let actualTemp = todayWeather.temp {
                cell.actualTempLabel.text = actualTemp.description + " °"
            }else  {
                cell.actualTempLabel.text = "-"
            }
            
            if let weatherIcon = todayWeather.getWeatherIcon() {
                cell.weatherIcon.image = UIImage(named: weatherIcon)
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
