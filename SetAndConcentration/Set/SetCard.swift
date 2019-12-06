//
//  Card.swift
//  SetHomework
//
//  Created by Limbek Soma on 2019. 10. 09..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import Foundation

struct SetCard: Equatable {
    let numberOfShapes: NumberOfShapes
    let shape: Shape
    let shading: Shading
    let color: Color
    
    init() {
        let identifier = SetCard.makeUniqueIdentifier()
        numberOfShapes = NumberOfShapes(rawValue: (identifier % 3) + 1)!
        shape = Shape(rawValue: (identifier / 3) % 3)!
        shading = Shading(rawValue: (identifier / 9) % 3)!
        color = Color(rawValue: (identifier / 27) % 3)!
    }
        
    private static var nextIdentifier = -1
    
    private static func makeUniqueIdentifier() -> Int {
        nextIdentifier += 1
        return nextIdentifier
    }
    
    enum NumberOfShapes: Int {
        case one = 1, two, three
    }
    
    enum Shape: Int {
        case first, second, third
    }
    
    enum Shading: Int {
        case first, second, third
    }
    
    enum Color: Int {
        case first, second, third
    }
}
