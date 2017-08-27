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
            errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(errorAlert, animated: true)
        }
        else {
            let alert = UIAlertController(title: "Saved!", message: "Your blurred photo was saved.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .default, handler: {
                (alert: UIAlertAction!) in self.navigationController?.popToRootViewController(animated: true)
            })
            
            alert.addAction(dismissAction)
            present(alert, animated: true)
        }
    }
}
