//
//  ViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 9/27/21.
//

import UIKit
//import Firebase

class StartViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var groupCodeSelector: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        Auth.auth().signInAnonymously(completion: { authResult, error in
//            guard let user = authResult?.user else {
//                print(authResult!.user)
//                return
//            }
//            let uid = user.uid
//            print(uid)
//        })
        groupCodeSelector.delegate = self
        groupCodeSelector.autocapitalizationType = .allCharacters
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(string.isEmpty) {
            return true
        }
        
        //textField.text = (textField.text as NSString).replace
        
        let expectedLength = 4
        
        // calculate how long the input is after it is added to / removed from
        let initialLength = textField.text?.count ?? 0
        let addingLength = string.count
        let replacingLength = range.length
        
        // final input length after change
        let resultingLength = initialLength + addingLength - replacingLength
        
        let permissableChars = CharacterSet.letters
        if let allowedCharRange = string.rangeOfCharacter(from: permissableChars, options: .caseInsensitive) {
            let validCharCount = string.distance(from: allowedCharRange.lowerBound, to: allowedCharRange.upperBound)
            return validCharCount == string.count && resultingLength <= expectedLength
        } else {
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if(textField.text?.count != 4) {
            showTooShortAlert()
        } else {
            showConfirmAlert()
        }
        
        return true
    }
    
    private func showTooShortAlert() {
        let alert = UIAlertController(title: "Error", message: "Code must be four characters.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) {(action: UIAlertAction) -> Void in
            alert.removeFromParent()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showConfirmAlert() {
        groupCodeSelector.isHidden = true
        
        let alert = UIAlertController(title: "Are you sure?", message: "Once you have confirmed your code (\(groupCodeSelector.text!)) you cannot return to this page.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) {(action: UIAlertAction) -> Void in
            alert.removeFromParent()
            self.groupCodeSelector.isHidden = false
        })
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) {(action: UIAlertAction) -> Void in
            alert.removeFromParent()
            self.prepareAppGroup()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    // segues to appropriate group VC
    // stores anonymous uid and group letter in database
    private func prepareAppGroup() {
        
    }
    
    @IBAction func unwindToStart(segue: UIStoryboardSegue) {}
    
}

