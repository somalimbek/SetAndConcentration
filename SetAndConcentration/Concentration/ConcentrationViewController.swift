//
//  ViewController.swift
//  ConcentrationHomework1
//
//  Created by Limbek Soma on 2019. 09. 30..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController {
    
    var game: ConcentrationGame! {
        didSet { updateViewFromModel() }
    }
    
    let defaultTheme = ConcentrationTheme(name: "Halloween", emojies: "🦇😱🙀😈🎃👻🍭🍬🍎", backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), cardBackColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), textColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))

    
    var theme: ConcentrationTheme? {
        didSet {
            if theme != oldValue, let theme = theme {
                emojiChoices = theme.emojies
                emoji = [:]
                newGame(self)
                updateViewFromModel()
            }
        }
    }
    
    var emojiChoices = "🦇😱🙀😈🎃👻🍭🍬🍎"
    var emoji = [Int: String]()
    
    var numberOfPairsOfCards: Int {
        return (cardButtons.count + 1) / 2
    }

    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var flipCountLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    
    @IBOutlet var cardButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newGame(self)
    }
    
    // MARK: Handle New Game Touch Behavior
    
    @IBAction func newGame(_ sender: Any) {
        let currentTheme = theme ?? defaultTheme
        view.backgroundColor = currentTheme.backgroundColor
        for button in cardButtons {
            button.backgroundColor = currentTheme.cardBackColor
        }
        
        themeLabel.textColor = currentTheme.textColor
        scoreLabel.textColor = currentTheme.textColor
        flipCountLabel.textColor = currentTheme.textColor
        newGameButton.setTitleColor(currentTheme.textColor, for: UIControl.State.normal)

        emoji.removeAll()
        emojiChoices = currentTheme.emojies
        
        themeLabel.text = "Theme: \(currentTheme.name)"

        if sender is UIViewController {
            if game == nil {
                game = ConcentrationGame(numberOfPairsOfCards: numberOfPairsOfCards)
            }
        } else if sender is UIButton {
            game = ConcentrationGame(numberOfPairsOfCards: numberOfPairsOfCards)
        }
    }
    
    // MARK: Handle Card Touch Behavior
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            if let game = game {
                game.chooseCard(at: cardNumber)
                updateViewFromModel()
            } else {
                game = ConcentrationGame(numberOfPairsOfCards: numberOfPairsOfCards)
                game.chooseCard(at: cardNumber)
                updateViewFromModel()
            }
        } else {
            print("chosen card was not in cardButtons")
        }
    }
    
    func updateViewFromModel() {
        if cardButtons != nil {
            for index in cardButtons.indices {
                let button = cardButtons[index]
                let card = game.cards[index]
                if card.isFaceUp {
                    button.setTitle(emoji(for: card), for: UIControl.State.normal)
                    button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                } else {
                    button.setTitle("", for: UIControl.State.normal)
                    button.backgroundColor = card.isMatched ?  #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0) : theme?.cardBackColor ?? defaultTheme.cardBackColor
                }
            }
        }
        if flipCountLabel != nil, scoreLabel != nil {
            flipCountLabel.text = "Flips: \(game.flipCount)"
            scoreLabel.text = "Score: \(game.score)"
        }
    }
    
    func emoji(for card: ConcentrationCard) -> String {
        if emoji[card.identifier] == nil, emojiChoices.count > 0 {
            let stringIndex = emojiChoices.index(emojiChoices.startIndex, offsetBy: emojiChoices.count.arc4random)
            emoji[card.identifier] = String(emojiChoices.remove(at: stringIndex))
        }
        return emoji[card.identifier] ?? "?"
    }
}

struct ConcentrationTheme: Equatable {
    let name: String
    let emojies: String
    let backgroundColor: UIColor
    let cardBackColor: UIColor
    let textColor: UIColor
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(-self)))
        } else {
            return 0
        }
    }
}
