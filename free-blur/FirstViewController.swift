//
//  FirstViewController.swift
//  free-blur
//
//  Created by Justin Kambic on 6/1/17.
//  Copyright © 2017 Justin Kambic. All rights reserved.
//

import UIKit
import Photos
import CoreImage

class FirstViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{

    let image = UIImagePickerController()
    
    @IBOutlet weak var imgView: UIImageView!
    override func viewDidLoad() {
        NSLog("view did load")
        super.viewDidLoad()
        
        image.delegate = self
        imgView.layer.borderColor = UIColor.black.cgColor
        imgView.layer.borderWidth = 2
        imgView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnClick(_ sender: Any) {
        NSLog("btn click")
        image.allowsEditing = true
        image.sourceType = .photoLibrary
        self.present(image, animated: true, completion: nil)
    }

    func findFaces(ciImage: CIImage) {
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        if let faces = faceDetector?.features(in: ciImage) {
        
        let ciImageSize = ciImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImage.extent.size.height)
        
            for face in faces as! [CIFaceFeature] {
                var faceViewBounds = face.bounds.applying(transform)
                print("Found face at bounds \(face.bounds)")
                let viewSize = imgView.bounds.size
                let scale = min(viewSize.width / ciImageSize.width,
                                viewSize.height / ciImageSize.height)
                let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
                let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
                
                //let transform = CGRectApplyAffineTransform(face.bounds, )
                
                faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
                faceViewBounds.origin.x += offsetX
                faceViewBounds.origin.y += offsetY
                
                let faceBox = SelectBlurView(frame: faceViewBounds)
                faceBox.layer.borderWidth = 2
                faceBox.layer.borderColor = UIColor.yellow.cgColor
                faceBox.backgroundColor = UIColor.clear
                faceBox.clipsToBounds = true
                faceBox.layer.cornerRadius = faceBox.frame.size.width/2.0
                
                
                //let gestureRecognizer = UITapGestureRecognizer(target: faceBox, action: #selector(self.viewTapped(_:)))
                //faceBox.addGestureRecognizer(gestureRecognizer)
                
                /*let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
                let blurView = UIVisualEffectView(effect: blurEffect)
                blurView.frame = faceViewBounds
                blurView.layer.cornerRadius = faceBox.frame.size.width/2.0
                blurView.clipsToBounds = true*/
                
                imgView.addSubview(faceBox)
                
                //imgView.addSubview(blurView)
            }
        }
    }
    
    func viewTapped(_ sender: UIGestureRecognizer) {
        NSLog("In view tapped")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        NSLog("In picker handler")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            NSLog("In")
            imgView.contentMode = .scaleAspectFit
            for view in imgView.subviews {
                view.removeFromSuperview()
            }
            
            imgView.image = pickedImage
            let ciImage = CIImage(image: pickedImage)
            self.findFaces(ciImage: ciImage!)
            var toSave = imgView.snapshotView(afterScreenUpdates: true)
            imgView.image = processPixels(in: pickedImage)
        }
        
        dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        NSLog("cancel")
        dismiss(animated: true, completion: nil)
    }
}

