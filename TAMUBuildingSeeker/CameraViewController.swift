//
//  CameraViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 12/19/21.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    let backCamera = AVCaptureDevice.default(for: .video)
    var captureSession: AVCaptureSession = AVCaptureSession()
    
    @IBOutlet var videoPreviewView: UIView! {
        didSet {
            videoPreviewView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handleVideoPreviewPinch(sender: ))))
        }
    }
    @IBOutlet var pictureTakingBorder: UIImageView!
    @IBOutlet var takePictureButton: UIButton!
    
    var zoomFactor: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //takePictureButton.titleLabel!.isHidden = true
        //takePictureButton.titleLabel!.text = ""
        
        //videoPreviewView.frame = view.frame
        //captureSession = AVCaptureSession()
        prepareCaptureSession()
    }
    
    @objc func handleVideoPreviewPinch(sender: UIPinchGestureRecognizer) {
        print("here!")
        
        if(sender.state == .began) {
            zoomFactor = (backCamera?.videoZoomFactor)!
        } else {
            let scale: CGFloat = min(max(1, zoomFactor * sender.scale), (backCamera?.activeFormat.videoMaxZoomFactor)!)
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.01)
            //videoPreviewView.layer.setAffineTransform(CGAffineTransform())
            videoPreviewView.layer.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
            print("SENDER: \(sender)")
            print("SENDER SCALE: \(sender.scale)")
            print("SCALE: \(scale)")
            CATransaction.commit()
            
//            DispatchQueue.main.async {
//                self.videoPreviewLayer.frame = self.videoPreviewView.bounds
//            }
            /*
             switch sender.state {
             case .began: fallthrough
             case .changed:
                 let scale: CGFloat = min(max(1, zoomFactor * sender.scale), (backCamera?.activeFormat.videoMaxZoomFactor)!)
                 CATransaction.begin()
                 CATransaction.setAnimationDuration(0.01)
             case .ended:
                 let scale: CGFloat = min(max(1, zoomFactor * sender.scale), (backCamera?.activeFormat.videoMaxZoomFactor)!)
                 CATransaction.begin()
                 CATransaction.setAnimationDuration(0.01)
                 videoPreviewView.layer.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
                 CATransaction.commit()
             }
             if(sender.state == .began) {
                 zoomFactor = (backCamera?.videoZoomFactor)!
             } else {
                 
                 
                 
                 
                 print("SENDER: \(sender)")
                 print("SENDER SCALE: \(sender.scale)")
                 print("SCALE: \(scale)")
             */
            do {
                try backCamera?.lockForConfiguration()
                print("scaling!")
                backCamera?.videoZoomFactor = scale
                backCamera?.unlockForConfiguration()
                print("VIDEO PREVIEW LAYER FRAME 2: \(videoPreviewLayer.frame) BOUNDS: \(videoPreviewLayer.bounds)")
                print("VIDEO PREVIEW VIEW FRAME 2: \(videoPreviewView.frame) BOUNDS: \(videoPreviewView.bounds)")
            } catch let error {
                print("Could not lock thread with error: \(error)")
            }
        }
    }
    
    func prepareCaptureSession() {
        print("BING CHILLING 2")
        
        captureSession.sessionPreset = .high // change if too slow
        
//        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
//            print("Unable to access back camera!")
//            return
//        }
        
        do {
            print("BING CHILLING 3")
            let input = try AVCaptureDeviceInput(device: backCamera!)
            
            stillImageOutput = AVCapturePhotoOutput()
            
            if(captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput)) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupVideoPreview()
            }
        } catch let error {
            print("Error: Unable to initialize back camera: \(error.localizedDescription)")
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        videoPreviewLayer.frame = view.layer.bounds
//    }
    
    func setupVideoPreview() {
        print("BING CHILLING 4")
        //videoPreviewView = UIView(frame: self.view.frame)
        //videoPreviewView.frame = CGRect(x: 0, y: 0, width: 1080, height: 1920)
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        DispatchQueue.main.async {
//            self.videoPreviewLayer.frame = CGRect(x: self.videoPreviewView.frame.minX, y: self.videoPreviewView.frame.minY, width: self.videoPreviewView.frame.width, height: self.videoPreviewView.frame.width)
//        }
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.videoPreviewView.bounds
        }
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        /*DispatchQueue.main.async {
            
            self.videoPreviewLayer.frame = UIScreen.main.bounds
//            self.videoPreviewLayer.frame = self.videoPreviewView.bounds
//            self.videoPreviewLayer.bounds = self.view.bounds
//            self.videoPreviewLayer.position = CGPoint(x: self.view.layer.bounds.midX, y: self.view.layer.bounds.midY)
        } */
        videoPreviewView.layer.addSublayer(videoPreviewLayer)
        
        pictureTakingBorder.layer.zPosition = 1
        //videoPreviewView.addSubview(pictureTakingBorder)
        
        takePictureButton.layer.zPosition = 2
        //videoPreviewView.addSubview(takePictureButton)
        
        //videoPreviewView.frame = self.view.frame
        //videoPreviewView.tag = 101
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
        
        print("VIDEO PREVIEW LAYER FRAME: \(videoPreviewLayer.frame) BOUNDS: \(videoPreviewLayer.bounds)")
        print("VIDEO PREVIEW VIEW FRAME: \(videoPreviewView.frame) BOUNDS: \(videoPreviewView.bounds)")
        print("BING CHILLING 5")
        //view.addSubview(videoPreviewView)
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
        print("BING CHILLING 6")
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("BING CHILLING 7")
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        let image = UIImage(data: imageData)
        
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "sendPreviewImage"), object: nil, userInfo: ["previewImage" : image!])
        
        self.dismiss(animated: true, completion: nil)
    }

}
