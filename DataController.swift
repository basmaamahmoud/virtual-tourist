//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Basma Ahmed Mohamed Mahmoud on 4/14/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import UIKit
import CoreData

class DataController: NSObject {
    
    private class func getContext() -> NSManagedObjectContext{
        let appleDelegate = UIApplication.shared.delegate as? AppDelegate
        return (appleDelegate?.persistentContainer.viewContext)!
    }
    
    class func saveAnnotation(latitude: Double, longitude: Double) -> NSManagedObject{
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AnnotCoord",in: context)
        let annotCoord = NSManagedObject(entity: entity!, insertInto: context)
        
        annotCoord.setValue(latitude, forKey: "latitude")
        annotCoord.setValue(longitude, forKey: "longitude")
        annotCoord.setValue(Date(), forKey: "date")
        
        try? context.save()
        return annotCoord
    }
    
    class func saveRegion(regionLatit: Double, regionLong: Double, spanDeltaLat: Double, spanDeltaLong: Double, date: Date) -> Bool{
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Region",in: context)
        
        let region = NSManagedObject(entity: entity!, insertInto: context)
        
        region.setValue(regionLatit, forKey: "regionLat")
        region.setValue(regionLong, forKey: "regionLong")
        region.setValue(spanDeltaLat, forKey: "spanDeltaLat")
        region.setValue(spanDeltaLong, forKey: "spanDeltaLong")
        region.setValue(date, forKey: "date")
        do{
            try context.save()
            return true
        }catch{
            return false
        }
        
    }
    
    class func fetchAnnot() -> [AnnotCoord]?{
        
        let context = getContext()
        var annotCoord:[AnnotCoord]? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AnnotCoord")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do{
            annotCoord = try context.fetch(fetchRequest) as? [AnnotCoord]
            return annotCoord
        }catch{
            return annotCoord
        }
    }
    
    class func fetchRegion() -> [Region]?{
        
        let context = getContext()
        var region:[Region]? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Region")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do{
            region = try context.fetch(fetchRequest) as? [Region]
            return region
        }catch{
            return region
        }
    }
    
    class func deleteAnnotCoord(annotCoord: AnnotCoord) -> Bool{
        let context = getContext()
        context.delete(annotCoord)
        do{
            try context.save()
            return true
        }catch{
            return false
        }
    }
    
    class func deleteAllData() -> Bool{
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: AnnotCoord.fetchRequest())
        do{
            try context.execute(delete)
            return true
        }catch{
            return false
        }
    }
    
}
