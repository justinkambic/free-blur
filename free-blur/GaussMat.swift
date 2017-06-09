//
//  GaussMat.swift
//  free-blur
//
//  Created by Justin Kambic on 6/8/17.
//

import Foundation

struct GaussMat {
    private var _mat : [[Float]]
    
    
    var mat : [[Float]] {
        return self._mat
    }
    
    var matWidth : Int {
        if self._mat.count > 0 {
            return self._mat[0].count
        }
        return -1
    }
    
    var matHeight : Int {
        return self._mat.count
    }
    
    var matCenterX : Int {
        return self.matWidth / 2 + 1
    }
    
    var matCenterY : Int {
        return self.matHeight / 2 + 1
    }
    
    init(diameter: Int, weight: Float) {
        self._mat = Array(repeating: Array(repeating: Float(), count:diameter), count: diameter)
        var matSum : Float = 0
        
        let e = 1.0 / (2.0 * Float.pi * pow(weight, 2))
        
        let radius = Int(diameter / 2)
        for y in -radius ... radius {
            for x in -radius ... radius {
                let distance = (Float((x * x) + (y * y))) / (2 * pow(weight, 2))
                
                self._mat[y + radius][x + radius] =
                    e * exp(-distance)
                
                matSum += self._mat[y + radius][x + radius]
            }
        }
        
        for y in 0 ..< self._mat.count {
            for x in 0 ..< self._mat.count {
                self._mat[y][x] *= (1.0 / matSum)
            }
        }
    }
}
