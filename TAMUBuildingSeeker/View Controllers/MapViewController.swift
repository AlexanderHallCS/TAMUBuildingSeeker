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
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var takePictureButton: UIButton!
    
    var previewImageView: UIImageView!
    var capturedImage: UIImage?
    
    let manager = CLLocationManager()
    
    let request = MKDirections.Request()
    
    var destinationIndex = 0 // specifies what the current destination is
    var shouldShowNearbyNotification = [false, false, false] // only show nearby notif. once per dest
    var mapAnnotations: [MKPointAnnotation] = []
    var mapRegions: [CLCircularRegion] = []
    
    var coordinates: [GeoPoint] = []
    
    var modelDownloadTask: StorageDownloadTask?
    var modelDownloadUrl = URL(string: "")
    
    //var timer: Timer? = nil
    //var currentTime = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mlModelFileData = downloadMLModelFile()
        modelDownloadTask = mlModelFileData.0
        modelDownloadUrl = mlModelFileData.1
        
        mapView.delegate = self
        manager.delegate = self
        
        mapView.mapType = .mutedStandard
        manager.requestAlwaysAuthorization()
        //manager.requestLocation()
        //request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        
        
        //let coordinates = [CLLocationCoordinate2D(latitude: 30.6132970, longitude: -96.3409940), CLLocationCoordinate2D(latitude: 30.614635239430765, longitude: -96.33918907598739),CLLocationCoordinate2D(latitude: 30.614321299604413, longitude: -96.33882430116313),CLLocationCoordinate2D(latitude: 30.615392337642014, longitude: -96.33720420138674),CLLocationCoordinate2D(latitude: 30.614810655204593, longitude: -96.33809472574791),CLLocationCoordinate2D(latitude: 30.616177215386124, longitude: -96.33937144185),CLLocationCoordinate2D(latitude: 30.615743252104618, longitude: -96.34011174809874),CLLocationCoordinate2D(latitude: 30.61573401860394, longitude: -96.3400902902438),CLLocationCoordinate2D(latitude: 30.616288023445797, longitude: -96.34070184020244),CLLocationCoordinate2D(latitude: 30.616204922997778, longitude: -96.3409378787194),CLLocationCoordinate2D(latitude: 30.61633419024504, longitude: -96.34109881435528),CLLocationCoordinate2D(latitude: 30.61620492238295, longitude: -96.3412812072978),CLLocationCoordinate2D(latitude: 30.616297255938285, longitude: -96.34137776902726),CLLocationCoordinate2D(latitude: 30.615235418417686, longitude: -96.34109881128131),CLLocationCoordinate2D(latitude: 30.614939950952216, longitude: -96.34083058876958),CLLocationCoordinate2D(latitude: 30.614302848825638, longitude: -96.34093787685902),CLLocationCoordinate2D(latitude: 30.613998147779352, longitude: -96.34086277522175),CLLocationCoordinate2D(latitude: 30.613665746287364, longitude: -96.34105589232338),CLLocationCoordinate2D(latitude: 30.61347184557696, longitude: -96.34091641869196),CLLocationCoordinate2D(latitude: 30.6132970, longitude: -96.3409940)]
        
       // let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        //mapView.addOverlay(polyline)
        
        
//        var regionRect = polyline.boundingMapRect
//
//
//                var wPadding = regionRect.size.width * 0.25
//                var hPadding = regionRect.size.height * 0.25
//
//                //Add padding to the region
//                regionRect.size.width += wPadding
//                regionRect.size.height += hPadding
//
//                //Center the region on the line
//                regionRect.origin.x -= wPadding / 2
//                regionRect.origin.y -= hPadding / 2

        //mapView.setRegion(MKCoordinateRegion(regionRect), animated: true)
        
//        let startEndMarker = MKPointAnnotation()
//        startEndMarker.coordinate = CLLocationCoordinate2D(latitude: 30.6132970, longitude: -96.3409940)
//        startEndMarker.title = "Start/End"
        //mapView.addAnnotation(startEndMarker)
        
        
        //let buildingMarker = MKPointAnnotation()
//        switch(selectedBuilding) {
//        case "Evans Library Annex":
//            buildingMarker.coordinate = buildingCoordinates["ANNEX_LIBR"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["ANNEX_LIBR"]!))
//        case "Butler Hall":
//            buildingMarker.coordinate = buildingCoordinates["BTLR"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["BTLR"]!))
//        case "Biological Sciences Building West":
//            buildingMarker.coordinate = buildingCoordinates["BSBW"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["BSBW"]!))
//        case "Engineering Activity Building A":
//            buildingMarker.coordinate = buildingCoordinates["EABAA"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["EABAA"]!))
//        case "Engineering Activity Building B":
//            buildingMarker.coordinate = buildingCoordinates["EABAB"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["EABAB"]!))
//        case "Engineering Activity Building C":
//            buildingMarker.coordinate = buildingCoordinates["EABAC"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["EABAC"]!))
//        case "Heldenfelds":
//            buildingMarker.coordinate = buildingCoordinates["HELD"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["HELD"]!))
//        case "Liberal Arts & Humanities Building":
//            buildingMarker.coordinate = buildingCoordinates["LAAH"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["LAAH"]!))
//        case "Pavilion":
//            buildingMarker.coordinate = buildingCoordinates["PAV"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["PAV"]!))
//        case "Peterson Building":
//            buildingMarker.coordinate = buildingCoordinates["PETR"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["PETR"]!))
//        case "Rudder Tower":
//            buildingMarker.coordinate = buildingCoordinates["RDER"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["RDER"]!))
//        case "SBISA":
//            buildingMarker.coordinate = buildingCoordinates["SBISA"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["SBISA"]!))
//        case "Student Computing Center":
//            buildingMarker.coordinate = buildingCoordinates["SCC"]!
//            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["SCC"]!))
//        default:
//            break
//        }
        
        //buildingMarker.title = selectedBuilding
        //mapView.addAnnotation(buildingMarker)
        
       
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            prepareDestination(title: "Start!", message: "Head to the Freedom from Terrorism Memorial")
        case .notDetermined:
            break
        default:
            let alert = UIAlertController(title: "Error", message: "Please enable location tracking in the Settings app!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) {(action: UIAlertAction) -> Void in
                alert.removeFromParent()
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        var alertStyle = UIAlertController.Style.actionSheet
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            alertStyle = UIAlertController.Style.alert
        }
        
        let photoSourcePicker = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        var capturedImage = UIImage()
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            capturedImage = pickedImage
        }
        
        updateClassifications(for: capturedImage)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                //if(!didGetFirstLocation) {
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
                    let directions = MKDirections(request: request)

                    directions.calculate { [weak self] response, error in
                        guard let unwrappedResponse = response else { return }

                        for route in unwrappedResponse.routes {
                            self!.mapView.addOverlay(route.polyline)
                            self!.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        }
                    }
//                    didGetFirstLocation = true
//                }
                coordinates.append(GeoPoint(latitude: locations.first!.coordinate.latitude, longitude: locations.first!.coordinate.longitude))
            }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch user's location: \(error.localizedDescription)")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 7
        return renderer
    }
    
    
    
    private func prepareDestination(title: String, message: String) {
        let destinationMarker = MKPointAnnotation()
        destinationMarker.coordinate = LandmarkData.landmarkCoords[destinationIndex]
        destinationMarker.title = LandmarkData.landmarkTitles[destinationIndex]
        mapAnnotations.append(destinationMarker)
        mapView.addAnnotation(destinationMarker)
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: LandmarkData.landmarkCoords[destinationIndex]))
        monitorRegionAtLocation(center: LandmarkData.landmarkCoords[destinationIndex])
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) {(action: UIAlertAction) -> Void in
            alert.removeFromParent()
        })
        present(alert, animated: true, completion: nil)
    }
    
    private func monitorRegionAtLocation(center: CLLocationCoordinate2D) {
        // Make sure the devices supports region monitoring.
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            // Register the region.
            let maxDistance: CLLocationDistance = 60 // 60 meters radius from landmark
            let region = CLCircularRegion(center: center,
                                          radius: maxDistance, identifier: "")
            region.notifyOnEntry = true
            region.notifyOnExit = false
            mapRegions.append(region)
            
            manager.startMonitoring(for: region)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        mapRegions[destinationIndex].notifyOnEntry = false
        // TODO: nearby notifications if correct group
        // TODO: create button and uiimageview (or make unhidden)
    }
    
//    @objc func confirmButtonPressed() {
//        takePictureButton.isUserInteractionEnabled = true
//        takePictureButton.isHidden = false
//        //updateClassifications(for: capturedImage!)
//        for view in self.view.subviews {
//            if(view.tag == 101) {
//                view.removeFromSuperview()
//            }
//        }
//    }
    
//    func renameResult(result: String) -> String {
//        switch result {
//        case "ANNEX_LIBR":
//            return "Evans Library Annex"
//        case "BSBW":
//            return "Biological Sciences Building West"
//        case "BTLR":
//            return "Butler Hall"
//        case "EABAA":
//            return "Engineering Activity Building A"
//        case "EABAB":
//            return "Engineering Activity Building B"
//        case "EABAC":
//            return "Engineering Activity Building C"
//        case "HELD":
//            return "Heldenfelds Hall"
//        case "LAAH":
//            return "Liberal Arts & Humanities Building"
//        case "PAV":
//            return "Pavilion"
//        case "PETR":
//            return "Peterson Building"
//        case "RDER":
//            return "Rudder Tower"
//        case "SBISA":
//            return "SBISA Dining Hall"
//        case "SCC":
//            return "Student Computing Center"
//        default:
//            return result
//        }
//    }
    
    func downloadMLModelFile() -> (StorageDownloadTask, URL) {
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
    
    // TODO: DISPLAY NOTIFICATION IF RESULT IS SUCCESSFUL OR NOT OR NEEDS ANOTHER PICTURE
    func processClassifications(for request: VNRequest, error: Error?) -> Dictionary<String, Double> {
        
        guard let results = request.results else {
            fatalError("Could not classify image")
        }
    
        let classifications = results as! [VNClassificationObservation]
    
        let topClassifications = classifications.prefix(3) // get top 3 results
    
        let names = topClassifications.map { classification in
            return classification.identifier
        }
    
        let resultPercentages = topClassifications.map { classification in
            return Double(String(format: "%.2f", classification.confidence * 100))!
        }
        
        return Dictionary(uniqueKeysWithValues: zip(names, resultPercentages))
    }
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        
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
            
            self.modelDownloadTask!.observe(.success) { snapshot in
                // Download completed successfully
                do {
                    let compiledModelURL = try MLModel.compileModel(at: self.modelDownloadUrl!)
                    print("test1")
                    let mlModelObject = try MLModel(contentsOf: compiledModelURL)
                    print("test2")
                    let modelTest = try VNCoreMLModel(for: mlModelObject)
                    print("WOOO BABY")
                    let request = VNCoreMLRequest(model: modelTest, completionHandler: { [weak self] request, error in
                        self?.processClassifications(for: request, error: error)
                    })
                    request.imageCropAndScaleOption = .centerCrop
                    do {
                        try handler.perform([request])
                        print("WE REQUESTING!")
                    } catch {
                        print("Failed to perform classification.\n\(error.localizedDescription)")
                    }
                } catch {
                    print("error!!")
                }
            }
        }
    }

}
