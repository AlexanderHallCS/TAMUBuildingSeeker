//
//  DViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 12/29/21.
//

import UIKit

class DViewController: UIViewController {

    @IBOutlet var takePhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        
    }
    
    @IBAction func unwindToDVC(segue: UIStoryboardSegue) {}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
