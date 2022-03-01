//
//  CViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 1/16/22.
//

import UIKit
import Vision
import CoreML
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import ResearchKit

class CViewController: UIViewController, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, ORKTaskViewControllerDelegate {

    @IBOutlet var takePhotoButton: UIButton!
    @IBOutlet var foundLandmarkButton: UIButton!
    
    @IBOutlet var foundLandmarkActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var takePhotoActivityIndicator: UIActivityIndicatorView!
    
    // used when participant uses the "Take Photo" button
    @IBOutlet var landmarkInfoView: UIView!
    @IBOutlet var landmarkInfoViewImageView: UIImageView!
    
    // used after a successful recognition of a destination landmark
    @IBOutlet var destCongratsView: UIView!
    @IBOutlet var destCongratsViewImageView: UIImageView!
    
    @IBOutlet var startButton: UIButton!
    @IBOutlet var startActivityIndicator: UIActivityIndicatorView!
    
    var previewImageView: UIImageView!
    var capturedImage: UIImage?
    
    let manager = CLLocationManager()
    
    var destinationIndex = 0 // specifies what the current destination is
    
    var coordinates: [GeoPoint] = []
    var currLoc = CLLocationCoordinate2D()
    
    let modelManager = MLModelManager()
    let firebaseManager = FirebaseManager()
    let surveyHelper = SurveyHelper()
    
    var modelDownloadTask: StorageDownloadTask?
    var modelDownloadUrl = URL(string: "")
    
    var timer: Timer = Timer()
    let timeInterval = 1.0 // how often timestamps are taken (1.0s or 1000ms)
    var currentTime = 0.0
    var shouldRecordLocation = false
    
    // Used to indicate which button the user pressed to take a picture.
    // This is needed to find out how to process the classification results
    var didUsePhotoTakingFeature = false
    var didUseFoundLandmarkFeature = false
    
    // Represents how many times the user has tried to take a picture of the destination
    var pictureTakingAttempts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseManager.signInAnonymously()
        
        let mlModelFileData = modelManager.downloadMLModelFile()
        modelDownloadTask = mlModelFileData.0
        modelDownloadUrl = mlModelFileData.1
        
        manager.delegate = self
        
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        
        foundLandmarkActivityIndicator.startAnimating()
        foundLandmarkButton.isEnabled = false
        
        takePhotoActivityIndicator.startAnimating()
        takePhotoButton.isEnabled = false
        
        startActivityIndicator.startAnimating()
        startButton.isEnabled = false
        
        modelDownloadTask?.observe(.success) { _ in
            self.foundLandmarkActivityIndicator.stopAnimating()
            self.takePhotoActivityIndicator.stopAnimating()
            self.startActivityIndicator.stopAnimating()
            
            self.foundLandmarkActivityIndicator.isHidden = true
            self.takePhotoActivityIndicator.isHidden = true
            self.startActivityIndicator.isHidden = true
            
            self.startButton.setBackgroundImage(UIImage(named: "Start"), for: .normal)
            self.startButton.isEnabled = true
        }
    }
    
    @IBAction func pressStartButton(_ sender: UIButton) {
        startButton.setBackgroundImage(UIImage(named: "StartGrayscale"), for: .normal)
        startButton.isEnabled = false
        shouldRecordLocation = true
        prepareDestination(title: "Start!", message: "Head to the Freedom from Terrorism Memorial")
        foundLandmarkButton.isEnabled = true
        takePhotoButton.isEnabled = true
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(incrementTimeInterval), userInfo: nil, repeats: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
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
    
    // linked to "Take Photo" button
    @IBAction func pressTakePhotoButton(_ sender: UIButton) {
        didUsePhotoTakingFeature = true
        
        let photoTakingAlert = generatePhotoTakingAlert()
        let cancelPhotoTaking = UIAlertAction(title: "Cancel", style: .cancel) {  [unowned self] _ in
            self.didUsePhotoTakingFeature = false
        }
        photoTakingAlert.addAction(cancelPhotoTaking)
        present(photoTakingAlert, animated: true)
    }
    
    // linked to found landmark button
    @IBAction func pressFoundLandmarkButton(_ sender: UIButton) {
        let atDestinationAlert = UIAlertController(title: "Confirm", message: "Do you think you have found the landmark?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .default) {  [unowned self] _ in
            self.didUseFoundLandmarkFeature = true
            
            let photoTakingAlert = generatePhotoTakingAlert()
            let cancelPhotoTaking = UIAlertAction(title: "Cancel", style: .cancel) {  [unowned self] _ in
                self.didUseFoundLandmarkFeature = false
            }
            photoTakingAlert.addAction(cancelPhotoTaking)
            present(photoTakingAlert, animated: true)
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel)
        atDestinationAlert.addAction(confirmAction)
        atDestinationAlert.addAction(cancelAction)
        present(atDestinationAlert, animated: true)
    }
    
    private func generatePhotoTakingAlert() -> UIAlertController {
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return UIAlertController()
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
        
        return photoSourcePicker
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
        UserData.numPicturesTaken += 1
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currLoc = location.coordinate
            if(shouldRecordLocation) {
                UserData.coordinates.append(GeoPoint(latitude: locations.first!.coordinate.latitude, longitude: locations.first!.coordinate.longitude))
                UserData.coordinateTimestamps.append(currentTime)
                UserData.coordinateDateTimes.append(getCurrentDateTime())
                shouldRecordLocation = false
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch user's location: \(error.localizedDescription)")
    }
    
    private func prepareDestination(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) {(action: UIAlertAction) -> Void in
            alert.removeFromParent()
        })
        present(alert, animated: true, completion: nil)
    }
    
    @objc func incrementTimeInterval() {
        currentTime += timeInterval
        shouldRecordLocation = true
        
        UserData.totalTimeElapsed = currentTime
        
        // save data to DB every 10 seconds
        if(currentTime.truncatingRemainder(dividingBy: 10.0) == 0.0) {
            firebaseManager.saveData()
        }
        
        // disallow most data collection after 75 minutes
        if(currentTime > 4500) {
            pauseTimer()
        }
    }
    
    private func startTimer() {
        timer.fire()
    }
    
    private func pauseTimer() {
        timer.invalidate()
    }
    
    private func getCurrentDateTime() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY, MMM d, HH:mm:ss.SSSS"
        return dateFormatter.string(from: date)
    }
    
    private func prepareEndOfStudy() {
        pauseTimer()
        
        UserData.totalTimeElapsed = currentTime
        
        let endAlert = UIAlertController(title: "Complete", message: "Thank you for participating in this study! Please head back to Rudder Plaza", preferredStyle: .alert)
        endAlert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            self.performSegue(withIdentifier: "CToEnd", sender: self)
            endAlert.removeFromParent()
        })
        present(endAlert, animated: true, completion: nil)
    }
    
    // MARK: Image classification processing
    
    private func processClassifications(for request: VNRequest, error: Error?, image: UIImage) {
        
        guard let results = request.results else {
            fatalError("Could not classify image")
        }
    
        // get all classification results whose confidence is greater than 0.01/1.00
        let classifications = (results as! [VNClassificationObservation]).filter { classification in
            return classification.confidence > 0.01
        }
    
        var wholeImageTopResults = classifications.map { classification in
            return modelManager.renameResult(result: classification.identifier)
        }
        
        // take top 3 results from image classification of overall image
        wholeImageTopResults = Array(wholeImageTopResults.prefix(3))
        
        let choppedImagesTopResults = modelManager.extractThreeByThreeCroppingTopResults(image: image, modelDownloadUrl: modelDownloadUrl!)
        
        var overallAndSliceResults = Array(Set(wholeImageTopResults + choppedImagesTopResults))
        
        overallAndSliceResults = modelManager.filterOutDistantBuildings(results: overallAndSliceResults, currLoc: currLoc);
        
        if(didUseFoundLandmarkFeature) {
            didUseFoundLandmarkFeature = false
            UserData.numTimesDestinationPictureTaken += 1
            // takes top results from classification of whole image and classification of chopped parts
            verifyOrRejectLandmark(names: Array(overallAndSliceResults))
        } else if(didUsePhotoTakingFeature) {
            didUsePhotoTakingFeature = false
            UserData.numTimesBuildingRecognizerUsed += 1
            var topResult = ""
            if(wholeImageTopResults.count == 0 && choppedImagesTopResults.count == 0) {
                topResult = "None"
            } else if(wholeImageTopResults.count == 0 && choppedImagesTopResults.count > 0) {
                topResult = choppedImagesTopResults.first!
            } else if(wholeImageTopResults.count > 0 && choppedImagesTopResults.count == 0) {
                topResult = wholeImageTopResults.first!
            } else {
                topResult = wholeImageTopResults.first!
            }
            showLandmarkInformation(named: topResult)
        }
    }
    
    // Called when using the Found Landmark buttons
    // Prepares and updates route to next destination if accurate,
    // else asks to retry/override picture in alert
    private func verifyOrRejectLandmark(names: [String]) {
        pictureTakingAttempts += 1
        switch DestinationData.destTitles[destinationIndex] {
        case "Freedom from Terrorism Memorial":
            if(names.contains("Freedom from Terrorism Memorial")) {
                UserData.numTimesDestinationWasRecognized += 1
                UserData.successfulRecogTimes.append(currentTime)
                presentPictureSuccessAlert(imageName: "Freedom Congrats")
            } else {
                UserData.failedRecogTimes.append(currentTime)
                presentPictureErrorAlert()
            }
        case "Engineering Activity Building":
            if(names.contains("Engineering Activity Building")) {
                UserData.numTimesDestinationWasRecognized += 1
                UserData.successfulRecogTimes.append(currentTime)
                presentPictureSuccessAlert(imageName: "EAB Congrats")
            } else {
                UserData.failedRecogTimes.append(currentTime)
                presentPictureErrorAlert()
            }
        default:
            if(names.contains("Bolton Hall")) {
                UserData.numTimesDestinationWasRecognized += 1
                UserData.successfulRecogTimes.append(currentTime)
                presentPictureSuccessAlert(imageName: "Bolton Congrats")
            } else {
                UserData.failedRecogTimes.append(currentTime)
                presentPictureErrorAlert()
            }
        }
    }
    
    // show congrats pop-up after taking a successful picture of a destination
    private func presentPictureSuccessAlert(imageName: String) {
        destCongratsViewImageView.image = UIImage(named: imageName)
        destCongratsView.animateIn()
    }
    
    // remove congrats pop-up, save data, show survey
    @IBAction func pressDestCongratsContinueButton(_ sender: UIButton) {
        destCongratsView.animateOut()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            let surveyAlert = UIAlertController(title: "Survey", message: "Please take a short survey.", preferredStyle: .alert)
            surveyAlert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
                UserData.destinationTimes.append(self.currentTime)
                self.pictureTakingAttempts = 0
                self.destinationIndex += 1
                self.takeSurvey()
                surveyAlert.removeFromParent()
            })
            self.present(surveyAlert, animated: true, completion: nil)
        })
    }
    
    // if destination picture is incorrect, show this alert
    // allow overriding of taking pictures after 2 attempts
    private func presentPictureErrorAlert() {
        let pictureErrorAlert = UIAlertController(title: "Error", message: pictureTakingAttempts > 1 ? "The error may be on our end. Click on \"Continue Anyway\" to continue the study and take a short survey." : "Hm.. You may be looking in the wrong direction. Double check and try again.", preferredStyle: .alert)
        // one attempt to retake photo
        if(pictureTakingAttempts <= 1) {
            pictureErrorAlert.addAction(UIAlertAction(title: "Retake Photo", style: .default) { _ in
                pictureErrorAlert.removeFromParent()
                self.didUseFoundLandmarkFeature = true
                
                let photoTakingAlert = self.generatePhotoTakingAlert()
                let cancelPhotoTaking = UIAlertAction(title: "Cancel", style: .cancel) {  [unowned self] _ in
                    self.didUseFoundLandmarkFeature = false
                }
                photoTakingAlert.addAction(cancelPhotoTaking)
                self.present(photoTakingAlert, animated: true)
            })
        } else {
            pictureErrorAlert.addAction(UIAlertAction(title: "Continue Anyway", style: .default) { _ in
                UserData.destinationTimes.append(self.currentTime)
                self.pictureTakingAttempts = 0
                self.destinationIndex += 1
                self.takeSurvey()
                pictureErrorAlert.removeFromParent()
            })
        }
        present(pictureErrorAlert, animated: true, completion: nil)
    }
    
    // Called when using general photo taking picture (Take Photo button)
    private func showLandmarkInformation(named name: String) {
        if(name == "None") {
            let oopsAlert = UIAlertController(title: "Oops", message: "We could not find a landmark in the picture! Please try again.", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "Ok", style: .default) { _ in
                oopsAlert.removeFromParent()
            }
            oopsAlert.addAction(confirm)
            present(oopsAlert, animated: true, completion: nil)
        } else {
            landmarkInfoViewImageView.image = UIImage(named: Landmarks.landmarkData[name]!.imageFileName)
            landmarkInfoView.animateIn()
        }
    }
    
    @IBAction func closeLandmarkInfoView(_ sender: UIButton) {
        landmarkInfoView.animateOut()
    }
    
    /// - Tag: PerformRequests
    private func updateClassifications(for image: UIImage) {
        
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
                    let mlModelObject = try MLModel(contentsOf: compiledModelURL)
                    let modelAsVNCoreModel = try VNCoreMLModel(for: mlModelObject)
                    let request = VNCoreMLRequest(model: modelAsVNCoreModel, completionHandler: { [weak self] request, error in
                        self?.processClassifications(for: request, error: error, image: image)
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
    }
    
    // MARK: Mid-App Survey, ResearchKit
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        UserData.surveyStopTimes.append(currentTime)
        surveyHelper.storeSurveyResultsLocally(taskViewController: taskViewController, reason: reason)
        firebaseManager.saveSurveyResults()
        taskViewController.dismiss(animated: true, completion: nil)
        
        if(destinationIndex == 1) {
            prepareDestination(title: "Continue", message: "Please head to the Engineering Activity Buildings!")
        } else if(destinationIndex == 2) {
            prepareDestination(title: "Continue", message: "Please head to Bolton Hall!")
        } else { // destinationIndex > 2 means finished route
            prepareEndOfStudy()
        }
    }
    
    // Delegate function used to make cancel button invisible
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        stepViewController.cancelButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.nothingPlaceholderForInvisCancelButton))
    }
    
    // Supporting function to make cancel button invisible
    @objc func nothingPlaceholderForInvisCancelButton() {}
    
    private func takeSurvey() {
        UserData.surveyStartTimes.append(currentTime)
        let taskViewController = ORKTaskViewController(task: surveyHelper.MidAppSurveyTask, taskRun: nil)
        taskViewController.delegate = self
        taskViewController.modalPresentationStyle = .fullScreen
        taskViewController.navigationBar.prefersLargeTitles = false
        taskViewController.navigationBar.backgroundColor = .white
        present(taskViewController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToCVC(segue: UIStoryboardSegue) {}

}
