//
//  SaveImageViewController.swift
//  free-blur
//
//  Created by Justin Kambic on 6/13/17.
//  Copyright © 2017 Justin Kambic. All rights reserved.
//

import Foundation
import UIKit

class SaveImageViewController : UIViewController {
    
    var imageToSave : UIImage = UIImage()
    
    @IBOutlet weak var imgViewToSave: UIImageView!
    @IBOutlet weak var saveImageNavBar: UINavigationItem!
    
    
    override func viewDidLoad() {
        if let saveButton = saveImageNavBar.rightBarButtonItem {
            saveButton.target = self
            saveButton.action = #selector(saveImage)
        }

        self.imgViewToSave.isUserInteractionEnabled = false
        self.imgViewToSave.contentMode = .scaleAspectFit
        self.imgViewToSave.frame = self.view.bounds
        self.imgViewToSave.image = imageToSave
    }
    
    func saveImage(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(self.imageToSave, self, #selector(self.imageSaved), nil)
    }
    
    func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let er = error {
            let errorAlert = UIAlertController(title: "Error Saving Photo", message: er.localizedDescription, preferredStyle: .alert)
            present(errorAlert, animated: true)
        }
        else {
            //self.lblSaved.isHidden = false
            /*UIView.animate(withDuration: 0.65, animations: {
                self.lblSaved.alpha = 0
            }, completion: { (finished: Bool) in
                self.lblSaved.isHidden = true
                self.lblSaved.alpha = 1.0
            })*/
        }
    }
}
