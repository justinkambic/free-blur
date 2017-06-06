//
//  CustomBlur.swift
//  free-blur
//
//  Created by Justin Kambic on 6/5/17.
//  Copyright © 2017 Justin Kambic. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreImage
import UIKit

func processPixels(in image: UIImage) -> UIImage? {
    guard let inputCGImage = image.cgImage else {
        print("unable to get cgImage")
        return nil
    }
    let colorSpace       = CGColorSpaceCreateDeviceRGB()
    let width            = inputCGImage.width
    let height           = inputCGImage.height
    let bytesPerPixel    = 4
    let bitsPerComponent = 8
    let bytesPerRow      = bytesPerPixel * width
    let bitmapInfo       = RGBA32.bitmapInfo
    
    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
        print("unable to create context")
        return nil
    }
    context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    guard let buffer = context.data else {
        print("unable to get context data")
        return nil
    }
    
    let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
    
    let blurMat = GaussMat()
    
    for row in 0 ..< Int(height) {
        for column in 0 ..< Int(width) {
            let offset = row * width + column
            
            //if 20 < column && column < 600 && 30 < row && row < 900 {
                
            let curPixel = pixelBuffer[offset]
            
            var skipMat : [[Bool]] = Array(repeating: Array(repeating: Bool(), count: blurMat.matWidth), count: blurMat.matHeight)
            var selectionMat : [[RGBA32]] = Array(repeating: Array(repeating: RGBA32(), count: blurMat.matWidth), count: blurMat.matHeight)
            
            for bRow in 0 ..< blurMat.mat.count {
                for bCol in 0 ..< blurMat.mat[bRow].count {
                    // bRow = 0, 0 < mat.center.y, (0 - 4) = -4
                    // bRow = 1, 1 < mat.center.y, (1 - 4) = -3
                    // bRow = 4, 4 = mat.centery.y, 4
                    // bRow = 5, 5 > mat.center.y, (5 - 4) = 1
                    let rowMod = bRow - blurMat.matCenterY
                    let colMod = bCol - blurMat.matCenterX
                    
                    let selIndex = (row + rowMod) * width + (column + colMod)
                    
                    if selIndex > 0 && selIndex < Int(height) * Int(width) {
                        let selPixel = pixelBuffer[selIndex]
                        selectionMat[bRow][bCol] = selPixel
                    }
                    else {
                        skipMat[bRow][bCol] = true
                    }
                }
            }
            
            //if (row > 2 && ((row + 1) * width + (column + 1)) < height * width) {
            
                /*let toBlur = [
                    pixelBuffer[(row - 1) * width + (column - 1)],
                    pixelBuffer[(row - 1) * width + column],
                    pixelBuffer[(row - 1) * width + (column + 1)],
                    pixelBuffer[row * width + (column - 1)],
                    pixelBuffer[row * width + column],
                    pixelBuffer[row * width + (column + 1)],
                    pixelBuffer[(row + 1) * width + (column - 1)],
                    pixelBuffer[(row + 1) * width + column],
                    pixelBuffer[(row + 1) * width + (column + 1)],
                ]*/
                
                /*let topLeft = pixelBuffer[(row - 1) * width + (column - 1)]
                let top = pixelBuffer[(row - 1) * width + column]
                let topRight = pixelBuffer[(row - 1) * width + (column + 1)]
                let midLeft = pixelBuffer[row * width + (column - 1)]
                let mid = pixelBuffer[row * width + column]
                let midRight = pixelBuffer[row * width + (column + 1)]
                let bottomLeft = pixelBuffer[(row + 1) * width + (column - 1)]
                let bottom = pixelBuffer[(row + 1) * width + column]
                let bottomRight = pixelBuffer[(row + 1) * width + (column + 1)]*/
                
            let blurredPixel = curPixel.blurPixel(neighborMat: selectionMat, gaussMat: blurMat, skipMat: skipMat)
            
            pixelBuffer[offset] = blurredPixel
            //}
            /*if pixelBuffer[offset] == .black {
                pixelBuffer[offset] = .red
            }*/
        }
    }
    
    let outputCGImage = context.makeImage()!
    let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
    
    return outputImage
}

struct RGBA32: Equatable {
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
    
    func blurPixel(neighborMat: [[RGBA32]], gaussMat: GaussMat, skipMat: [[Bool]]) -> RGBA32 {
        var redTotal : UInt32 = 0
        var greenTotal : UInt32 = 0
        var blueTotal : UInt32 = 0
        var divisor : Float = 0.0
        
        for row in 0 ..< gaussMat.mat.count {
            for col in 0 ..< gaussMat.mat[row].count {
                let neighbor = neighborMat[row][col]
                
                if skipMat[row][col] { continue }
                
                let kernelModifier = gaussMat.mat[row][col]
                
                redTotal += UInt32(Float(neighbor.redComponent) * kernelModifier)
                greenTotal += UInt32(Float(neighbor.greenComponent) * kernelModifier)
                blueTotal += UInt32(Float(neighbor.blueComponent) * kernelModifier)
                divisor += kernelModifier
            }
        }
        
        let bRed = divisor == 0.0 ? 0 : UInt8(Float(redTotal) / divisor)
        let bGreen = divisor == 0.0 ? 0 : UInt8(Float(greenTotal) / divisor)
        let bBlue = divisor == 0.0 ? 0 : UInt8(Float(blueTotal) / divisor)
        
        return RGBA32(red: bRed, green: bGreen, blue: bBlue, alpha: self.alphaComponent)
    }
    
    static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
    static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
    static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
    static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
    static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
    static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
    static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
    static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
    
    static func *(left: RGBA32, right: Float) -> RGBA32 {
        var result = UInt32(Float(left.color) * right)
        result |= 255
        return RGBA32(color: result)
    }
    
    static func +(left: RGBA32, right: RGBA32) -> RGBA32 {
        var result = UInt32(left.color + right.color)
        result |= 255
        return RGBA32(color: result)
    }
}

struct GaussMat {
    private var _mat : Array<Array<Float>>
    
    
    var mat : Array<Array<Float>> {
        return self._mat
    }
    
    var matWidth : Int {
        return self._mat[0].count
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
    
    // TODO: write code to allow for custom stdev
    init() {
        self._mat = [
            /*[0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067],
            [0.00002292, 0.00078634, 0.00655965, 0.01330373, 0.00655965, 0.00078634, 0.00002292],
            [0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117],
            [0.00038771, 0.01330373, 0.11098164, 0.22508352, 0.11098164, 0.01330373, 0.00038771],
            [0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117],
            [0.00002292, 0.00078634, 0.00655965, 0.01330373, 0.00655965, 0.00078634, 0.00002292],
            [0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067]*/
            [0.18, 0.35, 0.18],
            [0.35, 0.6, 0.35],
            [0.18, 0.35, 0.18]
        ]
    }
}
