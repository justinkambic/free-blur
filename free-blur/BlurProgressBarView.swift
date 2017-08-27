//
//  BlurProgressBarView.swift
//  free-blur
//
//  Created by Justin Kambic on 8/25/17.
//  Copyright © 2017 Justin Kambic. All rights reserved.
//

import Foundation
import UIKit

class BlurProgressBarView : UIProgressView, AsyncCounter
{
    var progressValue: Float = 0.0
    
    var animated: Bool {
        get {
            return self.progressValue != 0.0
        }
    }
    
    func updateCounter(value: Float) {
        self.progressValue = value
        self.setProgress(self.progressValue, animated: self.animated)
    }
}
