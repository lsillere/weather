//
//  SearchCityViewController.swift
//  test iOS Ingima
//
//  Created by Loic Sillere on 16/03/2017.
//  Copyright © 2017 Loic Sillere. All rights reserved.
//

import UIKit

class SearchCityViewController: UITableViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    var cities: Cities?
    var filteredCities: Cities?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar*/
        
        // Search Controller customization
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search your camera model"
        // searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.barTintColor = UIColor.black
        searchController.searchBar.layer.borderWidth = 1
        searchController.searchBar.layer.borderColor = UIColor.black.cgColor
        searchController.searchBar.tintColor = UIColor.white
        
        
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        let url = Bundle.main.url(forResource: "cityListFrance", withExtension: "json")
        
        // Load Data
        let data = try! Data(contentsOf: url!)
        
        // Deserialize JSON
        if let JSON = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            cities = Cities.init(json: JSON)
            filteredCities = cities
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let count = cities?.cities?.count else {
            return 0
        }
        if searchController.isActive && searchController.searchBar.text != "" {
            return (filteredCities?.cities!.count)!
        }
       
        /*if searchController.isActive && searchController.searchBar.text != "" {
            guard let countSearch = filteredCities?.cities?.count else {
                return 0
            }
            return
        }*/
        
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let cityName: String
        if searchController.isActive && searchController.searchBar.text != "" {
            cityName = (filteredCities?.cities?[indexPath.row].name)!
        } else {
            cityName = (cities?.cities?[indexPath.row].name)!
        }
        
        
        cell.textLabel?.text = cityName
        
        return cell
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredCities?.cities = cities?.cities?.filter { citiesFind in
            print("filter 2", citiesFind.name)
            return (citiesFind.name!.lowercased().range(of: searchText.lowercased()) != nil)
        }
        
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected : ", indexPath)
        
        let coreData = coredataManager()
        coreData.saveCityID(id: (cities?.cities?[indexPath.row].id)!)
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
