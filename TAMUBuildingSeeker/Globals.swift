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
    // stored in database
    static var group = ""
    static var groupCode = ""
    static var numPicturesTaken = 0
    static var totalTimeElapsed = 0.0
    static var coordinates: [GeoPoint] = [] // coordinates of the user
    static var coordinateTimestamps: [Double] = [] // timestamps associated with above coordinates
    static var destinationTimes: [Double] = [] // [Freedom from Terrorism Memorial identification time, EAB identification time, Bolton Hall identification time]
    static var surveyStartTimes: [Double] = []
    static var surveyStopTimes: [Double] = []
    static var surveyResults: [NSString] = []
    // not stored in data
    // used to load in the Photo Bank
    static var picturesTaken: [UIImage] = []
}

struct LandmarkData {
    // [Freedom from Terrorism Memorial, EABAB, Bolton Hall]
    static var landmarkCoords: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 30.614078054580283 , longitude: -96.33837550518793), CLLocationCoordinate2D(latitude: 30.615614431420465 , longitude: -96.33748147740882), CLLocationCoordinate2D(latitude: 30.616236201130842 , longitude: -96.34167587533827)]
    static var landmarkTitles = ["Freedom from Terrorism Memorial", "Engineering Activity Building", "Bolton Hall"]
}
