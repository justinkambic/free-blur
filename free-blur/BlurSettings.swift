//
//  Settings.swift
//  free-blur
//
//  Created by Justin Kambic on 6/30/17.
//  Copyright © 2017 Justin Kambic. All rights reserved.
//

import Foundation
import UIKit

enum SettingsError : Error {
    case SettingValueOutsideAcceptedRange
    case ProvidedInvalidShapeValue
}

class BlurSettings {
    private let numPassesKey = "numPasses"
    private let diameterKey = "diameter"
    private let blurShapeKey = "blurShape"
    private let userDefaults = UserDefaults.standard
    
    public var maxNumPasses : Int {
        return 5
    }

    public var minNumPasses : Int {
        return 1
    }

    public var numPassesDefault : Int {
        return 2
    }
    
    public var maxDiameter : Int {
        return 15
    }

    public var minDiameter : Int {
        return 2
    }

    public var diameterDefault : Int {
        return 3
    }
    
    public var blurShapeDefault : String {
        return "circle"
    }
    
    func setDefaults() throws {
        if self.userDefaults.object(forKey: self.numPassesKey) == nil {
            try self.setNumPasses(numPasses: self.numPassesDefault)
        }

        if self.userDefaults.object(forKey: self.diameterKey) == nil {
            try self.setDiameter(diameter: self.diameterDefault)
        }
        
        if self.userDefaults.object(forKey: self.blurShapeKey) == nil {
            try self.setBlurShape(shape: self.blurShapeDefault)
        }
    }
    
    func getBlurShape() -> String! {
        let shape = userDefaults.string(forKey: self.blurShapeKey)
        if shape != "circle" && shape != "square" {
            return self.blurShapeDefault
        }
        return shape
    }
    
    func setBlurShape(shape: String!) throws {
        guard shape == "circle" || shape == "square" else {
            throw SettingsError.ProvidedInvalidShapeValue
        }
        self.userDefaults.set(shape, forKey: self.blurShapeKey)
    }
    
    func getNumPasses() -> Int {
        let numPasses = userDefaults.integer(forKey: self.numPassesKey)
        if numPasses >= self.minNumPasses && numPasses <= self.maxNumPasses {
            return numPasses
        }
        return self.numPassesDefault
    }
    
    func setNumPasses(numPasses: Int!) throws {
        guard numPasses >= self.minNumPasses else {
            throw SettingsError.SettingValueOutsideAcceptedRange
        }
        guard numPasses <= self.maxNumPasses else {
            throw SettingsError.SettingValueOutsideAcceptedRange
        }
        self.userDefaults.set(numPasses, forKey: self.numPassesKey)
    }
    
    func getDiameter() -> Int {
        let diameter = userDefaults.integer(forKey: self.diameterKey)
        
        if diameter >= self.minDiameter && diameter <= self.maxDiameter {
            return diameter
        }
        return self.diameterDefault
    }
    
    func setDiameter(diameter: Int!) throws {
        guard diameter >= self.minDiameter else {
            throw SettingsError.SettingValueOutsideAcceptedRange
        }
        guard diameter <= self.maxDiameter else {
            throw SettingsError.SettingValueOutsideAcceptedRange
        }
        if diameter % 2 == 0 {
            self.userDefaults.set(diameter - 1, forKey: self.diameterKey)
        } else {
            self.userDefaults.set(diameter, forKey: self.diameterKey)
        }
    }
}
