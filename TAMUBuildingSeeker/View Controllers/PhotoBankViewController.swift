//
//  PhotoBankViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 1/1/22.
//

import UIKit

class PhotoBankViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToHomeVC(_ sender: UIButton) {
        switch UserData.groupCode {
            case "A":
                fallthrough
            case "C":
                performSegue(withIdentifier: "unwindToACVCFromPhotoBank", sender: self)
            default:
                performSegue(withIdentifier: "unwindToDVCFromPhotoBank", sender: self)
        }
    }

}
