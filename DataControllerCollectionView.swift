//
//  DataControllerCollectionView.swift
//  Virtual Tourist
//
//  Created by Basma Ahmed Mohamed Mahmoud on 4/15/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import UIKit
import CoreData

class DataControllerCollectionView: NSObject {
    
    class func getContext() -> NSManagedObjectContext{
        let appleDelegate = UIApplication.shared.delegate as? AppDelegate
        return (appleDelegate?.persistentContainer.viewContext)!
    }
    
    class func saveImageUrls(imageUrl: String) -> NSManagedObject{
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "ImageUrl",in: context)
        let imageString = NSManagedObject(entity: entity!, insertInto: context)
        imageString.setValue(imageUrl, forKey: "imageUrlText")
        
        try? context.save()
        return imageString
    }
    
    class func saveImage(actualimage: Data) -> NSManagedObject{
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "ImageUrl",in: context)
        let image = NSManagedObject(entity: entity!, insertInto: context)
        image.setValue(actualimage, forKey: "actualImage")
        
        try? context.save()
        return image
    }
    
    class func fetchImageUrls(annotCoord: AnnotCoord) -> [ImageUrl]?{
        
        let context = getContext()
        var imageUrl:[ImageUrl]? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageUrl")
        let predicate = NSPredicate(format:"annotCoord == %@", annotCoord)
        
        fetchRequest.predicate = predicate
        imageUrl = try! context.fetch(fetchRequest) as? [ImageUrl]
        return imageUrl
    }
    
    class func deleteImage(imageUrl: ImageUrl) -> Bool{
        let context = getContext()
        context.delete(imageUrl)
        do{
            try context.save()
            return true
        }catch{
            return false
        }
    }
    
    class func deleteAllData() -> Bool{
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: ImageUrl.fetchRequest())
        do{
            try context.execute(delete)
            return true
        }catch{
            return false
        }
    }
}

