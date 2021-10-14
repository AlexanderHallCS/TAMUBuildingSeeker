//
//  SelectViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 10/14/21.
//

import UIKit

class SelectViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var buildingPickerView: UIPickerView!
    @IBOutlet var goToMapButton: UIButton!
    
    var pickerData: [String] = [String]()
    
    var selectedBuilding = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Connect data:
        self.buildingPickerView.delegate = self
        self.buildingPickerView.dataSource = self
        
        // Do any additional setup after loading the view.
        pickerData = ["Annex/West Evans Library", "Biological Sciences Building West", "Butler Hall", "Engineering Activity Building A", "Engineering Activity Building B", "Engineering Activity Building C",
        "Heldenfelds","Liberal Arts & Humanities Building","Pavillion","Peterson Building","Rudder Tower","SBISA","Student Computing Center"]
        
        goToMapButton.backgroundColor = #colorLiteral(red: 0.3058823529, green: 0.04705882353, blue: 0.03921568627, alpha: 1)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count;
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedBuilding = pickerData[row]
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? MapViewController {
            vc.selectedBuilding = selectedBuilding
        }
    }

}
