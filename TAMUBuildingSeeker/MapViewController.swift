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
import GeoFire

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate  {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var takePictureButton: UIButton!
    
    var previewImageView: UIImageView!
    var capturedImage: UIImage?
    
    let manager = CLLocationManager()
    
    let buildingCoordinates: [String: (CLLocationCoordinate2D)] = ["ANNEX_LIBR":CLLocationCoordinate2D(latitude: 30.6163635,longitude: -96.33843075),"BSBW":CLLocationCoordinate2D(latitude: 30.61561355,longitude: -96.33967812),"BTLR":CLLocationCoordinate2D(latitude: 30.61484579,longitude: -96.33893333),"EABAA":CLLocationCoordinate2D(latitude: 30.61593593,longitude: -96.33709296),"EABAB":CLLocationCoordinate2D(latitude: 30.61563357,longitude: -96.33749011),"EABAC":CLLocationCoordinate2D(latitude: 30.61541765, longitude: -96.33785592),"HELD":CLLocationCoordinate2D(latitude: 30.61510356,longitude: -96.33870627),"LAAH":CLLocationCoordinate2D(latitude: 30.61760828,longitude: -96.33806657),"PAV":CLLocationCoordinate2D(latitude: 30.61684315,longitude: -96.33802255), "PETR":CLLocationCoordinate2D(latitude: 30.61602477,longitude: -96.33851940),"RDER":CLLocationCoordinate2D(latitude: 30.61274023,longitude: -96.34015579),"SBISA":CLLocationCoordinate2D(latitude: 30.61675223,longitude: -96.34382093),"SCC":CLLocationCoordinate2D(latitude: 30.61589394,longitude: -96.33785416)]
    
    var selectedBuilding = ""
    
    let request = MKDirections.Request()
    
    var classificationResult: [String] = []
    var didGetFirstLocation = false
    var coordinates: [GeoPoint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //fetchMLModelFile() // DELETE THIS LATER
        //downloadedMLModelFile()
        
        NotificationCenter.default.addObserver(self,
                         selector: #selector(presentImagePreviewControls),
                         name: NSNotification.Name ("sendPreviewImage"),
                         object: nil)
        
        takePictureButton.backgroundColor = #colorLiteral(red: 0.3058823529, green: 0.04705882353, blue: 0.03921568627, alpha: 1)
        
        mapView.mapType = .mutedStandard
        self.mapView.delegate = self
        
        manager.delegate = self
        manager.requestLocation()
        manager.startUpdatingLocation()
        
        let buildingMarker = MKPointAnnotation()
        switch(selectedBuilding) {
        case "Evans Library Annex":
            buildingMarker.coordinate = buildingCoordinates["ANNEX_LIBR"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["ANNEX_LIBR"]!))
        case "Butler Hall":
            buildingMarker.coordinate = buildingCoordinates["BTLR"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["BTLR"]!))
        case "Biological Sciences Building West":
            buildingMarker.coordinate = buildingCoordinates["BSBW"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["BSBW"]!))
        case "Engineering Activity Building A":
            buildingMarker.coordinate = buildingCoordinates["EABAA"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["EABAA"]!))
        case "Engineering Activity Building B":
            buildingMarker.coordinate = buildingCoordinates["EABAB"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["EABAB"]!))
        case "Engineering Activity Building C":
            buildingMarker.coordinate = buildingCoordinates["EABAC"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["EABAC"]!))
        case "Heldenfelds":
            buildingMarker.coordinate = buildingCoordinates["HELD"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["HELD"]!))
        case "Liberal Arts & Humanities Building":
            buildingMarker.coordinate = buildingCoordinates["LAAH"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["LAAH"]!))
        case "Pavilion":
            buildingMarker.coordinate = buildingCoordinates["PAV"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["PAV"]!))
        case "Peterson Building":
            buildingMarker.coordinate = buildingCoordinates["PETR"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["PETR"]!))
        case "Rudder Tower":
            buildingMarker.coordinate = buildingCoordinates["RDER"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["RDER"]!))
        case "SBISA":
            buildingMarker.coordinate = buildingCoordinates["SBISA"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["SBISA"]!))
        case "Student Computing Center":
            buildingMarker.coordinate = buildingCoordinates["SCC"]!
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["SCC"]!))
        default:
            break
        }
        
        buildingMarker.title = selectedBuilding
        mapView.addAnnotation(buildingMarker)
        
        request.requestsAlternateRoutes = true
        request.transportType = .walking
    }
    
    @IBAction func presentCameraView(_ sender: UIButton) {
        segueToCameraView()
    }
    
    @objc func segueToCameraView() {
        performSegue(withIdentifier: "mapToCamera", sender: self)
    }
    
    func downloadedMLModelFile() -> (StorageDownloadTask, URL) {
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
    
    // TODO: Request permission to use location (rather than have it set to true in Settings app by default) --> See info.plist if it's bugging out
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                if(!didGetFirstLocation) {
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
                    let directions = MKDirections(request: request)

                    directions.calculate { [weak self] response, error in
                        guard let unwrappedResponse = response else { return }

                        for route in unwrappedResponse.routes {
                            self!.mapView.addOverlay(route.polyline)
                            self!.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        }
                    }
                    didGetFirstLocation = true
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
        return renderer
    }
    
    @IBAction func presentPictureTakingView(_ sender: UIButton) {
        print("BING CHILLING")
        segueToCameraView()
    }
    
    // removes the UIView and camera button
    // presents the image preview with continue and retake buttons
    @objc func presentImagePreviewControls(notification: Notification) {
        takePictureButton.isHidden = true
        takePictureButton.isUserInteractionEnabled = false
        
        print("BING CHILLING 8")
//        for each in self.view.subviews {
//            if each.tag == 101 {
//                each.removeFromSuperview()
//            }
//        }
        
        print("BINGGG")
        let image = (notification.userInfo as! Dictionary<String, UIImage>)["previewImage"]!
        print("Image: \(image)")
        capturedImage = image
        
        previewImageView = UIImageView()
        previewImageView.image = image
        previewImageView.tag = 101
        //previewImageView.layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        previewImageView.frame = CGRect(x: self.view.frame.maxX/7, y: self.view.frame.maxY/6, width: self.view.frame.width/1.5, height: self.view.frame.height/1.5)
        previewImageView.layer.borderWidth = 17.0
        previewImageView.layer.borderColor = #colorLiteral(red: 0.4470588235, green: 0.6078431373, blue: 0.4745098039, alpha: 1)
        print("FRAME: \(self.view.frame) OTHER THING: \(self.view.frame.origin)")
        
//        let previewBorder = UIImageView(image: UIImage(named: "Picture Border"))
//        previewBorder.frame = CGRect(x: self.view.frame.maxX/7, y: self.view.frame.maxY/6, width: self.view.frame.width/1.5 + 17, height: self.view.frame.height/1.5 + 17)
//        previewBorder.layer.zPosition = 1
        
        let takeAgainButton: UIButton = UIButton(type: .custom)
        takeAgainButton.setImage(UIImage(named: "Take Again Button"), for: .normal)
        takeAgainButton.tag = 101
        takeAgainButton.isUserInteractionEnabled = true
        takeAgainButton.frame = CGRect(x: self.view.frame.maxX - 166, y: self.view.frame.maxY - 91, width: 126, height: 53)
        takeAgainButton.layer.cornerRadius = 25
        takeAgainButton.addTarget(self, action: #selector(self.segueToCameraView), for: .touchUpInside)
        
        let confirmButton: UIButton = UIButton(type: .custom)
        confirmButton.setImage(UIImage(named: "Confirm Button"), for: .normal)
        confirmButton.tag = 101
        confirmButton.isUserInteractionEnabled = true
        confirmButton.frame = CGRect(x: self.view.frame.maxX - 336, y: self.view.frame.maxY - 91, width: 126, height: 53)
        confirmButton.layer.cornerRadius = 25
        confirmButton.addTarget(self, action: #selector(self.confirmButtonPressed), for: .touchUpInside)
        
        self.view.addSubview(previewImageView)
        //self.view.addSubview(previewBorder)
        self.view.addSubview(takeAgainButton)
        self.view.addSubview(confirmButton)
        print("BING CHILLING 9")
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                // unable to classify image
                return
            }
            let classifications = results as! [VNClassificationObservation]
        
            if classifications.isEmpty {
                self.classificationResult = []
            } else {
                // Get top 3 classifications
                let topClassifications = classifications.prefix(3)
                let descriptions = topClassifications.map { classification in
                   return String(format: "  %.2f %@", classification.confidence, classification.identifier)
                }
                self.classificationResult = descriptions.map { classification in
                    let resultsData = classification.split(separator: " ")
                    //print("Percentage: \(resultsData[0])")
                    let percentage = resultsData[0]
                    return "\(self.renameResult(result: String(resultsData[1])))  \(Int((Double(percentage)!*100).rounded()))%"
                }
                
                // TODO: Make database private for writing <<<<<<<<<<<<<<<<<<
               /* var ref: DocumentReference? = nil
                ref = db.collection("WalkingPaths").addDocument(data: [
                    "coordinatesOfUser": self.coordinates,
                    "responseToQuestion0#" : "Yes",
                    "responseToQuestion1#" : "5"
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                } */
                self.performSegue(withIdentifier: "mapToTable", sender: nil)
                //print("DESCRIPTIONS: " + descriptions.description)
            }
        }
    }
    
    @objc func confirmButtonPressed() {
        takePictureButton.isUserInteractionEnabled = true
        takePictureButton.isHidden = false
        //updateClassifications(for: capturedImage!)
        for view in self.view.subviews {
            if(view.tag == 101) {
                view.removeFromSuperview()
            }
        }
    }
    
    func renameResult(result: String) -> String {
        switch result {
        case "ANNEX_LIBR":
            return "Evans Library Annex"
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
        default:
            return result
        }
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
            let mlModelFileData = self.downloadedMLModelFile()
            let mlModelFileDownload = mlModelFileData.0
            let mlModelFilePath = mlModelFileData.1
            
            mlModelFileDownload.observe(.success) { snapshot in
                // Download completed successfully
                do {
                    let compiledModelURL = try MLModel.compileModel(at: mlModelFilePath)
                    print("test1")
                    let mlModelObject = try MLModel(contentsOf: compiledModelURL)
                    print("test2")
                    let modelTest = try VNCoreMLModel(for: mlModelObject)
                    print("WOOO BABY")
                    do {
                        //let model = try VNCoreMLModel(for: )
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
                        fatalError("Failed to load Vision ML model: \(error)")
                    }
                } catch {
                    print("error!!")
                }
            }
        }
    }
    
    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        var capturedImage = UIImage()
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            capturedImage = pickedImage
        }
        updateClassifications(for: capturedImage)
    } */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UINavigationController {
            if let childVC = vc.viewControllers[0] as? ResultsTableViewController {
                childVC.percentages = classificationResult
            }
        }
    }

    @IBAction func unwindToMap(segue: UIStoryboardSegue) {}
    
}
