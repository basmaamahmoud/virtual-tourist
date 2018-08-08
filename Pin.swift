//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Basma Ahmed Mohamed Mahmoud on 4/3/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import Foundation

class Pin {
    var albumPicturesURL: [String] = []
    var imageUrl: [String]? = nil
    
    //Return the singleton instance of Storage
    class var shared: Pin {
        struct Static {
            static let instance: Pin = Pin()
        }
        return Static.instance
    }
}
