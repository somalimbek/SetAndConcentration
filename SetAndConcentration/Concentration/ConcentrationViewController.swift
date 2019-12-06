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
        didSet {
            updateViewFromModel()
        }
    }
    
    var themeNumber = 0
    var emojiChoices = [String]()
    var emoji = [Int:String]()
    
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
        newGame()
    }
    
    // MARK: Handle New Game Touch Behavior
    
    @IBAction func newGame() {
        themeNumber = themes.count.arc4random
        
        view.backgroundColor = themes[themeNumber].backgroundColor
        for button in cardButtons {
            button.backgroundColor = themes[themeNumber].cardBackColor
        }
        
        themeLabel.textColor = themes[themeNumber].textColor
        scoreLabel.textColor = themes[themeNumber].textColor
        flipCountLabel.textColor = themes[themeNumber].textColor
        newGameButton.setTitleColor(themes[themeNumber].textColor, for: UIControl.State.normal)
        
        themeLabel.text = "Theme: \(themes[themeNumber].name)"
        
        emoji.removeAll()
        emojiChoices = themes[themeNumber].emojies
        game = ConcentrationGame(numberOfPairsOfCards: numberOfPairsOfCards)
    }
    
    // MARK: Handle Card Touch Behavior
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("chosen card was not in cardButtons")
        }
    }
    
    func updateViewFromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ?  #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0) : themes[themeNumber].cardBackColor
            }
        }
        flipCountLabel.text = "Flips: \(game.flipCount)"
        scoreLabel.text = "Score: \(game.score)"
    }
    
    func emoji(for card: ConcentrationCard) -> String {
        if emoji[card.identifier] == nil, emojiChoices.count > 0 {
            emoji[card.identifier] = emojiChoices.remove(at: emojiChoices.count.arc4random)
        }
        return emoji[card.identifier] ?? "?"
    }
    
    let themes = [
        ConcentrationTheme(name: "Halloween", emojies: ["🦇","😱","🙀","😈","🎃","👻","🍭","🍬","🍎"], backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), cardBackColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), textColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)),
        ConcentrationTheme(name: "Animals", emojies: ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐨"], backgroundColor: #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), cardBackColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
        ConcentrationTheme(name: "Fruits", emojies: ["🍏","🍎","🍐","🍊","🍋","🍌","🍉","🍇","🍓"], backgroundColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), cardBackColor: #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
        ConcentrationTheme(name: "Sports", emojies: ["⚽️","🏀","🏈","⚾️","🥎","🎾","🏐","🥏","🎱"], backgroundColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), cardBackColor: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
        ConcentrationTheme(name: "Faces", emojies: ["😀","😅","😊","🤩","🤪","🤓","🥳","🤯","🤠"], backgroundColor: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), cardBackColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
        ConcentrationTheme(name: "People", emojies: ["👮‍♀️","👩‍🍳","👩‍🏫","👷‍♂️","👨‍🚒","💂‍♂️","🕵️‍♂️","👩‍⚕️","👩‍🚀"], backgroundColor: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), cardBackColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
    ]
    
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
