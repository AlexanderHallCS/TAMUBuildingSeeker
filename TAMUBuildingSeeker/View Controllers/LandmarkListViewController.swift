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
            case "B":
                fallthrough
            case "D":
                performSegue(withIdentifier: "unwindToBDVCFromList", sender: self)
            default:
                performSegue(withIdentifier: "unwindToCVCFromList", sender: self)
        }
    }
    
}
