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
        switch UserData.group {
            case "B":
                fallthrough
            case "D":
                performSegue(withIdentifier: "unwindToBDVCFromPhotoBank", sender: self)
            default:
                performSegue(withIdentifier: "unwindToCVCFromPhotoBank", sender: self)
        }
    }

}
