//
//  CoredataManager.swift
//  test iOS Ingima
//
//  Created by Loic Sillere on 16/03/2017.
//  Copyright © 2017 Loic Sillere. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class coredataManager {
    
    func saveCityID(id: Int) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "MyCities", in: managedContext)!
        
        let city = NSManagedObject(entity: entity, insertInto: managedContext)
        
        city.setValue(id, forKeyPath: "id")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    
    func getMyCities() -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MyCities")
        
        var cities: [NSManagedObject] = []
        
        do {
            cities = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return cities
    }
    
    
    func delete(objectToDelete: NSManagedObject) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(objectToDelete)
        appDelegate.saveContext()
    }
    
    
    func myFetchRequest(searchText: String) -> [NSManagedObject]
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "City")
        
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)

        do{
            let results = try context.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            return results as! [NSManagedObject]
        } catch let error{
            print(error)
        }
        
        return []
    }

}
