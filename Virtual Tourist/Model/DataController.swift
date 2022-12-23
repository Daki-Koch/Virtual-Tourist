//
//  DataController.swift
//  Virtual Tourist
//
//  Created by David Koch on 17.12.22.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
}

extension DataController{
    func autoSaveViewContext(interval:TimeInterval = 30){
        guard interval > 0 else {
            print("cannot set negative interval")
            return
        }
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: {
            self.autoSaveViewContext(interval: interval)
        })
    }
}

