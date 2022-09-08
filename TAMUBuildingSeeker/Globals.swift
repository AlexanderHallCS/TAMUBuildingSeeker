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
    static var numTimesBuildingRecognizerUsed = 0
    static var numTimesBuildingRecognizerFeatureSucceeded = 0
    static var numTimesDestinationPictureTaken = 0 // min 3, max 6 (unless user ends study early)
    static var numTimesDestinationWasRecognized = 0 // min 0, max 3
    static var totalTimeElapsed = 0.0
    static var coordinates: [GeoPoint] = [] // coordinates of the user
    static var coordinateTimestamps: [Double] = [] // timestamps associated with above coordinates
    static var coordinateDateTimes: [String] = [] // datetimes associated with above coordinates
    static var destinationTimes: [Double] = [] // [Freedom from Terrorism Memorial identification time, EAB identification time, Bolton Hall identification time]
    static var surveyStartTimes: [Double] = []
    static var surveyStopTimes: [Double] = []
    static var surveyResults: [NSString] = []
    static var successfulDestRecogTimes: [Double] = []
    static var failedDestRecogTimes: [Double] = []
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
        "Biological Sciences Building East":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61581386521865, longitude: -96.33928018374556), imageFileName: "BSBE"),
        "Bolton Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.616236201130842 , longitude: -96.34167587533827), imageFileName: "Bolton Hall"),
        "Biological Sciences Building West":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615614728833688, longitude: -96.33958205557924), imageFileName: "BSBW"),
        "Butler Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61480943011798, longitude: -96.33895545896416), imageFileName: "Butler Hall"),
        "Century Tree":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61588926299545, longitude: -96.34135357151021), imageFileName: "Century Tree"),
        "Cushing Memorial Library and Archives":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61636969676065, longitude: -96.33992320080623), imageFileName: "Cushing"),
        "EAB Courtyards":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615663168551777, longitude: -96.33724208204104), imageFileName: "Engineering Activity Courtyard"),
        "Engineering Activity Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615614431420465, longitude: -96.33748147740882), imageFileName: "EAB"),
        "Freedom from Terrorism Memorial":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.614078054580283 , longitude: -96.33837550518793), imageFileName: "Freedom From Terrorism Memorial"),
        "Harrington Education Center Office Tower":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.61655572979656, longitude: -96.340855271723), imageFileName: "Harrington"),
        "Hart Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.614329195904833, longitude: -96.34060915515406), imageFileName: "Hart Hall"),
        "Heldenfelds Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615085096152516, longitude: -96.33868414305762), imageFileName: "Heldenfelds"),
        "Nagle Hall":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.614939229647185, longitude: -96.34050217172262), imageFileName: "Nagle Hall"),
        "Pavilion":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.616860762501556, longitude: -96.33801557088246), imageFileName: "Pavilion"),
        "Peterson Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.616017974836765, longitude: -96.33852133754596), imageFileName: "Peterson"),
        "Psychology Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.614704696259263, longitude: -96.33985467193382), imageFileName: "psychology"),
        "Rudder Tower":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.612831762817343, longitude: -96.34028304263839), imageFileName: "Rudder"),
        "Student Computing Center":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.615911341535956, longitude: -96.33779557186001), imageFileName: "Student Computing"),
        "Shaping the Future Statue":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.616367359672434, longitude: -96.3412343951232), imageFileName: "Shaping the Future"),
        "Student Services Building":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.613970529551654, longitude: -96.34132947171938), imageFileName: "Student Services"),
        "Trigon":Landmark(coordinate: CLLocationCoordinate2D(latitude: 30.614346683415967, longitude: -96.33926316433066), imageFileName: "Military Sciences")]
}

extension UIView {
    func animateIn() {
        self.isUserInteractionEnabled = true
        self.isHidden = false
        self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.alpha = 0.0;
        for child in self.subviews {
            child.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            child.alpha = 0.0;
            child.isHidden = false
            child.isUserInteractionEnabled = true
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            for child in self.subviews {
                child.alpha = 1.0
                child.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        });
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.alpha = 0.0;
            for child in self.subviews {
                child.alpha = 1.0
                child.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }, completion:{ (doneAnimating : Bool) in
            if (doneAnimating)
            {
                self.isUserInteractionEnabled = false
                self.isHidden = true
                for child in self.subviews {
                    child.isHidden = true
                    child.isUserInteractionEnabled = false
                }
            }
        });
    }
}
