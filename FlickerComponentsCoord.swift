//
//  FlickerComponents.swift
//  Virtual Tourist
//
//  Created by Basma Ahmed Mohamed Mahmoud on 4/4/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import Foundation

class FlickerComponentsCoord{

    private static let _instance = FlickerComponentsCoord()
    
    static var Instance: FlickerComponentsCoord{
        
        return _instance
    }
    
    
    func getComponentsCoordinate(latitude: Double,logitude: Double, handler:@escaping (_ error: String?) -> Void) {
    
        var imageArray: [String] = []
        
        
    let components = NSURLComponents()
    components.scheme = Constants.Flickr.APIScheme
    components.host = Constants.Flickr.APIHost
    components.path = Constants.Flickr.APIPath
    components.queryItems = [NSURLQueryItem() as URLQueryItem]
    
    let queryitem1 = NSURLQueryItem(name: Constants.FlickrParameterKeys.Method, value: Constants.FlickrParameterValues.SearchMethod)
    let queryitem2 = NSURLQueryItem(name: Constants.FlickrParameterKeys.APIKey, value: Constants.FlickrParameterValues.APIKey)
        let queryitem3 = NSURLQueryItem(name: Constants.FlickrParameterKeys.BoundingBox, value: bboxString(latitude: latitude,longitude: logitude))
    let queryitem4 = NSURLQueryItem(name: Constants.FlickrParameterKeys.SafeSearch, value: Constants.FlickrParameterValues.UseSafeSearch)
    let queryitem5 = NSURLQueryItem(name: Constants.FlickrParameterKeys.Extras, value: Constants.FlickrParameterValues.MediumURL)
    let queryitem6 = NSURLQueryItem(name: Constants.FlickrParameterKeys.Format, value: Constants.FlickrParameterValues.ResponseFormat)
    let queryitem7 = NSURLQueryItem(name: Constants.FlickrParameterKeys.NoJSONCallback, value: Constants.FlickrParameterValues.DisableJSONCallback)
    
    components.queryItems!.append(queryitem1 as URLQueryItem)
    components.queryItems!.append(queryitem2 as URLQueryItem)
    components.queryItems!.append(queryitem3 as URLQueryItem)
    components.queryItems!.append(queryitem4 as URLQueryItem)
    components.queryItems!.append(queryitem5 as URLQueryItem)
    components.queryItems!.append(queryitem6 as URLQueryItem)
    components.queryItems!.append(queryitem7 as URLQueryItem)
    
    
    let url = components.url!
    let request = URLRequest(url: url)
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        func displayError(_ error: String) {
            print(error)
            handler("error")
        }
        if error == nil {
            if let data = data {
                
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                } catch {
                    displayError("Could not parse the data as JSON: '\(data)'")
                    handler("Could not parse the data as JSON: '\(data)'")
                    return
                }
                
                if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] {

                    for x in photoArray{
                        
                        imageArray.append((x[Constants.FlickrResponseKeys.MediumURL] as? String)!)
                        
                    }
                   Pin.shared.albumPicturesURL = imageArray
                   handler(nil)
                    
                }
                
            }
            
        }
        
    }
    
    task.resume()
}

    func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
       
            let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        
    }

}
