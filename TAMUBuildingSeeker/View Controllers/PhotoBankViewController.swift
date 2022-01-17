//
//  PhotoBankViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 1/1/22.
//

import UIKit

class PhotoBankViewController: UIViewController {

    @IBOutlet var background: UIImageView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var contentViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadImages()
    }
    
    private func loadImages() {
        
        var heightConstraintCopy = contentViewHeightConstraint
        
        let leftAlignX = background.frame.minX + background.frame.width/12
        var yPosition = 0.0
        
        var imageViewList: [UIImageView] = []
        for imageIndex in 0..<UserData.picturesTaken.count {
            let pictureImageView = UIImageView(image: UserData.picturesTaken[imageIndex])
            pictureImageView.contentMode = .scaleAspectFit
            
            // position next image using the height of the image in the row above it
            if(imageIndex >= 2 && imageIndex%2 == 0) {
                yPosition += imageViewList[imageIndex-2].frame.height
            }
            if(imageIndex%2 == 1) {
                pictureImageView.frame = CGRect(x: leftAlignX + (imageIndex == 0 ? 0 : background.frame.size.width/3.0) + background.frame.width/12, y: yPosition, width: background.frame.size.width/3.0, height: background.frame.size.height/3.0)
            } else {
                pictureImageView.frame = CGRect(x: leftAlignX, y: yPosition, width: background.frame.size.width/3.0, height: background.frame.size.height/3.0)
            }
            pictureImageView.layer.zPosition = 4
            contentView.addSubview(pictureImageView)
            imageViewList.append(pictureImageView)
            
            if(pictureImageView.frame.maxY > contentView.frame.height) {
                if(contentViewHeightConstraint.isActive) {
                    contentViewHeightConstraint.isActive = false
                }
                if(heightConstraintCopy!.isActive) {
                    heightConstraintCopy!.isActive = false
                }
                heightConstraintCopy = heightConstraintCopy!.recreateConstraint(multiplier: heightConstraintCopy!.multiplier + pictureImageView.frame.size.height/contentView.frame.size.height)
             
                self.view.addConstraint(heightConstraintCopy!)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func goToHomeVC(_ sender: UIButton) {
        switch UserData.group {
        case "A":
            fallthrough
        case "C":
            performSegue(withIdentifier: "unwindToACVCFromPhotoBank", sender: self)
        case "B":
            performSegue(withIdentifier: "unwindToBVCFromPhotoBank", sender: self)
        default:
            performSegue(withIdentifier: "unwindToDVCFromPhotoBank", sender: self)
        }
    }

}

extension NSLayoutConstraint {
    func recreateConstraint(multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
