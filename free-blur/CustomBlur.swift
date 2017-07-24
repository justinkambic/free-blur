//
//  CustomBlur.swift
//  free-blur
//
//  Created by Justin Kambic on 6/5/17.
//

import Foundation
import CoreGraphics
import CoreImage
import UIKit

func blurImage(in image: UIImage, targets: [CGRect], numPasses: Int, diameter: Int) -> UIImage? {
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
    let bitmapInfo       = RGBAPixel.bitmapInfo
    
    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
        print("unable to create context")
        return nil
    }
    context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    guard let buffer = context.data else {
        print("unable to get context data")
        return nil
    }
    
    let pixelBuffer = buffer.bindMemory(to: RGBAPixel.self, capacity: width * height)
    
    let blurMat = GaussMat(diameter: diameter, weight: 50)

    var i = 1
    while i <= numPasses {
        i += 1
        for target in targets {
            let blurRange = Circle(container: target)
            for row in Int(target.minY) ..< Int(target.minY + target.height) {
                for column in Int(target.minX) ..< Int(target.minX + target.width) {
                    let offset = row * width + column

                    let curPixel = pixelBuffer[offset]
                    
                    if !blurRange.containsPixel(xp: column, yp: row) { continue }
                    
                    var skipMat : [[Bool]] = Array(repeating: Array(repeating: Bool(), count: blurMat.matWidth), count: blurMat.matHeight)
                    var selectionMat : [[RGBAPixel]] = Array(repeating: Array(repeating: RGBAPixel(), count: blurMat.matWidth), count: blurMat.matHeight)
                    
                    for bRow in 0 ..< blurMat.mat.count {
                        for bCol in 0 ..< blurMat.mat[bRow].count {
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

                    let blurredPixel = curPixel.blurPixel(neighborMat: selectionMat, gaussMat: blurMat, skipMat: skipMat)
                    
                    pixelBuffer[offset] = blurredPixel
                }
            }
        }
    }

    let outputCGImage = context.makeImage()!
    let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
    
    return outputImage
}
