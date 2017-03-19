//
//  SearchCityViewController.swift
//  test iOS Ingima
//
//  Created by Loic Sillere on 16/03/2017.
//  Copyright © 2017 Loic Sillere. All rights reserved.
//

import UIKit
import CoreData

class SearchCityViewController: UITableViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCities: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appColor = UIColor(red: 136/255, green: 210/255, blue: 202/255, alpha: 1.0)
        
        // Navigation bar customization
        let nav = self.navigationController?.navigationBar
        nav?.isTranslucent = false
        nav?.tintColor = UIColor.white
        nav?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        nav?.shadowImage = UIImage()
        
        // Search Controller customization
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search your city"
        searchController.searchBar.barTintColor = appColor
        searchController.searchBar.layer.borderWidth = 1
        searchController.searchBar.layer.borderColor = appColor.cgColor
        searchController.searchBar.tintColor = UIColor.white
        
        
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        /*let url = Bundle.main.url(forResource: "cityListFrance", withExtension: "json")
        
        // Load Data
        let data = try! Data(contentsOf: url!)
        
        // Deserialize JSON
        if let JSON = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            cities = Cities.init(json: JSON)
            //filteredCities = cities
            tableView.reloadData()
        }*/
        
        filteredCities = []
        //cities = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(false, animated:true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        /*guard let count = cities?.cities?.count else {
            return 0
        }
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredCities.count
        }*/
       
        return filteredCities.count
        /*if searchController.isActive && searchController.searchBar.text != "" {
            guard let countSearch = filteredCities?.cities?.count else {
                return 0
            }
            return
        }*/
        
        //return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let city: String
        //if searchController.isActive && searchController.searchBar.text != "" {
            let cityName = filteredCities[indexPath.row].value(forKeyPath: "name") as! String
            let country = filteredCities[indexPath.row].value(forKeyPath: "country") as! String
            city = cityName + " (" + country + ")"
        /*} else {
            city = (cities?.cities?[indexPath.row].name)!
        }*/
        
        cell.textLabel?.text = city
        
        return cell
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    
    /*------------------------ Filtered table view with searh result -------------------- */
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        /*filteredCities?.cities = cities?.cities?.filter { citiesFind in
            print("filter 2", citiesFind.name)
            return (citiesFind.name!.lowercased().range(of: searchText.lowercased()) != nil)
        }*/
        
        // Search is make only when there is enough characters for limiting results
        if searchText.characters.count >= 3 {
            let coredata = coredataManager()
            filteredCities = coredata.myFetchRequest(searchText: searchText)
        }

        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected : ", indexPath)
        
        let coreData = coredataManager()
        coreData.saveCityID(id: (filteredCities[indexPath.row].value(forKeyPath: "id") as! Int))
        //self.performSegueWithIdentifier("yourIdentifier", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
