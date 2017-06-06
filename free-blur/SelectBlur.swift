//
//  SelectBlur.swift
//  free-blur
//
//  Created by Justin Kambic on 6/3/17.
//  Copyright © 2017 Justin Kambic. All rights reserved.
//

import UIKit
import CoreImage
import Foundation

class SelectBlurView : UIView
{
    var isBlurringFace = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        //gesture.delegate = self
        self.addGestureRecognizer(gesture)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        NSLog("in touches began")
        if isBlurringFace {
            self.subviews[0].removeFromSuperview()
            self.isBlurringFace = false
        }
        else {
            let blurViewRatio = 0.9
            let viewBounds = self.bounds
            let smaller = self.bounds.insetBy(dx: 2.15, dy: 2.15)
            let containerOrigin = self.bounds.origin
            let widthCenter = self.bounds.width * 0.5
            let heightCenter = self.bounds.height * 0.5
            let containerCenter = CGPoint(x: containerOrigin.x + widthCenter, y: containerOrigin.y + heightCenter)
            let bvBounds = self.bounds.insetBy(dx: self.bounds.origin.x * 0.5, dy: self.bounds.origin.y * 0.5)
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            
            let blurView = UIVisualEffectView()
            //blurView.frame = CGRect(x: self.bounds.origin.x * 1.3, y: self.bounds.origin.y * 1.3, width: self.bounds.width * 0.9, height: self.bounds.height * 0.9)
            blurView.frame = smaller
            //blurView.layer.cornerRadius = blurView.frame.size.width/2.0
            blurView.clipsToBounds = true
            blurView.alpha = 1.0
            self.isBlurringFace = true
            self.addSubview(blurView)
            blurView.effect = blurEffect
            let op = blurView.isOpaque
            NSLog("Done")
        }
    }
    
    func viewTapped(_ sender:UITapGestureRecognizer) {
        NSLog("caught a touch brosef")
    }
}
