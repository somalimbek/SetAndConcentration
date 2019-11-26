//
//  SetGame.swift
//  SetHomework
//
//  Created by Limbek Soma on 2019. 10. 09..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import Foundation

struct SetGame {
    private var deck = Array(calling: { Card() }, count: 81).shuffled()
    var cardsOnTable = [Card]()
    var selectedCardsIndices = [Int]()
    var matchedCardsIndices = [Int]()
    
    var deckCount: Int {
        return deck.count
    }
    
    var areSelectedCardsAMatch: Bool {
        if selectedCardsIndices.count < 3 {
            return false
        } else {
            let firstCard = cardsOnTable[selectedCardsIndices[0]]
            let secondCard = cardsOnTable[selectedCardsIndices[1]]
            let thirdCard = cardsOnTable[selectedCardsIndices[2]]
            
            var isMatch = Card.NumberOfShapes.allEqual(firstCard.numberOfShapes, secondCard.numberOfShapes, thirdCard.numberOfShapes) || Card.NumberOfShapes.allUnequal(firstCard.numberOfShapes, secondCard.numberOfShapes, thirdCard.numberOfShapes)
            isMatch = isMatch && (Card.Shape.allEqual(firstCard.shape, secondCard.shape, thirdCard.shape) || Card.Shape.allUnequal(firstCard.shape, secondCard.shape, thirdCard.shape))
            isMatch = isMatch && (Card.Shading.allEqual(firstCard.shading, secondCard.shading, thirdCard.shading) || Card.Shading.allUnequal(firstCard.shading, secondCard.shading, thirdCard.shading))
            isMatch = isMatch && (Card.Color.allEqual(firstCard.color, secondCard.color, thirdCard.color) || Card.Color.allUnequal(firstCard.color, secondCard.color, thirdCard.color))
            
            return isMatch
        }
    }
    
    mutating func selectCard(at index: Int) {
        if selectedCardsIndices.count < 3 {
            if selectedCardsIndices.contains(index) {
                selectedCardsIndices.removeAll(where: { $0 == index })
            } else {
                selectedCardsIndices.append(index)
            }
            if areSelectedCardsAMatch {
                matchedCardsIndices.append(contentsOf: selectedCardsIndices)
            }
        } else {
            if areSelectedCardsAMatch {
                let selectedCard = cardsOnTable[index]
                let cardWasSelected = selectedCardsIndices.contains(index)
                if deckCount >= 3 {
                    dealNewCards()
                    selectedCardsIndices.removeAll()
                    if !cardWasSelected {
                        selectedCardsIndices.append(index)
                    }
                } else {
                    removeSelectedCardsFromTable()
                    selectedCardsIndices.removeAll()
                    if !cardWasSelected {
                        selectedCardsIndices.append(cardsOnTable.firstIndex(where: { $0 == selectedCard })!)
                    }
                }
            } else {
                selectedCardsIndices.removeAll()
                selectedCardsIndices.append(index)
            }
        }
    }
    
    mutating func removeSelectedCardsFromTable() {
        selectedCardsIndices.sorted().reversed().forEach { cardsOnTable.remove(at: $0) }
    }
    
    mutating func dealNewCards() {
        if deck.count >= 3 {
            if areSelectedCardsAMatch {
                for index in selectedCardsIndices {
                    cardsOnTable[index] = deck.removeFirst()
                }
                matchedCardsIndices.removeAll(where: { selectedCardsIndices.contains($0)} )
                selectedCardsIndices.removeAll()
            } else {
                cardsOnTable.append(contentsOf: deck[0..<3])
                deck.removeFirst(3)
            }
        }
    }
    
    mutating func reShuffleCardsOnTable() {
        var selectedCards = [Card]()
        for index in selectedCardsIndices {
            selectedCards.append(cardsOnTable[index])
        }
        if areSelectedCardsAMatch {
            if deckCount >= 3{
                dealNewCards()
            } else {
                removeSelectedCardsFromTable()
            }
        }
        selectedCardsIndices.removeAll(keepingCapacity: true)
        cardsOnTable.shuffle()
        
        for card in selectedCards {
            if let cardIndex = cardsOnTable.firstIndex(of: card) {
                selectedCardsIndices.append(cardIndex)
            }
        }
    }
}

extension Equatable {
    static func allEqual(_ first: Self, _ second: Self, _ third: Self) -> Bool {
        return first == second && second == third
    }

    static func allUnequal(_ first: Self, _ second: Self, _ third: Self) -> Bool {
        return first != second && first != third && second != third
    }
}

extension Array {
    init(calling: () -> Element, count: Int) {
        self.init()
        for _ in 0..<count {
            self.append(calling())
        }
    }
}
