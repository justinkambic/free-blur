//
//  Circle.swift
//  free-blur
//
//  Created by Justin Kambic on 6/8/17.
//

import UIKit

struct Circle {
    let diameter : Int
    let radius : Int
    let x : Int
    let y : Int
    
    init(container: CGRect) {
        self.diameter = container.height > container.width ? Int(container.height) : Int(container.width)
        self.radius = diameter / 2
        self.x = Int(container.minX + container.width / 2)
        self.y = Int(container.minY + container.height / 2)
    }
    
    func containsPixel(xp: Int, yp: Int) -> Bool {
        return (xp - x) * (xp - x) + (yp - y) * (yp - y) <= self.radius * self.radius
    }
}
