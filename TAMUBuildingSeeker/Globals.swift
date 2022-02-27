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

struct DestinationData {
    // Coords for [Freedom from Terrorism Memorial, EABAB, Bolton Hall]
    static var destCoords: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 30.614078054580283 , longitude: -96.33837550518793), CLLocationCoordinate2D(latitude: 30.615614431420465, longitude: -96.33748147740882), CLLocationCoordinate2D(latitude: 30.616236201130842 , longitude: -96.34167587533827)]
    static var destTitles = ["Freedom from Terrorism Memorial", "Engineering Activity Building", "Bolton Hall"]
}

struct Landmarks {
    // Defines landmark by its coordinate location and image file name used in pop-up
    struct Landmark {
        var coordinate: CLLocationCoordinate2D
        var imageFileName: String
    }
    
    static var landmarkData: [String : Landmark] = [
        "Academic Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615776800003946, longitude: -96.3407510000051), imageFileName: "Academic Building"),
        "Evans Library Annex":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61650444288934, longitude: -96.33854863538343), imageFileName: "EvansLibraryAnnex"),
        "Biological Sciences Building East":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61581386521865, longitude: -96.33928018374556), imageFileName: "BSBE"),
        "Bolton Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.616236201130842 , longitude: -96.34167587533827), imageFileName: "Bolton Hall"),
        "Bonfire Memorial":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.62272646722342, longitude: -96.33516544390638), imageFileName: "Bonfire Memorial"),
        "Biological Sciences Building West":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615614728833688, longitude: -96.33958205557924), imageFileName: "BSBW"),
        "Butler Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61480943011798, longitude: -96.33895545896416), imageFileName: "Butler Hall"),
        "Century Tree":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61588926299545, longitude: -96.34135357151021), imageFileName: "Century Tree"),
        "Cushing Memorial Library and Archives":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61636969676065, longitude: -96.33992320080623), imageFileName: "Cushing"),
        "EAB Courtyards":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615663168551777, longitude: -96.33724208204104), imageFileName: "Engineering Activity Courtyard"),
        "Engineering Activity Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615614431420465, longitude: -96.33748147740882), imageFileName: "EAB"),
        "Freedom from Terrorism Memorial":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.614078054580283 , longitude: -96.33837550518793), imageFileName: "Freedom From Terrorism Memorial"),
        "H2O Fountains":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.617635864096762, longitude: -96.34066682988757), imageFileName: "H20 Fountains"),
        "Harrington Education Center Office Tower":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61655572979656, longitude: -96.340855271723), imageFileName: "Harrington"),
        "Hart Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.614329195904833, longitude: -96.34060915515406), imageFileName: "Hart Hall"),
        "Heldenfelds Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615085096152516, longitude: -96.33868414305762), imageFileName: "Heldenfelds"),
        "Jack K. Williams Administration Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.618718130006023, longitude: -96.33643037172173), imageFileName: "Administration Bldg"),
        "Kyle Field":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.609908330659565, longitude: -96.34036227109038), imageFileName: "Kyle Field"),
        "Liberal Arts & Humanities Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61671302602539, longitude: -96.33745383586927), imageFileName: "LIBERAL ARTS"),
        "Michael T. Halbouty Geosciences Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.619134329246926, longitude: -96.34092862884681), imageFileName: "Halbouty"),
        "Nagle Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.614939229647185, longitude: -96.34050217172262), imageFileName: "Nagle Hall"),
        "Pavilion":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.616860762501556, longitude: -96.33801557088246), imageFileName: "Pavilion"),
        "Peterson Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.616017974836765, longitude: -96.33852133754596), imageFileName: "Peterson"),
        "Psychology Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.614704696259263, longitude: -96.33985467193382), imageFileName: "psychology"),
        "Rudder Tower":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.612831762817343, longitude: -96.34028304263839), imageFileName: "Rudder"),
        "Sanders Corps of Cadets Center":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61205479492118, longitude: -96.33748527256537), imageFileName: "Sanders Corps Center"),
        "SBISA Dining Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.616982380857866, longitude: -96.34355180388643), imageFileName: "SBISA"),
        "Student Computing Center":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615911341535956, longitude: -96.33779557186001), imageFileName: "Student Computing"),
        "Scoates Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61851334294704, longitude: -96.33834902425852), imageFileName: "Scoates Hall"),
        "Shaping the Future Statue":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.616367359672434, longitude: -96.3412343951232), imageFileName: "Shaping the Future"),
        "Student Services Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.613970529551654, longitude: -96.34132947171938), imageFileName: "Student Services"),
        "Trigon":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.614346683415967, longitude: -96.33926316433066), imageFileName: "Military Sciences"),
        "Koldus Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.612171028742992, longitude: -96.33966660122215), imageFileName: "Koldus"),
        "YMCA Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615100263370817, longitude: -96.34235182988616), imageFileName: "YMCA")]
}
