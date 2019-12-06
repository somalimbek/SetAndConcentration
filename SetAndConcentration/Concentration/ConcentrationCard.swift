//
//  Card.swift
//  ConcentrationHomework1
//
//  Created by Limbek Soma on 2019. 09. 30..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import Foundation

struct ConcentrationCard {
    
    var isFaceUp = false
    var isMatched = false
    var isSeen = false
    var identifier: Int
    
    static var identifierFactory = 0
    
    static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    init() {
        self.identifier = ConcentrationCard.getUniqueIdentifier()
    }
}
