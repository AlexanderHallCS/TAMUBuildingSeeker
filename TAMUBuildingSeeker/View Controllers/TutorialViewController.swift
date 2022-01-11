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
            case "B":
                fallthrough
            case "D":
                performSegue(withIdentifier: "unwindToBDVCFromTutorial", sender: self)
            default:
                performSegue(withIdentifier: "unwindToCVCFromTutorial", sender: self)
        }
    }

}
