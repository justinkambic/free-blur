//
//  SelectBlur.swift
//  free-blur
//
//  Created by Justin Kambic on 6/3/17.
//

import UIKit
import CoreImage

class BlurSelectionView : UIView
{
    var shouldBlurFace = false
    var ciFaceCoords : CGRect
    
    init(frame: CGRect, ciFaceCoords: CGRect) {
        self.ciFaceCoords = ciFaceCoords
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.yellow.cgColor
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if self.shouldBlurFace {
            self.shouldBlurFace = false
            self.backgroundColor = UIColor.clear
        }
        else {
            self.shouldBlurFace = true
            self.backgroundColor = UIColor(red: 0.239, green: 0.863, blue: 0.265, alpha: 0.685)
        }
    }
}
