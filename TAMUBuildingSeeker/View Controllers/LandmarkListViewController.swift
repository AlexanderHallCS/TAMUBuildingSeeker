//
//  LandmarkListViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 1/1/22.
//

import UIKit

class LandmarkListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToHomeVC(_ sender: UIButton) {
        switch UserData.group {
        case "A":
            fallthrough
        case "C":
            performSegue(withIdentifier: "unwindToACVCFromList", sender: self)
        case "B":
            performSegue(withIdentifier: "unwindToBVCFromList", sender: self)
        default:
            performSegue(withIdentifier: "unwindToDVCFromList", sender: self)
        }
    }
    
}
