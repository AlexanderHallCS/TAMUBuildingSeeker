//
//  ViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 9/27/21.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startButton.backgroundColor = #colorLiteral(red: 0.3058823529, green: 0.04705882353, blue: 0.03921568627, alpha: 1)
    }
    
    @IBAction func unwindToStart(segue: UIStoryboardSegue) {}
}

