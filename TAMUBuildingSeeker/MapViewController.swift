//
//  MapViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 10/3/21.
//

import UIKit
import MapKit
import Vision
import CoreML
import ImageIO

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var takePictureButton: UIButton!
    
    let manager = CLLocationManager()
    
    let buildingCoordinates: [String: (CLLocationCoordinate2D)] = ["BSBW":CLLocationCoordinate2D(latitude: 30.61567,longitude: -96.33946), "PETR":CLLocationCoordinate2D(latitude: 30.6159816,longitude: -96.338583),"SCC":CLLocationCoordinate2D(latitude: 30.6158783,longitude: -96.3400321),"RDER":CLLocationCoordinate2D(latitude: 30.6128318,longitude: -96.3424932)]
    
    var selectedBuilding = ""
    
    let request = MKDirections.Request()
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: UpdatedV2ThirteenCampusBuildings().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    var classificationResult: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        takePictureButton.backgroundColor = #colorLiteral(red: 0.3058823529, green: 0.04705882353, blue: 0.03921568627, alpha: 1)
        
        mapView.mapType = .mutedStandard
        self.mapView.delegate = self
        
        manager.delegate = self
        manager.requestLocation()
        manager.startUpdatingLocation()
        
        let buildingMarker = MKPointAnnotation()
        switch(selectedBuilding) {
        case "Student Computing Center":
            buildingMarker.coordinate = buildingCoordinates["SCC"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["SCC"]!))
        case "Biological Sciences Building West":
            buildingMarker.coordinate = buildingCoordinates["BSBW"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["BSBW"]!))
        case "Peterson Building":
            buildingMarker.coordinate = buildingCoordinates["PETR"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["PETR"]!))
        case "Rudder Tower":
            buildingMarker.coordinate = buildingCoordinates["RDER"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["RDER"]!))
        default:
            break
        }
        
        buildingMarker.title = selectedBuilding
        mapView.addAnnotation(buildingMarker)
        
        mapView.showsUserLocation = true
        
        request.requestsAlternateRoutes = true
        request.transportType = .walking
    }
    
    
    // TODO: Request permission to use location (rather than have it set to true in Settings app by default) --> See info.plist if it's bugging out
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
            let directions = MKDirections(request: request)

            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }

                for route in unwrappedResponse.routes {
                    mapView.addOverlay(route.polyline)
                    mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch user's location: \(error.localizedDescription)")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                // unable to classify image
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
        
            if classifications.isEmpty {
                self.classificationResult = []
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(3)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                   return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.classificationResult = descriptions.map { classification in
                    let resultsData = classification.split(separator: " ")
                    let percentage = Int(resultsData[0].replacingOccurrences(of: "(0.", with: "").replacingOccurrences(of: ")", with: ""))!
                    return "\(self.renameResult(result: String(resultsData[1])))  \(percentage)%"
                }
                self.performSegue(withIdentifier: "mapToTable", sender: nil)
                print("DESCRIPTIONS: " + descriptions.description)
            }
        }
    }
    
    func renameResult(result: String) -> String {
        switch result {
        case "ANNEX_LIBR":
            return "Annex and West Evans Library"
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
            return "Heldenfelds"
        case "LAAH":
            return "Liberal Arts & Humanities Building"
        case "PAV":
            return "Pavillion"
        case "PETR":
            return "Peterson Building"
        case "RDER":
            return "Rudder Tower"
        case "SCC":
            return "Student Computing Center"
        default:
            return result
        }
    }
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        //resultLabel.text = "Classifying..."
        
        var orientation: CGImagePropertyOrientation = .down
        switch image.imageOrientation {
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
        
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(rawValue: orientation.rawValue)! ,options: [:])
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        var capturedImage = UIImage()
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            capturedImage = pickedImage
        }
        updateClassifications(for: capturedImage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ResultsTableViewController {
            vc.percentages = classificationResult
        }
    }

}
