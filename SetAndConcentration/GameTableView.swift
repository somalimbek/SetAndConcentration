//
//  SetCardView.swift
//  SetHomeworkCustomView
//
//  Created by Limbek Soma on 2019. 10. 29..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import UIKit

class GameTableView: UIView {

    lazy var grid = Grid(layout: .aspectRatio(5.0/8.0), frame: self.bounds)
    
    var cards = [CardView]()
    
    func addCard() { addCards(count: 1) }
    
    func addThreeMoreCards() { addCards(count: 3) }
    
    func addCards(count numberOfCardsToAdd: Int) {
        assert(numberOfCardsToAdd > 0, "GameTableView.addCards(count:): count must be a positivee number")
        
        let newCountOfCardsArray = cards.count + numberOfCardsToAdd
        if newCountOfCardsArray > grid.cellCount {
            grid.cellCount = newCountOfCardsArray
            updateCardFrames()
        }
        for _ in 1...numberOfCardsToAdd {
            if let frame = grid[cards.count] {
                let newCard = CardView(frame: frame)
                newCard.layer.isOpaque = false
                cards.append(newCard)
                addSubview(newCard)
            } else {
                fatalError("Index out of range.")
            }
        }
    }
    
    func removeCards(indexesOfCardsToRemove indexes: Set<Int>) {
        for index in Array(indexes.sorted().reversed()) {
            cards[index].removeFromSuperview()
            cards.remove(at: index)
        }
        grid.cellCount = cards.count
        updateCardFrames()
    }
    
    func newGame() {
        if cards.count > 12 {
            removeCards(indexesOfCardsToRemove: Set<Int>(cards.indices.suffix(from: 12)))
        } else if cards.count < 12 {
            let numberOfCardsToAdd = 12 - cards.count
            addCards(count: numberOfCardsToAdd)
        }
    }
    
    private func updateCardFrames() {
        cards.forEach {
            let card = $0
            if let index = cards.firstIndex(of: $0) {
                if let frame = grid[index] {
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: Constants.defaultAnimationDuration,
                        delay: Constants.defaultAnimationDelay,
                        options: [],
                        animations: {
                            card.frame = frame
                    }
                    )
                } else {
                    fatalError("Index out of range.")
                }
            } else {
                fatalError("card not found in cards.")
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        grid.frame = bounds
        updateCardFrames()
    }
}

extension GameTableView {
    struct Constants {
        static let defaultAnimationDuration = 0.6
        static let defaultAnimationDelay = 0.0
    }
}
