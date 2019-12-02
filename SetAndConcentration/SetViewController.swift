//
//  ViewController.swift
//  SetHomeWorkDrawing
//
//  Created by Limbek Soma on 2019. 10. 30..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    
    var game = SetGame() {
        didSet {
            updateCardViewsBorders()
            dealButton.isEnabled = game.deckCount >= 3
            score = game.score
            deck.isHidden = game.deckCount == 0
        }
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Sets: \(self.score)"
            if oldValue == 0 {
                matchedPile.isHidden = self.score == 0
            }
        }
    }
    
    var deck = CardView()
    var matchedPile = CardView()
    
    @IBOutlet weak var stackViewForDealAndScore: UIStackView!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var gameTable: GameTableView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealThreeMoreCards))
            swipe.direction = [.down]
            gameTable.addGestureRecognizer(swipe)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        newGame()
        configureDeck()
        configureMathcedPile()
    }
    
    @objc @IBAction func dealThreeMoreCards() {
        if game.deckCount >= 3 {
            if game.areSelectedCardsAMatch {
                let selectedCardsIndices = game.selectedCardsIndices
                var cardViewsToAnimate = [CardView]()
                selectedCardsIndices.forEach { cardViewsToAnimate.append(gameTable.cardViews[$0]) }
                game.dealNewCards()
                
                cardViewsToAnimate.forEach {
                    updateCardViewFromModel($0)
                    animateAppearanceOfCardView($0)
                }
            } else {
                game.dealNewCards()
                gameTable.addThreeMoreCardViews()
                
                let timeToWait = GameTableView.Constants.durationOfUpdatingCardFrames + GameTableView.Constants.delayOfUpdatingCardFrames
                Timer.scheduledTimer(withTimeInterval: timeToWait, repeats: false) { _ in
                    let cardViewsToAnimate = self.gameTable.cardViews.suffix(3)
                    cardViewsToAnimate.forEach {
                        self.updateCardViewFromModel($0)
                        self.animateAppearanceOfCardView($0)
                    }
                    self.addTapGestureRecognizers()
                }
            }
        }
    }
        
    @IBAction func newGame() {
        game = SetGame()
        for _ in 1...4 { game.dealNewCards() }
        
        let timeToWait: TimeInterval
        
        if gameTable.cardViews.isEmpty {
            timeToWait = 0.0
        } else {
            gameTable.cardViews.forEach { animateDisappearanceOfCardView($0) }
            timeToWait = Constants.durationOfDisappearanceOfCardView + Constants.delayOfDisappearanceOfCardView
        }

        Timer.scheduledTimer(withTimeInterval: timeToWait, repeats: false) { _ in
            self.gameTable.newGame()
            self.addTapGestureRecognizers()
            self.gameTable.cardViews.forEach {
                self.updateCardViewFromModel($0)
                self.animateAppearanceOfCardView($0)
            }
            

        }
        
//        gameTable.newGame()
        
//        gameTable.cardViews.forEach {
//            updateCardViewFromModel($0)
//            animateAppearanceOfCardView($0)
//        }
//
//        addTapGestureRecognizers()
    }
    
    @objc func touchCardView(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            if let touchedCardView = sender.view as? CardView {
                if let index = gameTable.cardViews.firstIndex(of: touchedCardView) {
                    game.selectCard(at: index)
                    
                    if game.areSelectedCardsAMatch {
                        let selectedCardsIndices = game.selectedCardsIndices
                        var cardViewsToAnimate = [CardView]()
                        selectedCardsIndices.forEach { cardViewsToAnimate.append(gameTable.cardViews[$0]) }
                        
                        cardViewsToAnimate.forEach { animateDisappearanceOfCardView($0) }
                        
                        let timeToWait = Constants.durationOfDisappearanceOfCardView + Constants.delayOfDisappearanceOfCardView
                        Timer.scheduledTimer(withTimeInterval: timeToWait, repeats: false) { _ in
                            if self.game.deckCount < 3 {
                                cardViewsToAnimate.forEach { self.gameTable.removeCardView($0) }
                            } else {
                                self.dealThreeMoreCards()
                            }
                        }
                    }
                } else {
                    fatalError("SetViewController.touchCardView(_:): could not find touched card in playingTable.cards.")
                }
            } else {
                fatalError("SetViewController.touchCardView(_:): could not downcast sender.view to CardView.")
            }
        default:
            break
        }
    }
    
    @IBAction func reShuffleCardsOnTable(_ sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .ended:
            game.reShuffleCardsOnTable()
            if gameTable.cardViews.count > game.cardsOnTable.count {
                let numberOfCardViewsToRemove = gameTable.cardViews.count - game.cardsOnTable.count
                gameTable.cardViews.suffix(numberOfCardViewsToRemove).forEach { gameTable.removeCardView($0) }
            }
            
            gameTable.cardViews.forEach { updateCardViewFromModel($0) }
        default:
            break
        }
    }
    
    private func addTapGestureRecognizers() {
        gameTable.cardViews.forEach {
            let cardView = $0
            if cardView.gestureRecognizers == nil {
                let touch = UITapGestureRecognizer(target: self, action: #selector(touchCardView(_:)))
                cardView.addGestureRecognizer(touch)
            }
        }
    }
    
    private func updateCardViewsBorders() {
        gameTable.cardViews.forEach { $0.removeBorder() }
        if game.areSelectedCardsAMatch {
            game.selectedCardsIndices.forEach { gameTable.cardViews[$0].addBorder(color: UIColor.green.cgColor) }
        } else {
            if game.selectedCardsIndices.count == 3 {
                game.selectedCardsIndices.forEach { gameTable.cardViews[$0].addBorder(color: UIColor.red.cgColor) }
            } else {
                game.selectedCardsIndices.forEach { gameTable.cardViews[$0].addBorder(color: UIColor.blue.cgColor) }
            }
        }
    }
    
    private func updateCardViewFromModel(_ cardViewToUpdate: CardView) {
        if let index = gameTable.cardViews.firstIndex(of: cardViewToUpdate) {
            if let numberOfShapes = CardView.NumberOfShapes(rawValue: game.cardsOnTable[index].numberOfShapes.rawValue) {
                cardViewToUpdate.numberOfShapes = numberOfShapes
            } else {
                fatalError("SetViewController.updateCardViewFromModel(_:): could not set numberOfShapes property of card at: \(index).")
            }
            
            if let shape = CardView.Shape(rawValue: game.cardsOnTable[index].shape.rawValue) {
                cardViewToUpdate.shape = shape
            } else {
                fatalError("SetViewController.updateCardViewFromModel(_:): could not set shape property of card at: \(index).")
            }
            
            if let shading = CardView.Shading(rawValue: game.cardsOnTable[index].shading.rawValue) {
                cardViewToUpdate.shading = shading
            } else {
                fatalError("SetViewController.updateCardViewFromModel(_:): Could not set shading property of card at: \(index).")
            }
            
            if let color = CardView.Color(rawValue: game.cardsOnTable[index].color.rawValue) {
                cardViewToUpdate.color = color
            } else {
                fatalError("SetViewController.updateCardViewFromModel(_:): Could not set color property of card at: \(index).")
            }
        }
    }
    
    private func configureDeck() {
        stackViewForDealAndScore.addSubview(deck)
        stackViewForDealAndScore.sendSubviewToBack(deck)
        deck.isUserInteractionEnabled = false
        deck.layer.isOpaque = false
        deck.frame = dealButton.frame
        deck.isFaceUp = false
    }
    
    private func configureMathcedPile() {
        stackViewForDealAndScore.addSubview(matchedPile)
        stackViewForDealAndScore.sendSubviewToBack(matchedPile)
        matchedPile.isUserInteractionEnabled = false
        matchedPile.layer.isOpaque = false
        matchedPile.frame = scoreLabel.frame
        matchedPile.isFaceUp = false
    }
    
    private func animateDisappearanceOfCardView(_ cardViewToDisappear: CardView) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: Constants.durationOfDisappearanceOfCardView,
            delay: Constants.delayOfDisappearanceOfCardView,
            options: [],
            animations: {
                cardViewToDisappear.alpha = 0
        }
        )
    }
    
    private func animateAppearanceOfCardView(_ cardViewToAppear: CardView) {
        let originalFrame = cardViewToAppear.frame
        let transform = CGAffineTransform.identity.rotated(by: .pi/2)
        cardViewToAppear.transform = transform
        cardViewToAppear.center = stackViewForDealAndScore.convert(deck.center, to: gameTable)
        cardViewToAppear.alpha = 1
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: Constants.durationOfApearanceOfCardView,
            delay: Constants.delayOfApearanceOfCardView,
            options: [],
            animations: {
                cardViewToAppear.transform = transform.rotated(by: .pi/2)
                cardViewToAppear.frame = originalFrame
        }
        )
        
    }
}

extension SetViewController {
    struct Constants {
        static let durationOfDisappearanceOfCardView = 0.3
        static let delayOfDisappearanceOfCardView = 0.0
        
        static let durationOfApearanceOfCardView = durationOfDisappearanceOfCardView
        static let delayOfApearanceOfCardView = delayOfDisappearanceOfCardView
    }
}
