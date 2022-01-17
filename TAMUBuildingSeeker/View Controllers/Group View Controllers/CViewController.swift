//
//  CViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 1/16/22.
//

import UIKit

class CViewController: UIViewController {

    @IBOutlet var takePhotoButton: UIButton!
    @IBOutlet var foundLandmarkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func takePhoto(_ sender: UIButton) {
        if(sender == foundLandmarkButton) {
            // show if building is correct or not and to retake if incorrect
        } else if(sender == takePhotoButton) {
            // show building name (and possibly information about the building)
        }
    }
    
    @IBAction func unwindToCVC(segue: UIStoryboardSegue) {}

}
