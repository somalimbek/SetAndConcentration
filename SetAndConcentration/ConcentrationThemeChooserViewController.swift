//
//  ConcentrationThemeChooserViewController.swift
//  SetAndConcentration
//
//  Created by Limbek Soma on 2019. 12. 06..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {

    let themes = [
        "Halloween": ConcentrationTheme(name: "Halloween", emojies: "🦇😱🙀😈🎃👻🍭🍬🍎", backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), cardBackColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), textColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)),
        "Animals": ConcentrationTheme(name: "Animals", emojies: "🐶🐱🐭🐹🐰🦊🐻🐼🐨", backgroundColor: #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), cardBackColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
        "Fruits": ConcentrationTheme(name: "Fruits", emojies: "🍏🍎🍐🍊🍋🍌🍉🍇🍓", backgroundColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), cardBackColor: #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
        "Sports": ConcentrationTheme(name: "Sports", emojies: "⚽️🏀🏈⚾️🥎🎾🏐🥏🎱", backgroundColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), cardBackColor: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
        "Faces": ConcentrationTheme(name: "Faces", emojies: "😀😅😊🤩🤪🤓🥳🤯🤠", backgroundColor: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), cardBackColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
        "People": ConcentrationTheme(name: "People", emojies: "👮‍♀️👩‍🍳👩‍🏫👷‍♂️👨‍🚒💂‍♂️🕵️‍♂️👩‍⚕️👩‍🚀", backgroundColor: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), cardBackColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        splitViewController?.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let cvc = secondaryViewController as? ConcentrationViewController {
            if cvc.theme == nil {
                return true
            }
        }
        return false
    }
    
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    private var lastSeguedToConcentrationViewController: ConcentrationViewController?
    
    @IBAction func changeTheme(_ sender: Any) {
        if let cvc = splitViewDetailConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
            }
        } else if let cvc = lastSeguedToConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
            }
            navigationController?.pushViewController(cvc, animated: true)
        } else {
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Theme" {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                if let cvc = segue.destination as? ConcentrationViewController {
                    cvc.theme = theme
                    lastSeguedToConcentrationViewController = cvc
                }
            }
        }
    }

}
