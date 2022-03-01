//
//  FirebaseManager.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 2/13/22.
//

import Foundation
import Firebase
import FirebaseCore

class FirebaseManager {
    
    var userRef = db.collection("user").document(UserData.groupCode)
    
    public func signInAnonymously() {
        Auth.auth().signInAnonymously(completion: { authResult, error in
            guard let _ = authResult?.user else {
                return
            }
            
            // create document in DB with empty/basic fields
            db.collection("user").document(UserData.groupCode).setData([
                "group":UserData.group,
                "groupCode":UserData.groupCode,
                "totalTimeElapsed":UserData.totalTimeElapsed,
                "coordinates":UserData.coordinates,
                "coordinateTimestamps":UserData.coordinateTimestamps,
                "coordinateDateTimes":UserData.coordinateDateTimes,
                "destinationTimes":UserData.destinationTimes,
                "surveyStartTimes":UserData.surveyStartTimes,
                "surveyStopTimes":UserData.surveyStopTimes,
                "surveyResults":UserData.surveyResults,
                "successfulRecogTimes":UserData.successfulRecogTimes,
                "failedRecogTimes":UserData.failedRecogTimes,
                "numPicturesTaken":UserData.numPicturesTaken,
                "numTimesBuildingRecognizerUsed":UserData.numTimesBuildingRecognizerUsed,
                "numTimesDestinationPictureTaken":UserData.numTimesDestinationPictureTaken,
                "numTimesDestinationWasRecognized":UserData.numTimesDestinationWasRecognized
                    ]) { error in
                if error != nil {
                    print("Error saving user data")
                }
            }
        })
    }
    
    // creates an anonymous user and stores study data
    // called every 10 seconds when participant uses app (on maps if available, otherwise on Group VC)
    public func saveData() {
        db.collection("user").document(UserData.groupCode).updateData([
            "group":UserData.group,
            "groupCode":UserData.groupCode,
            "totalTimeElapsed":UserData.totalTimeElapsed,
            "coordinates":UserData.coordinates,
            "coordinateTimestamps":UserData.coordinateTimestamps,
            "coordinateDateTimes":UserData.coordinateDateTimes,
            "destinationTimes":UserData.destinationTimes,
            "surveyStartTimes":UserData.surveyStartTimes,
            "surveyStopTimes":UserData.surveyStopTimes,
            "surveyResults":UserData.surveyResults,
            "successfulRecogTimes":UserData.successfulRecogTimes,
            "failedRecogTimes":UserData.failedRecogTimes,
            "numPicturesTaken":UserData.numPicturesTaken,
            "numTimesBuildingRecognizerUsed":UserData.numTimesBuildingRecognizerUsed,
            "numTimesDestinationPictureTaken":UserData.numTimesDestinationPictureTaken,
            "numTimesDestinationWasRecognized":UserData.numTimesDestinationWasRecognized
                ]) { error in
            if error != nil {
                print("Error saving user data")
            }
        }
    }
    
    // called after each survey is completed
    public func saveSurveyResults() {
        db.collection("user").document(UserData.groupCode).updateData([
            "surveyStartTimes":UserData.surveyStartTimes,
            "surveyStopTimes":UserData.surveyStopTimes,
            "surveyResults":UserData.surveyResults
        ]) { error in
            if error != nil {
                print("Error saving user data")
            }
        }
    }
    
}
