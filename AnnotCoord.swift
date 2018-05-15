//
//  ImagesUrls.swift
//  Virtual Tourist
//
//  Created by Basma Ahmed Mohamed Mahmoud on 4/6/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import Foundation

class AnnotCoord {
    
    /// The annotation coordinate
     var latitude: Double
     var longitude: Double
    
    
    /// The images contained by the annotation coordinate
    var annotation: [ImageUrls] = []
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        
        annotation = []
    }
}
extension AnnotCoord{
    func addAlbumPictures(text: String){
        annotation.append(ImageUrls(imageUrltext: text))
    }
}
