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
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var takePictureButton: UIButton!
    @IBOutlet var takePhotoActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var foundLandmarkButton: UIButton!
    @IBOutlet var foundLandmarkActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var nearbyNotifImageView: UIImageView!
    @IBOutlet var nearbyTakePictureButton: UIButton!
    
    var previewImageView: UIImageView!
    var capturedImage: UIImage?
    
    let manager = CLLocationManager()
    
    let request = MKDirections.Request()
    
    var shouldUpdateMapRect = false
    
    var destinationIndex = 0 // specifies what the current destination is
    var shouldShowNearbyNotification = [false, false, false] // only show nearby notif. once per dest
    var mapAnnotations: [MKPointAnnotation] = []
    var mapRegions: [CLCircularRegion] = []
    
    var coordinates: [GeoPoint] = []
    
    let modelManager = MLModelManager()
    
    var modelDownloadTask: StorageDownloadTask?
    var modelDownloadUrl = URL(string: "")
    
    //var timer: Timer? = nil
    //var currentTime = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("called!")
        let mlModelFileData = modelManager.downloadMLModelFile()
        modelDownloadTask = mlModelFileData.0
        modelDownloadUrl = mlModelFileData.1
        
        mapView.delegate = self
        manager.delegate = self
        
        mapView.mapType = .mutedStandard
        
        manager.requestAlwaysAuthorization()
        
        request.transportType = .walking
        
        foundLandmarkActivityIndicator.startAnimating()
        foundLandmarkButton.isEnabled = false
        
        // no photo taking feature for group B
        if(UserData.group == "B") {
            takePictureButton.isHidden = true
            takePhotoActivityIndicator.isHidden = true
        }
        
        // only allow photo taking for group D once ML model is downloaded
        if(UserData.group == "D") {
            takePhotoActivityIndicator.startAnimating()
            takePictureButton.isEnabled = false
            modelDownloadTask?.observe(.success) { _ in
                self.takePhotoActivityIndicator.stopAnimating()
                self.takePhotoActivityIndicator.isHidden = true
                self.takePictureButton.isEnabled = true
            }
        }
        
        // group B and D have access to the "Found Landmark" button
        modelDownloadTask?.observe(.success) { _ in
            self.foundLandmarkActivityIndicator.stopAnimating()
            self.foundLandmarkActivityIndicator.isHidden = true
            self.foundLandmarkButton.isEnabled = true
        }
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
    
    @IBAction func pressFoundLandmarkButton(_ sender: UIButton) {
        
    }
    
    @IBAction func pressNotifContinueButton(_ sender: UIButton) {
    }
    @IBAction func pressNotifFoundLandmarkButton(_ sender: UIButton) {
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
        UserData.picturesTaken.append(capturedImage)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
            let directions = MKDirections(request: request)

            directions.calculate { [weak self] response, error in
                guard let unwrappedResponse = response else { return }

                for route in unwrappedResponse.routes {
                    self!.mapView.addOverlay(route.polyline)
                    if(self!.shouldUpdateMapRect) {
                        self!.shouldUpdateMapRect = false
                        self!.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                }
            }
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
        
        shouldUpdateMapRect = true
        
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
        nearbyNotifImageView.isHidden = false
        nearbyTakePictureButton.isHidden = false
    }
    
    // TODO: Disable app from starting again once study completes (UserDefaults boolean)
    
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
    
    // TODO: DISPLAY NOTIFICATION IF RESULT IS SUCCESSFUL OR NOT OR NEEDS ANOTHER PICTURE
    func processClassifications(for request: VNRequest, error: Error?) -> Dictionary<String, Double> {
        
        guard let results = request.results else {
            fatalError("Could not classify image")
        }
    
        let classifications = results as! [VNClassificationObservation]
    
        let topClassifications = classifications.prefix(3) // get top 3 results
    
        let names = topClassifications.map { classification in
            return modelManager.renameResult(result: classification.identifier)
        }
    
        let resultPercentages = topClassifications.map { classification in
            return Double(String(format: "%.2f", classification.confidence * 100))!
        }
        
        print("NAMES: \(names)")
        print("RESULT PERCENTAGES: \(resultPercentages)")
        
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
                    let modelAsVNCoreModel = try VNCoreMLModel(for: mlModelObject)
                    print("WOOO BABY")
                    let request = VNCoreMLRequest(model: modelAsVNCoreModel, completionHandler: { [weak self] request, error in
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
    
    @IBAction func goToHomeVC(_ sender: UIButton) {
        switch UserData.group {
        case "B":
            performSegue(withIdentifier: "mapToBVC", sender: self)
        default:
            performSegue(withIdentifier: "mapToDVC", sender: self)
        }
    }
}
