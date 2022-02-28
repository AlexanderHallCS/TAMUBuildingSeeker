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
import CoreLocation
import CoreML
import Vision

class MLModelManager {
    
    public func downloadMLModelFile() -> (StorageDownloadTask, URL) {
        let storage = Storage.storage()
        let modelRef = storage.reference(forURL: "gs://tamu-building-seeker-6115e.appspot.com/CampusLandmarksModel.mlmodel")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent("model/CampusLandmarksModel.mlmodel")
        let downloadTask = modelRef.write(toFile: localURL) { (URL, error) -> Void in
            if (error != nil) {
                print("Uh-oh, an error occurred!")
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
            return "Engineering Activity Building"
        case "EABAB":
            return "Engineering Activity Building"
        case "EABAC":
            return "Engineering Activity Building"
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
    
    // Crop original image into 9 equal segments
    // Perform ML image classification analysis on each segment
    // Return three most prevalent top percentage buildings( >= 0.5 accuracy) from all segments
    public func extractThreeByThreeCroppingTopResults(image: UIImage, modelDownloadUrl: URL) -> [String] {
        
        // stores name and frequency
        var topAllSlicesResults = [String : Int]()
        
        let imageSlices = generateThreeByThreeImageGridSlices(image: image);
        
        for imageSlice in imageSlices {
            var orientation: CGImagePropertyOrientation = .down
            switch imageSlice.imageOrientation {
            case .up:
                orientation = .up
            case .right:
                orientation = .right
            case .down:
                orientation = .down
            case .left:
                orientation = .left
            default:
                orientation = .down
            }
            
            guard let ciImage = CIImage(image: imageSlice) else { fatalError("Unable to create \(CIImage.self) from \(imageSlice).") }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(rawValue: orientation.rawValue)! ,options: [:])
                do {
                    let compiledModelURL = try MLModel.compileModel(at: modelDownloadUrl)
                    let mlModelObject = try MLModel(contentsOf: compiledModelURL)
                    let modelAsVNCoreModel = try VNCoreMLModel(for: mlModelObject)
                    let request = VNCoreMLRequest(model: modelAsVNCoreModel, completionHandler: { [weak self] request, error in
                        let topSliceResults = self!.getImageSegmentTopClassifications(for: request, error: error)
                        for result in topSliceResults {
                            if(topAllSlicesResults.keys.contains(result)) {
                                topAllSlicesResults[result]! += 1
                            } else {
                                topAllSlicesResults[result] = 1
                            }
                        }
                    })
                    request.imageCropAndScaleOption = .centerCrop
                    do {
                        try handler.perform([request])
                    } catch {
                        print("Failed to perform classification.\n\(error.localizedDescription)")
                    }
                } catch {
                    print("error!")
                }
            }
        }
        
        
        // sort top slice results in order of most prevalent first and return top 3
        return (topAllSlicesResults.sorted { $0.value > $1.value }.prefix(3)).map{elem in return elem.key}
    }
    
    // Retrieves all images with 0.5/1.00 accuracy or above
    private func getImageSegmentTopClassifications(for request: VNRequest, error: Error?) -> [String] {
        guard let results = request.results else {
            fatalError("Could not classify image")
        }
    
        // get all classification results whose confidence is greater than 0.01/1.00
        let classifications = (results as! [VNClassificationObservation]).filter { classification in
            return classification.confidence >= 0.5
        }
        
        let names = classifications.map { classification in
            return renameResult(result: classification.identifier)
        }
        
        return names
    }
    
    // Credit: Rob Ryan on stackoverflow.com, https://stackoverflow.com/a/43010051/10605555
    // Splits UIImage into grid of 3x3 UIImages
    private func generateThreeByThreeImageGridSlices(image: UIImage) -> [UIImage] {
        let numRowsCols = 3
        
        let width: CGFloat
        let height: CGFloat

        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            width = image.size.height
            height = image.size.width
        default:
            width = image.size.width
            height = image.size.height
        }

        let tileWidth = Int(width / CGFloat(numRowsCols))
        let tileHeight = Int(height / CGFloat(numRowsCols))

        let scale = Int(image.scale)
        var images = [UIImage]()

        let cgImage = image.cgImage!

        var adjustedHeight = tileHeight

        var y = 0
        for row in 0 ..< numRowsCols {
            if row == (numRowsCols - 1) {
                adjustedHeight = Int(height) - y
            }
            var adjustedWidth = tileWidth
            var x = 0
            for column in 0 ..< numRowsCols {
                if column == (numRowsCols - 1) {
                    adjustedWidth = Int(width) - x
                }
                let origin = CGPoint(x: x * scale, y: y * scale)
                let size = CGSize(width: adjustedWidth * scale, height: adjustedHeight * scale)
                let tileCgImage = cgImage.cropping(to: CGRect(origin: origin, size: size))!
                images.append(UIImage(cgImage: tileCgImage, scale: image.scale, orientation: image.imageOrientation))
                x += tileWidth
            }
            y += tileHeight
        }
        return images
    }
    
    // Removes ML model results of buildings > 60 meters from current location
    public func filterOutDistantBuildings(results: [String], currLoc: CLLocationCoordinate2D) -> [String] {
        return results.filter{ CLLocation(latitude: Landmarks.landmarkData[$0]!.coordinate.latitude, longitude: Landmarks.landmarkData[$0]!.coordinate.longitude).distance(from: CLLocation(latitude: currLoc.latitude, longitude: currLoc.longitude)) < 60 }
    }
}
