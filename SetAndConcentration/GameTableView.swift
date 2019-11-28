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
    
    var cardViews = [CardView]()
    
    func addCardView() { addCardViews(count: 1) }
    
    func addThreeMoreCardViews() { addCardViews(count: 3) }
    
    func addCardViews(count numberOfCardViewsToAdd: Int) {
        assert(numberOfCardViewsToAdd > 0, "GameTableView.addCards(count:): count must be a positivee number")
        
        let newCountOfCardsArray = cardViews.count + numberOfCardViewsToAdd
        
        for _ in 1...numberOfCardViewsToAdd {
            let newCard = CardView(frame: CGRect.zero)
            newCard.layer.isOpaque = false
            cardViews.append(newCard)
            addSubview(newCard)
        }
        if newCountOfCardsArray > grid.cellCount {
            grid.cellCount = newCountOfCardsArray
        }
    }
    
    func removeCardView(_ cardViewToRemove: CardView) {
        cardViewToRemove.removeFromSuperview()
        cardViews.removeAll { $0 === cardViewToRemove }
        grid.cellCount = cardViews.count
    }
    
    func newGame() {
        if cardViews.count > 12 {
            cardViews.suffix(from: 12).forEach { removeCardView($0) }
        } else if cardViews.count < 12 {
            let numberOfCardsToAdd = 12 - cardViews.count
            addCardViews(count: numberOfCardsToAdd)
        }
    }
    
    func updateCardFrames(withDuration duration: TimeInterval = Constants.updateCardFramesDuration, delay: TimeInterval = Constants.updateCardFramesDelay) {
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
}

extension GameTableView {
    struct Constants {
        static let updateCardFramesDuration = 0.3
        static let updateCardFramesDelay = 0.0
    }
}
