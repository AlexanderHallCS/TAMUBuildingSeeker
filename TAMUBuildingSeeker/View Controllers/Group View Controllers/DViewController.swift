//
//  DViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 12/29/21.
//

import UIKit

class DViewController: UIViewController {
    
    let firebaseManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseManager.signInAnonymously()
    }
    
    @IBAction func unwindToDVC(segue: UIStoryboardSegue) {}

}
