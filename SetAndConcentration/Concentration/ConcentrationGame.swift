//
//  Concentration.swift
//  ConcentrationHomework1
//
//  Created by Limbek Soma on 2019. 09. 30..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import Foundation

class ConcentrationGame {
    
    var cards = [ConcentrationCard]()
    var flipCount = 0
    var score = 0
    var indexOfOneAndOnlyFaceUpCard: Int?
    let dateOfStartingTheGame = Date()
    var dateOfPreviousMatch: Date?
    
    func chooseCard(at index: Int) {
        if !cards[index].isMatched, !cards[index].isFaceUp {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                if cards[matchIndex].identifier == cards[index].identifier {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    score += 2
                    
                    let timeElapsed = abs(dateOfPreviousMatch?.timeIntervalSinceNow ?? dateOfStartingTheGame.timeIntervalSinceNow)
                    if timeElapsed < 5.0 {
                        score += 1
                    }
                    dateOfPreviousMatch = Date()
                } else {
                    if cards[matchIndex].isSeen {
                        score -= 1
                    }
                    if cards[index].isSeen {
                        score -= 1
                    }
                }
                cards[matchIndex].isSeen = true
                cards[index].isSeen = true
                indexOfOneAndOnlyFaceUpCard = nil
            } else {
                for flipDownIndex in cards.indices {
                    cards[flipDownIndex].isFaceUp = false
                }
                indexOfOneAndOnlyFaceUpCard = index
            }
            cards[index].isFaceUp = true
            flipCount += 1
        }
    }
    
    init(numberOfPairsOfCards: Int) {
        for _ in 1...numberOfPairsOfCards {
            let card = ConcentrationCard()
            cards += [card, card]
        }
        cards.shuffle()
    }
}
