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
        didSet { scoreLabel.text = "Sets: \(self.score)" }
    }
    
    lazy var deck = CardView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        newGame()
        configureDeck()
    }
    
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @objc @IBAction func dealThreeMoreCards() {
        if game.deckCount >= 3 {
            if game.areSelectedCardsAMatch {
                let matchedCardsIndices = game.selectedCardsIndices
                game.dealNewCards()
                for index in matchedCardsIndices {
                    updateCardViewFromModel(at: index)
                }
            } else {
                game.dealNewCards()
                gameTable.addThreeMoreCardViews()
                for index in game.cardsOnTable.indices.suffix(3) {
                    updateCardViewFromModel(at: index)
                }
                addTapGestureRecognizers()
            }
        }
    }
        
    @IBOutlet weak var gameTable: GameTableView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealThreeMoreCards))
            swipe.direction = [.down]
            gameTable.addGestureRecognizer(swipe)
        }
    }
    
    @IBAction func newGame() {
        game = SetGame()
        for _ in 1...4 { game.dealNewCards() }
        
        gameTable.newGame()
        
        for index in gameTable.cardViews.indices {
            updateCardViewFromModel(at: index)
        }
        
        addTapGestureRecognizers()
    }
    
    @objc func touchCardView(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            if let card = sender.view as? CardView {
                if let index = gameTable.cardViews.firstIndex(of: card) {
                    if game.areSelectedCardsAMatch {
                        let matchedCardsIndices = game.matchedCardsIndices
                        var cardsToRemove = [CardView]()
                        game.selectedCardsIndices.forEach { cardsToRemove.append(gameTable.cardViews[$0]) }
                        
                        cardsToRemove.forEach { animateDisappearanceOfCardView($0) }
                        
                        let timerTimeInterval = Constants.durationOfDisappearanceOfCardView + Constants.delayOfDisappearanceOfCardView
                        Timer.scheduledTimer(withTimeInterval: timerTimeInterval, repeats: false) { timer in
                            if self.game.deckCount < 3 {
                                cardsToRemove.forEach { self.gameTable.removeCardView($0) }
                                self.game.selectCard(at: index)
                            } else {
                                self.game.selectCard(at: index)
                                matchedCardsIndices.forEach { self.updateCardViewFromModel(at: $0) }
                            }
                        }
                        
                    } else {
                        game.selectCard(at: index)
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
            for index in gameTable.cardViews.indices {
                updateCardViewFromModel(at: index)
            }
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
    
    private func updateCardViewFromModel(at index: Int) {
        if let rawValue = CardView.NumberOfShapes(rawValue: game.cardsOnTable[index].numberOfShapes.rawValue) {
            gameTable.cardViews[index].numberOfShapes = rawValue
        } else {
            fatalError("SetViewController.dealThreeMoreCards(): could not set numberOfShapes property of card at: \(index).")
        }
        if let rawValue = CardView.Shape(rawValue: game.cardsOnTable[index].shape.rawValue) {
            gameTable.cardViews[index].shape = rawValue
        } else {
            fatalError("SetViewController.dealThreeMoreCards(): could not set shape property of card at: \(index).")
        }
        if let rawValue = CardView.Shading(rawValue: game.cardsOnTable[index].shading.rawValue) {
            gameTable.cardViews[index].shading = rawValue
        } else {
            fatalError("SetViewController.dealThreeMoreCards(): Could not set shading property of card at: \(index).")
        }
        if let rawValue = CardView.Color(rawValue: game.cardsOnTable[index].color.rawValue) {
            gameTable.cardViews[index].color = rawValue
        } else {
            fatalError("SetViewController.dealThreeMoreCards(): Could not set color property of card at: \(index).")
        }
    }
    
    private func configureDeck() {
        dealButton.addSubview(deck)
        deck.isUserInteractionEnabled = false
        deck.layer.isOpaque = false
        deck.frame = dealButton.frame
        deck.isFaceUp = false
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
}

extension SetViewController {
    struct Constants {
        static let durationOfDisappearanceOfCardView = 0.6
        static let delayOfDisappearanceOfCardView = 0.0
    }
}
