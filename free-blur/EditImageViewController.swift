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
    
    var canBlur: Bool {
        get {
            for faceGrid in faceGrids {
                if faceGrid.shouldBlurFace {
                    return true
                }
            }
            return false
        }
    }
    
    @IBOutlet weak var blurButton: UIBarButtonItem!
    @IBOutlet weak var blurNavItem: UINavigationItem!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblSaved: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.image.delegate = self
        self.imgView.isUserInteractionEnabled = true
        self.imgView.frame = self.view.bounds
        
        self.lblSaved.isHidden = true
        self.blurNavItem.title = "Blur Images"
        
        if let leftButton = self.blurNavItem.leftBarButtonItem {
            leftButton.target = self
            leftButton.action = #selector(selectPhotoPressed)
        }
        
        self.blurButton.target = self
        self.blurButton.action = #selector(blurPhotoPressed)
        self.blurButton.isEnabled = self.canBlur
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveBlurredImage" {
            let destView = segue.destination as! SaveImageViewController
            destView.imageToSave = self.blurredImage
        }
        super.prepare(for: segue, sender: sender)
    }

    func selectPhotoPressed() {
        self.image.allowsEditing = true
        self.image.sourceType = .photoLibrary
        self.present(image, animated: true, completion: nil)
    }
    
    func blurPhotoPressed() {
        var targets = [CGRect]()
        for target in self.faceGrids {
            if target.shouldBlurFace { targets.append(target.ciFaceCoords) }
        }
        
        // TODO: make this async
        let blurImageResult = blurImage(in: self.curImageSelection, targets: targets, numPasses: 2)
        self.blurredImage = blurImageResult!
        self.imgView.image = self.blurredImage
        
        self.clearSubviews()
        performSegue(withIdentifier: "saveBlurredImage", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearSubviews() {
        for view in self.imgView.subviews {
            view.removeFromSuperview()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.faceGrids.removeAll()
            self.curImageSelection = pickedImage
            self.imgView.contentMode = .scaleAspectFit
            
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

    func blurCountUpdated(_ sender: UITapGestureRecognizer) {
        self.blurButton.isEnabled = self.canBlur
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
                
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.blurCountUpdated(_:)))
                faceBox.addGestureRecognizer(gestureRecognizer)
                
                self.imgView.addSubview(faceBox)
                self.faceGrids.append(faceBox)
            }
        }
    }
}
