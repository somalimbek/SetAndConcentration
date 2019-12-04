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
        didSet {
            if isCreatingNewGame {
                updateCardFrames()
            } else {
                updateCardFramesAnimated()
            }
        }
    }
    
    var cardViews = [CardView]()
    var isCreatingNewGame = false
    
    func addCardView() { addCardViews(count: 1) }
    
    func addThreeMoreCardViews() { addCardViews(count: 3) }
    
    func addCardViews(count numberOfCardViewsToAdd: Int) {
        assert(numberOfCardViewsToAdd > 0, "GameTableView.addCards(count:): count must be a positivee number")
        
        let newCountOfCardsArray = cardViews.count + numberOfCardViewsToAdd
        
        if newCountOfCardsArray > grid.cellCount {
            grid.cellCount = newCountOfCardsArray
        }
        
        for _ in 1...numberOfCardViewsToAdd {
            if let frame = grid[cardViews.count] {
                let newCard = CardView(frame: frame)
                newCard.alpha = 0
                cardViews.append(newCard)
                addSubview(newCard)
            }
        }
    }
    
    func removeCardView(_ cardViewToRemove: CardView) {
        cardViewToRemove.removeFromSuperview()
        cardViews.removeAll { $0 === cardViewToRemove }
        grid.cellCount = cardViews.count
    }
    
    func newGame() {
        isCreatingNewGame = true
        if cardViews.count > 12 {
            cardViews.suffix(from: 12).forEach { removeCardView($0) }
        } else if cardViews.count < 12 {
            let numberOfCardsToAdd = 12 - cardViews.count
            addCardViews(count: numberOfCardsToAdd)
        }
        isCreatingNewGame = false
    }
    
    func updateCardFramesAnimated(withDuration duration: TimeInterval = Constants.durationOfUpdatingCardFrames, delay: TimeInterval = Constants.delayOfUpdatingCardFrames) {
        cardViews.forEach {
            let card = $0
            if let index = cardViews.firstIndex(of: $0) {
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
    
    func updateCardFrames() {
        cardViews.forEach {
            let card = $0
            if let index = cardViews.firstIndex(of: $0) {
                if let frame = grid[index] {
                    card.frame = frame
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
        static let durationOfUpdatingCardFrames = 0.3
        static let delayOfUpdatingCardFrames = 0.0
    }
}
