//
//  SetCardView.swift
//  SetHomeworkCustomView
//
//  Created by Limbek Soma on 2019. 10. 29..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import UIKit

class GameTableView: UIView {
    
    override var bounds: CGRect {
        didSet { grid.frame = self.bounds }
    }

    var grid = Grid(layout: .aspectRatio(5.0/8.0)) {
        didSet { updateCardFrames() }
    }
    
    var cards = [CardView]()
    
    func addCard() { addCards(count: 1) }
    
    func addThreeMoreCards() { addCards(count: 3) }
    
    func addCards(count numberOfCardsToAdd: Int) {
        assert(numberOfCardsToAdd > 0, "GameTableView.addCards(count:): count must be a positivee number")
        
        let newCountOfCardsArray = cards.count + numberOfCardsToAdd
        
        for _ in 1...numberOfCardsToAdd {
            let newCard = CardView(frame: CGRect.zero)
            newCard.layer.isOpaque = false
            cards.append(newCard)
            addSubview(newCard)
        }
        if newCountOfCardsArray > grid.cellCount {
            grid.cellCount = newCountOfCardsArray
        }
    }
    
    func removeCards(indexesOfCardsToRemove indexes: Set<Int>) {
        for index in Array(indexes.sorted().reversed()) {
            cards[index].removeFromSuperview()
            cards.remove(at: index)
        }
        grid.cellCount = cards.count
    }
    
    func newGame() {
        if cards.count > 12 {
            removeCards(indexesOfCardsToRemove: Set<Int>(cards.indices.suffix(from: 12)))
        } else if cards.count < 12 {
            let numberOfCardsToAdd = 12 - cards.count
            addCards(count: numberOfCardsToAdd)
        }
    }
    
    func updateCardFrames(withDuration duration: TimeInterval = Constants.defaultAnimationDuration, delay: TimeInterval = Constants.defaultAnimationDelay) {
        cards.forEach {
            let card = $0
            if let index = cards.firstIndex(of: $0) {
                if let frame = grid[index] {
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: duration,
                        delay: delay,
                        options: [.curveEaseInOut],
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
}

extension GameTableView {
    struct Constants {
        static let defaultAnimationDuration = 0.3
        static let defaultAnimationDelay = 0.0
    }
}
