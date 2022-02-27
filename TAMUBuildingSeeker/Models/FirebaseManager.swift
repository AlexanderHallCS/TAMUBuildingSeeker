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
                "destinationTimes":UserData.destinationTimes,
                "surveyStartTimes":UserData.surveyStartTimes,
                "surveyStopTimes":UserData.surveyStopTimes,
                "surveyResults":UserData.surveyResults,
                "numPicturesTaken":UserData.numPicturesTaken
                    ]) { error in
                if error != nil {
                    print("Error saving user data")
                }
            }
        })
    }
    
    // creates an anonymous user and stores study data
    // called after final destination has a correct picture taken
    public func saveData() {
        db.collection("user").addDocument(data: [
            "group":UserData.group,
            "groupCode":UserData.groupCode,
            "totalTimeElapsed":UserData.totalTimeElapsed,
            "coordinates":UserData.coordinates,
            "coordinateTimestamps":UserData.coordinateTimestamps,
            "destinationTimes":UserData.destinationTimes,
            "surveyStartTimes":UserData.surveyStartTimes,
            "surveyStopTimes":UserData.surveyStopTimes,
            "surveyResults":UserData.surveyResults,
            "numPicturesTaken":UserData.numPicturesTaken
                ]) { error in
            if error != nil {
                print("Error saving user data")
            }
        }
    }
    
    public func saveCoordsAndTimes() {
        db.collection("user").document(UserData.groupCode).updateData([
            "coordinates":UserData.coordinates,
            "coordinateTimestamps":UserData.coordinateTimestamps
        ]) { error in
            if error != nil {
                print("Error saving user data")
            }
        }
    }
    
    public func saveSurveyResults() {
        db.collection("user").document(UserData.groupCode).updateData([
            "surveyResults":UserData.surveyResults,
            "surveyStartTimes":UserData.surveyStartTimes,
            "surveyStopTimes":UserData.surveyStopTimes
        ]) { error in
            if error != nil {
                print("Error saving user data")
            }
        }
    }
    
    public func saveDestinationTimes() {
        db.collection("user").document(UserData.groupCode).updateData([
            "destinationTimes":UserData.destinationTimes
        ]) { error in
            if error != nil {
                print("Error saving user data")
            }
        }
    }
    
    public func saveNumPicturesTaken() {
        db.collection("user").document(UserData.groupCode).updateData([
            "numPicturesTaken":UserData.numPicturesTaken
        ]) { error in
            if error != nil {
                print("Error saving user data")
            }
        }
    }
    
    public func saveTotalTimeElapsed() {
        db.collection("user").document(UserData.groupCode).updateData([
            "totalTimeElapsed":UserData.totalTimeElapsed
        ]) { error in
            if error != nil {
                print("Error saving user data")
            }
        }
    }
    
}
