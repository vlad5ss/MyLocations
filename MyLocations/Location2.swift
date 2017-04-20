//
//  Location2.swift
//  
//
//  Created by mac on 4/19/17.
//
//

import Foundation
import CoreLocation

class Location2 {
    static var sharedInstance = Location()
    private init(){}
    
    var latitude:Double!
    var longitude: Double!
}
