//
//  Globals.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 12/29/21.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct UserData {
    static var group = ""
    static var groupCode = ""
    static var totalTimeElapsed = 0.0
    static var positions: [GeoPoint] = [] // coordinates of the user during study
    static var times: [Double] = [] // [Freedom from Terrorism Memorial identification time, EAB identification time, Bolton Hall identification time, finish/Rudder Plaza arrival time]
}

struct LandmarkData {
    // [Freedom from Terrorism Memorial, EABAB, Bolton Hall
    static var landmarkCoords: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 30.614078054580283 , longitude: -96.33837550518793), CLLocationCoordinate2D(latitude: 30.615614431420465 , longitude: -96.33748147740882)]
}
