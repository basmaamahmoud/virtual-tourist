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

        let queryItemArray = [queryitem1, queryitem2,queryitem3, queryitem4, queryitem5, queryitem6, queryitem7]
        
        queryItemArray.map { components.queryItems?.append($0 as URLQueryItem) }
              
        let url = components.url!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil{
                handler("Connection Error")
            }
            if let data = data {
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                } catch {
                    handler("Cant download Pictures")
                    return
                }
                guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else{
                    return
                }
                if photoArray.count == 0 {
                    handler("There is no Pictures")
                    return
                    
                }else if photoArray.count < 30{
                    photoArray.map { imageArray.append(($0[Constants.FlickrResponseKeys.MediumURL] as? String)!) }
                    Pin.shared.albumPicturesURL = imageArray
                    handler(nil)
                }else{
                    let pickImages = photoArray[randomPick: 10]
                    pickImages.map { imageArray.append(($0[Constants.FlickrResponseKeys.MediumURL] as? String)!) }
                    Pin.shared.albumPicturesURL = imageArray
                    handler(nil)
                }
            }
        }
        task.resume()
    }
}
extension Array {
    /// Picks `n` random elements (partial Fisher-Yates shuffle approach)
    subscript (randomPick n: Int) -> [Element] {
        var copy = self
        for i in stride(from: count - 1, to: count - n - 1, by: -1) {
            copy.swapAt(i, Int(arc4random_uniform(UInt32(i + 1))))
        }
        return Array(copy.suffix(n))
    }
}
extension FlickerComponentsCoord {
    func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        
    }
}
