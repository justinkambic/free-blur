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
    var counter: Int {
        get {
            return self.counter
        }
        set(newCounter) {
            self.counter = newCounter
            self.setProgress(self.progressValue, animated: self.animated)
        }
    }
    
    var progressValue: Float {
        get {
            return Float(self.counter) / 100.0
        }
    }
    
    var animated: Bool {
        get {
            return self.progressValue != 0
        }
    }
    
    func updateCounter(value: Int) {
        self.counter = value
    }
}
