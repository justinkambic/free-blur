//
//  RGBAPixel.swift
//  free-blur
//
//  Created by Justin Kambic on 6/8/17.
//

import CoreGraphics

struct RGBAPixel: Equatable {
    private var color: UInt32
    
    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
    }
    
    init(color: UInt32) {
        self.color = color
    }
    
    init() {
        self.color = 0
    }
    
    func blurPixel(neighborMat: [[RGBAPixel]], gaussMat: GaussMat, skipMat: [[Bool]]) -> RGBAPixel {
        var redTotal : UInt32 = 0
        var greenTotal : UInt32 = 0
        var blueTotal : UInt32 = 0
        
        for row in 0 ..< gaussMat.mat.count {
            for col in 0 ..< gaussMat.mat[row].count {
                let neighbor = neighborMat[row][col]
                
                if skipMat[row][col] { continue }
                
                let kernelModifier = gaussMat.mat[row][col]
                
                redTotal += UInt32(Float(neighbor.redComponent) * kernelModifier)
                greenTotal += UInt32(Float(neighbor.greenComponent) * kernelModifier)
                blueTotal += UInt32(Float(neighbor.blueComponent) * kernelModifier)
            }
        }
        
        return RGBAPixel(red: UInt8(redTotal), green: UInt8(greenTotal), blue: UInt8(blueTotal), alpha: self.alphaComponent)
    }
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func == (lhs: RGBAPixel, rhs: RGBAPixel) -> Bool {
        return lhs.color == rhs.color
    }
    
    static func * (left: RGBAPixel, right: Float) -> RGBAPixel {
        var result = UInt32(Float(left.color) * right)
        result |= 255
        return RGBAPixel(color: result)
    }
    
    static func + (left: RGBAPixel, right: RGBAPixel) -> RGBAPixel {
        var result = UInt32(left.color + right.color)
        result |= 255
        return RGBAPixel(color: result)
    }
}
