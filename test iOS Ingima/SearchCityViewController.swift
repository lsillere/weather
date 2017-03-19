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
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(false, animated:true)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return filteredCities.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let cityName = filteredCities[indexPath.row].value(forKeyPath: "name") as! String
        let country = filteredCities[indexPath.row].value(forKeyPath: "country") as! String
        
        cell.textLabel?.text = cityName + " (" + country + ")"
        
        return cell
    }
    
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    
    /*------------------------ Filtered table view with searh result ------------------------------ */
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
    
    /*------------------------ Selection of a city -> save her ID in coreData -------------------- */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let coreData = coredataManager()
        coreData.saveCityID(id: (filteredCities[indexPath.row].value(forKeyPath: "id") as! Int))
    }
}
