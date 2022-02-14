//
//  BViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 1/13/22.
//

import UIKit

class BViewController: UIViewController {

    let firebaseManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseManager.signInAnonymously()
    }
    
    @IBAction func unwindToBVC(segue: UIStoryboardSegue) {}

}
