//
//  TutorialViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 12/30/21.
//

import UIKit

class TutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToHomeVC(_ sender: UIButton) {
        switch UserData.group {
        case "A":
            performSegue(withIdentifier: "unwindToAVCFromTutorial", sender: self)
        case "B":
            performSegue(withIdentifier: "unwindToBVCFromTutorial", sender: self)
        case "C":
            performSegue(withIdentifier: "unwindToCVCFromTutorial", sender: self)
        default:
            performSegue(withIdentifier: "unwindToDVCFromTutorial", sender: self)
        }
    }

}
