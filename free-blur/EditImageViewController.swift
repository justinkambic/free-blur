//
//  FirstViewController.swift
//  free-blur
//
//  Created by Justin Kambic on 6/1/17.
//

import UIKit
import Photos
import CoreImage

class EditImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    let image = UIImagePickerController()
    var curImageSelection = UIImage()
    var blurredImage = UIImage()
    var faceGrids = [BlurSelectionView]()
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.delegate = self
        imgView.isUserInteractionEnabled = true
        imgView.frame = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnClick(_ sender: Any) {
        image.allowsEditing = true
        image.sourceType = .photoLibrary
        self.present(image, animated: true, completion: nil)
    }
    
    @IBAction func btnProcess_TouchUpInside(_ sender: Any) {
        var targets = [CGRect]()
        for target in self.faceGrids {
            if target.shouldBlurFace { targets.append(target.ciFaceCoords) }
        }
        
        let blurImageResult = blurImage(in: self.curImageSelection, targets: targets, numPasses: 2)
        self.blurredImage = blurImageResult!
        imgView.image = self.blurredImage
        
        self.clearSubviews()
    }
    
    func clearSubviews() {
        for view in imgView.subviews {
            view.removeFromSuperview()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.faceGrids.removeAll()
            self.curImageSelection = pickedImage
            imgView.contentMode = .scaleAspectFit
            
            self.clearSubviews()
            
            self.imgView.image = self.curImageSelection
            let ciImage = CIImage(image: pickedImage)
            self.findFaces(ciImage: ciImage!)
        }
        
        dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
                let viewSize = imgView.bounds.size
                let scale = min(viewSize.width / ciImageSize.width,
                                viewSize.height / ciImageSize.height)
                let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
                let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
                
                faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
                faceViewBounds.origin.x += offsetX
                faceViewBounds.origin.y += offsetY
                
                let faceBox = BlurSelectionView(frame: faceViewBounds, ciFaceCoords: face.bounds.applying(transform))
                
                imgView.addSubview(faceBox)
                self.faceGrids.append(faceBox)
            }
        }
    }
}


