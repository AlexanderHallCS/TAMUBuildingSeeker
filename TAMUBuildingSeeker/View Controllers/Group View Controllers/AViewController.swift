//
//  AViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 12/29/21.
//

import UIKit
import Vision
import CoreML
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class AViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var foundLandmarkButton: UIButton!
    @IBOutlet var foundLandmarkActivityMonitor: UIActivityIndicatorView!
    
    let modelManager = MLModelManager()
    let firebaseManager = FirebaseManager()
    
    var modelDownloadTask: StorageDownloadTask?
    var modelDownloadUrl = URL(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mlModelFileData = modelManager.downloadMLModelFile()
        modelDownloadTask = mlModelFileData.0
        modelDownloadUrl = mlModelFileData.1
        
        foundLandmarkActivityMonitor.startAnimating()
        foundLandmarkButton.isEnabled = false
        
        modelDownloadTask?.observe(.success) { _ in
            self.foundLandmarkActivityMonitor.stopAnimating()
            self.foundLandmarkActivityMonitor.isHidden = true
            self.foundLandmarkButton.isEnabled = true
        }
        
        firebaseManager.signInAnonymously()
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
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
        UserData.picturesTaken.append(capturedImage)
    }
    
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
                    let mlModelObject = try MLModel(contentsOf: compiledModelURL)
                    let modelAsVNCoreModel = try VNCoreMLModel(for: mlModelObject)
                    let request = VNCoreMLRequest(model: modelAsVNCoreModel, completionHandler: { [weak self] request, error in
                        self?.processClassifications(for: request, error: error)
                    })
                    request.imageCropAndScaleOption = .centerCrop
                    do {
                        try handler.perform([request])
                    } catch {
                        print("Failed to perform classification.\n\(error.localizedDescription)")
                    }
                } catch {
                    print("error!!")
                }
            }
        }
    }
    
    @IBAction func unwindToAVC(segue: UIStoryboardSegue) {}

}
