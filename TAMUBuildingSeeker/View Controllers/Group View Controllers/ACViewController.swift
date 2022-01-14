//
//  ACViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 12/29/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class ACViewController: UIViewController {

    @IBOutlet var takePhotoButton: UIButton!
    @IBOutlet var takePhotoActivityMonitor: UIActivityIndicatorView!
    
    let modelManager = MLModelManager()
    
    var modelDownloadTask: StorageDownloadTask?
    var modelDownloadUrl = URL(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mlModelFileData = modelManager.downloadMLModelFile()
        modelDownloadTask = mlModelFileData.0
        modelDownloadUrl = mlModelFileData.1
        
        // group A can only take photos from the nearby notification
        if(UserData.group == "A") {
            takePhotoButton.isHidden = true
            takePhotoActivityMonitor.isHidden = true
        }
        
        if(UserData.group == "C") {
            takePhotoActivityMonitor.startAnimating()
            takePhotoButton.isEnabled = false
            
            modelDownloadTask?.observe(.success) { _ in
                self.takePhotoActivityMonitor.stopAnimating()
                self.takePhotoActivityMonitor.isHidden = true
                self.takePhotoButton.isEnabled = true
            }
        }
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        
    }
    
    @IBAction func unwindToACVC(segue: UIStoryboardSegue) {}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
