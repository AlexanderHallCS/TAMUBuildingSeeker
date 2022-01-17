//
//  MLModelManager.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 1/14/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class MLModelManager {
    
    public func downloadMLModelFile() -> (StorageDownloadTask, URL) {
        let storage = Storage.storage()
        let modelRef = storage.reference(forURL: "gs://tamu-building-seeker-6115e.appspot.com/CampusLandmarksModel.mlmodel")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent("model/CampusLandmarksModel.mlmodel")
        let downloadTask = modelRef.write(toFile: localURL) { (URL, error) -> Void in
            if (error != nil) {
                print("Uh-oh, an error occurred!")
                print(error)
            } else {
                print("Local file URL is returned")
                
            }
        }
        
        return (downloadTask, localURL)
    }
    
    public func renameResult(result: String) -> String {
        switch result {
        case "ANNEX_LIBR":
            return "Evans Library Annex"
        case "Biological Sciences Building East (BSBE) - Department of Biology":
            return "Biological Sciences Building East"
        case "BSBW":
            return "Biological Sciences Building West"
        case "BTLR":
            return "Butler Hall"
        case "EABAA":
            return "Engineering Activity Building A"
        case "EABAB":
            return "Engineering Activity Building B"
        case "EABAC":
            return "Engineering Activity Building C"
        case "HELD":
            return "Heldenfelds Hall"
        case "LAAH":
            return "Liberal Arts & Humanities Building"
        case "Military Sciences Building(Trigon)":
            return "Trigon"
        case "PAV":
            return "Pavilion"
        case "PETR":
            return "Peterson Building"
        case "RDER":
            return "Rudder Tower"
        case "SBISA":
            return "SBISA Dining Hall"
        case "SCC":
            return "Student Computing Center"
        case "Texas A_M Prospective Student Center - Aggieland":
            return "Koldus Building"
        default:
            return result
        }
    }
}
