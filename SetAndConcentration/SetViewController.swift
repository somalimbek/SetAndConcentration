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
            dealButton.isEnabled = !(game.deckCount < 3)
            dealButton.alpha = game.deckCount<3 ? 0 : 1
            score = game.score
        }
    }
    
    var score = 0 {
        didSet {
            if score == 1 {
                scoreLabel.text = "\(self.score) Set"
            } else {
                scoreLabel.text = "\(self.score) Sets"
            }
        }
    }
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    
    var matchedPileCenterConvertedToView: CGPoint {
        return stackViewForDealAndScore.convert(matchedPile.center, to: view)
    }
    
    lazy var cardFlyawayBehavior = CardFlyawayBehavior(in: self.animator, pointToFlyTo: self.matchedPileCenterConvertedToView)
    
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
                var cardViewsToAnimate = [CardView]()
                game.selectedCardsIndices.forEach { cardViewsToAnimate.append(gameTable.cardViews[$0]) }
                game.dealNewCards()
                animateDealingOutCardViews(cardViewsToAnimate)
            } else {
                game.dealNewCards()
                gameTable.addThreeMoreCardViews()
                let cardViewToAnimate = gameTable.cardViews.suffix(3)
                animateDealingOutCardViews(Array(cardViewToAnimate))
                addTapGestureRecognizers()
            }
        }
    }
        
    @IBAction func newGame() {
        game = SetGame()
        for _ in 1...4 { game.dealNewCards() }
        deck.isHidden = false
        matchedPile.isHidden = true
        
        let timeToWait: TimeInterval
        
        if gameTable.cardViews.isEmpty {
            timeToWait = 0.0
        } else {
            gameTable.cardViews.forEach { animateFlyAwayForCardView($0) }
            timeToWait = Constants.timeToWaitForMatchedCardsToFlyAway
        }

        Timer.scheduledTimer(withTimeInterval: timeToWait, repeats: false) { _ in
            
            self.gameTable.newGame()
            self.addTapGestureRecognizers()
            self.animateDealingOutCardViews(self.gameTable.cardViews)
        }
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
                        
                        cardViewsToAnimate.forEach { animateFlyAwayForCardView($0) }
                        
                        let timeToWait = Constants.timeToWaitBeforeDealingAutomatically
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
            print("Shuffle not implemented")
//            game.reShuffleCardsOnTable()
//            if gameTable.cardViews.count > game.cardsOnTable.count {
//                let numberOfCardViewsToRemove = gameTable.cardViews.count - game.cardsOnTable.count
//                gameTable.cardViews.suffix(numberOfCardViewsToRemove).forEach { gameTable.removeCardView($0) }
//            }
//
//            gameTable.cardViews.forEach { updateCardViewFromModel($0) }
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
        deck.frame = dealButton.frame
        deck.isFaceUp = false
    }
    
    private func configureMathcedPile() {
        stackViewForDealAndScore.addSubview(matchedPile)
        stackViewForDealAndScore.sendSubviewToBack(matchedPile)
        matchedPile.isUserInteractionEnabled = false
        matchedPile.frame = scoreLabel.frame
        matchedPile.isFaceUp = false
        matchedPile.isHidden = true
    }
    
    private func animateFlyAwayForCardView(_ cardViewToFlyAway: CardView) {
        let tempCardView = CardView(copyFrom: cardViewToFlyAway)
        gameTable.addSubview(tempCardView)
        cardViewToFlyAway.alpha = 0
        
        cardFlyawayBehavior.addItem(tempCardView)
        
        Timer.scheduledTimer(withTimeInterval: Constants.timeToWaitForMatchedCardsToFlyAway, repeats: false) { _ in
            UIView.transition(
                with: tempCardView,
                duration: Constants.durationOfFlippingOverCardView,
                options: [.transitionFlipFromRight],
                animations: {
                    tempCardView.isFaceUp = false
                    let transform = CGAffineTransform.identity.rotated(by: -(.pi/2))
                    tempCardView.transform = transform
                    let matchedPileBoundsConvertedToGameTable = self.stackViewForDealAndScore.convert(self.matchedPile.bounds, to: self.gameTable)
                    tempCardView.bounds = matchedPileBoundsConvertedToGameTable.applying(transform)
            },
                completion: { _ in
                    self.cardFlyawayBehavior.removeItem(tempCardView)
                    tempCardView.removeFromSuperview()
                    self.matchedPile.isHidden = self.score == 0
            }
            )
        }
    }
    
    private func animateDealingOutCardView(_ cardViewToAnimate: CardView) {
        updateCardViewFromModel(cardViewToAnimate)
        let originalFrame = cardViewToAnimate.frame
        let transform = CGAffineTransform.identity.rotated(by: -(.pi/2))
        cardViewToAnimate.transform = transform
        cardViewToAnimate.frame = stackViewForDealAndScore.convert(deck.frame, to: gameTable)
        cardViewToAnimate.alpha = 1
        cardViewToAnimate.isFaceUp = false
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: Constants.durationOfDealingOutCardView,
            delay: Constants.delayOfDealingOutCardView,
            options: [],
            animations: {
                cardViewToAnimate.transform = transform.rotated(by: .pi/2)
                cardViewToAnimate.frame = originalFrame
        },
            completion: { _ in
                UIView.transition(
                    with: cardViewToAnimate,
                    duration: Constants.durationOfFlippingOverCardView,
                    options: [.transitionFlipFromLeft],
                    animations: {
                        cardViewToAnimate.isFaceUp = true
                }
                )
        }
        )
    }
    
    private func animateDealingOutCardViews(_ cardViewsToAnimate: [CardView]) {
        var tempCardViews = cardViewsToAnimate
        animateDealingOutCardView(tempCardViews.removeFirst())
        Timer.scheduledTimer(withTimeInterval: Constants.timeToWaitBetweenDealingOutCards, repeats: true) { timer in
            if self.game.deckCount == 0, tempCardViews.count == 1 {
                self.deck.isHidden = true
            }
            self.animateDealingOutCardView(tempCardViews.removeFirst())
            if tempCardViews.count == 0 { timer.invalidate() }
        }
    }
}

extension SetViewController {
    struct Constants {
        static let durationOfFlyingCardViewToMatchedPile = CardFlyawayBehavior.Constants.timeToWaitForMatchedCardsToFlyAround + 1.5
        static let delayOfFlyingCardViewToMatchedPile = 0.0
        static let timeToWaitForMatchedCardsToFlyAway = durationOfFlyingCardViewToMatchedPile + delayOfFlyingCardViewToMatchedPile

        static let durationOfDealingOutCardView = 0.3
        static let delayOfDealingOutCardView = 0.0
 
        static let durationOfFlippingOverCardView = 0.7
        
        static let timeToWaitBetweenDealingOutCards = 0.1
        
        static let timeToWaitBeforeDealingAutomatically = 0.5
    }
}
