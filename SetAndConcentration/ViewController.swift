//
//  ViewController.swift
//  SetHomeWorkDrawing
//
//  Created by Limbek Soma on 2019. 10. 30..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var game = SetGame() {
        didSet {
            updateCardsBorders()
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
                gameTable.addThreeMoreCards()
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
        
        for index in gameTable.cards.indices {
            updateCardViewFromModel(at: index)
        }
        
        addTapGestureRecognizers()
    }
    
    @objc func touchCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            if let card = sender.view as? CardView {
                if let index = gameTable.cards.firstIndex(of: card) {
                    if game.areSelectedCardsAMatch {
                        if game.deckCount < 3 {
                            var cardsToRemove = [CardView]()
                            game.selectedCardsIndices.forEach { cardsToRemove.append(gameTable.cards[$0]) }
                            gameTable.removeCards(cardsToRemove)
                            game.selectCard(at: index)
                        } else {
                            let matchedCardsIndices = game.matchedCardsIndices
                            game.selectCard(at: index)
                            matchedCardsIndices.forEach { updateCardViewFromModel(at: $0) }
                        }
                    } else {
                        game.selectCard(at: index)
                    }
                } else {
                    fatalError("ViewController.touchCard(_:): could not find touched card in playingTable.cards.")
                }
            } else {
                fatalError("Could not downcast sender.view to CardView.")
            }
        default:
            break
        }
    }
    
    @IBAction func reShuffleCardsOnTable(_ sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .ended:
            game.reShuffleCardsOnTable()
            if gameTable.cards.count > game.cardsOnTable.count {
                let numberOfCardsToRemove = gameTable.cards.count - game.cardsOnTable.count
                gameTable.removeCards(gameTable.cards.suffix(numberOfCardsToRemove))
            }
            for index in gameTable.cards.indices {
                updateCardViewFromModel(at: index)
            }
        default:
            break
        }
    }
    
    private func addTapGestureRecognizers() {
        gameTable.cards.forEach {
            let card = $0
            if card.gestureRecognizers == nil {
                let touch = UITapGestureRecognizer(target: self, action: #selector(touchCard(_:)))
                card.addGestureRecognizer(touch)
            }
        }
    }
    
    private func updateCardsBorders() {
        gameTable.cards.forEach { $0.removeBorder() }
        if game.areSelectedCardsAMatch {
            game.selectedCardsIndices.forEach { gameTable.cards[$0].addBorder(color: UIColor.green.cgColor) }
        } else {
            if game.selectedCardsIndices.count == 3 {
                game.selectedCardsIndices.forEach { gameTable.cards[$0].addBorder(color: UIColor.red.cgColor) }
            } else {
                game.selectedCardsIndices.forEach { gameTable.cards[$0].addBorder(color: UIColor.blue.cgColor) }
            }
        }
    }
    
    private func updateCardViewFromModel(at index: Int) {
        if let rawValue = CardView.NumberOfShapes(rawValue: game.cardsOnTable[index].numberOfShapes.rawValue) {
            gameTable.cards[index].numberOfShapes = rawValue
        } else {
            fatalError("ViewController.dealThreeMoreCards(): could not set numberOfShapes property of card at: \(index).")
        }
        if let rawValue = CardView.Shape(rawValue: game.cardsOnTable[index].shape.rawValue) {
            gameTable.cards[index].shape = rawValue
        } else {
            fatalError("ViewController.dealThreeMoreCards(): could not set shape property of card at: \(index).")
        }
        if let rawValue = CardView.Shading(rawValue: game.cardsOnTable[index].shading.rawValue) {
            gameTable.cards[index].shading = rawValue
        } else {
            fatalError("ViewController.dealThreeMoreCards(): Could not set shading property of card at: \(index).")
        }
        if let rawValue = CardView.Color(rawValue: game.cardsOnTable[index].color.rawValue) {
            gameTable.cards[index].color = rawValue
        } else {
            fatalError("ViewController.dealThreeMoreCards(): Could not set color property of card at: \(index).")
        }
    }
    
    private func configureDeck() {
        dealButton.addSubview(deck)
        deck.isUserInteractionEnabled = false
        deck.layer.isOpaque = false
        deck.frame = dealButton.frame
        deck.isFaceUp = false
    }
}

