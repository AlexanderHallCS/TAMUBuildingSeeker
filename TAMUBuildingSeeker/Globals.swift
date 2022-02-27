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
    static var destCoords: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 30.614078054580283 , longitude: -96.33837550518793), CLLocationCoordinate2D(latitude: 30.615614431420465, longitude: -96.33748147740882), CLLocationCoordinate2D(latitude: 30.616236201130842 , longitude: -96.34167587533827)]
    static var destTitles = ["Freedom from Terrorism Memorial", "Engineering Activity Building", "Bolton Hall"]
    
    static var landmarkCoords: [String : CLLocationCoordinate2D] = ["Academic Building":CLLocationCoordinate2D(latitude: 30.615776800003946, longitude: -96.3407510000051),"Evans Library Annex":CLLocationCoordinate2D(latitude: 30.61650444288934, longitude: -96.33854863538343),"Biological Sciences Building East":CLLocationCoordinate2D(latitude: 30.61581386521865, longitude: -96.33928018374556), "Bolton Hall":CLLocationCoordinate2D(latitude: 30.616236201130842 , longitude: -96.34167587533827),"Bonfire Memorial":CLLocationCoordinate2D(latitude: 30.62272646722342, longitude: -96.33516544390638),"Biological Sciences Building West":CLLocationCoordinate2D(latitude: 30.615614728833688, longitude: -96.33958205557924), "Butler Hall":CLLocationCoordinate2D(latitude: 30.61480943011798, longitude: -96.33895545896416), "Century Tree":CLLocationCoordinate2D(latitude: 30.61588926299545, longitude: -96.34135357151021), "Cushing Memorial Library and Archives":CLLocationCoordinate2D(latitude: 30.61636969676065, longitude: -96.33992320080623),"EAB Courtyards":CLLocationCoordinate2D(latitude: 30.615663168551777, longitude: -96.33724208204104),"Engineering Activity Building":CLLocationCoordinate2D(latitude: 30.615614431420465, longitude: -96.33748147740882),"Freedom from Terrorism Memorial":CLLocationCoordinate2D(latitude: 30.614078054580283 , longitude: -96.33837550518793),"H2O Fountains":CLLocationCoordinate2D(latitude: 30.617635864096762, longitude: -96.34066682988757),"Harrington Education Center Office Tower":CLLocationCoordinate2D(latitude: 30.61655572979656, longitude: -96.340855271723),"Hart Hall":CLLocationCoordinate2D(latitude: 30.614329195904833, longitude: -96.34060915515406),"Heldenfelds Hall":CLLocationCoordinate2D(latitude: 30.615085096152516, longitude: -96.33868414305762),"Jack K. Williams Administration Building":CLLocationCoordinate2D(latitude: 30.618718130006023, longitude: -96.33643037172173),"Kyle Field":CLLocationCoordinate2D(latitude: 30.609908330659565, longitude: -96.34036227109038),"Liberal Arts & Humanities Building":CLLocationCoordinate2D(latitude: 30.61671302602539, longitude: -96.33745383586927),"Michael T. Halbouty Geosciences Building":CLLocationCoordinate2D(latitude: 30.619134329246926, longitude: -96.34092862884681),"Nagle Hall":CLLocationCoordinate2D(latitude: 30.614939229647185, longitude: -96.34050217172262),"Pavilion":CLLocationCoordinate2D(latitude: 30.616860762501556, longitude: -96.33801557088246),"Peterson Building":CLLocationCoordinate2D(latitude: 30.616017974836765, longitude: -96.33852133754596),"Psychology Building":CLLocationCoordinate2D(latitude: 30.614704696259263, longitude: -96.33985467193382),"Rudder Tower":CLLocationCoordinate2D(latitude: 30.612831762817343, longitude: -96.34028304263839),"Sanders Corps of Cadets Center":CLLocationCoordinate2D(latitude: 30.61205479492118, longitude: -96.33748527256537),"SBISA Dining Hall":CLLocationCoordinate2D(latitude: 30.616982380857866, longitude: -96.34355180388643),"Student Computing Center":CLLocationCoordinate2D(latitude: 30.615911341535956, longitude: -96.33779557186001),"Scoates Hall":CLLocationCoordinate2D(latitude: 30.61851334294704, longitude: -96.33834902425852),"Shaping the Future Statue":CLLocationCoordinate2D(latitude: 30.616367359672434, longitude: -96.3412343951232),"Student Services Building":CLLocationCoordinate2D(latitude: 30.613970529551654, longitude: -96.34132947171938),"Koldus Building":CLLocationCoordinate2D(latitude: 30.612171028742992, longitude: -96.33966660122215),"YMCA Building":CLLocationCoordinate2D(latitude: 30.615100263370817, longitude: -96.34235182988616)]
}
