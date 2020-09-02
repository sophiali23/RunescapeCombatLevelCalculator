//
//  RSCombatLevelCalculatorViewController.swift
//  Runescape 3 Tools
//
//  Created by Sophia Li on 2020-06-24.
//  Copyright © 2020 Sophia Li. All rights reserved.
//

import UIKit
import Alamofire

class RSCombatLevelCalculatorViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var attackLevelTextField: UITextField!
    @IBOutlet weak var strengthLevelTextField: UITextField!
    @IBOutlet weak var magicLevelTextField: UITextField!
    @IBOutlet weak var defenceLevelTextField: UITextField!
    @IBOutlet weak var rangedLevelTextField: UITextField!
    @IBOutlet weak var constitutionLevelTextField: UITextField!
    @IBOutlet weak var prayerLevelTextField: UITextField!
    @IBOutlet weak var summoningLevelTextField: UITextField!
    @IBOutlet weak var currentLevelLabel: UILabel!
    @IBOutlet weak var combatLevelLabel: UILabel!
    @IBOutlet weak var neededForNextLevelLabel: UILabel!
    @IBOutlet weak var lookupButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var levelsNeededLabel: UILabel!
    @IBOutlet weak var versionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var calculatorScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var strengthLabel: UILabel!
    @IBOutlet weak var magicLabel: UILabel!
    @IBOutlet weak var defenceLabel: UILabel!
    @IBOutlet weak var rangedLabel: UILabel!
    @IBOutlet weak var constitutionLabel: UILabel!
    @IBOutlet weak var prayerLabel: UILabel!
    @IBOutlet weak var summoningLabel: UILabel!

    var combatLevel: Int = 3
    var attackLevel: Int = 1
    var strengthLevel: Int = 1
    var magicLevel: Int = 1
    var defenceLevel: Int = 1
    var rangedLevel: Int = 1
    var constitutionLevel: Int = 10
    var prayerLevel: Int = 1
    var summoningLevel: Int = 1
    var isRS3: Bool = true
    var version: RuneScapeVersion = .RuneScape3 {
        didSet {
            isRS3 = version == .RuneScape3
        }
    }
    
    enum RuneScapeVersion {
        case RuneScape3
        case OldSchool
    }
    
    enum CombatSkill: Int, CaseIterable {   // Skill IDs
        case attack = 0
        case defence = 1
        case strength = 2
        case constitution = 3
        case ranged = 4
        case prayer = 5
        case magic = 6
        case summoning = 23
    }
    
    override func loadView() {
        super.loadView()
        setNeedsStatusBarAppearanceUpdate()
        let placeholderText = NSAttributedString(string: "Enter RuneScape Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        usernameTextField.attributedPlaceholder = placeholderText
        versionSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        versionSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func fetchUser() {
        let mVal = isRS3 ? "hiscore" : "hiscore_oldschool"
        var url = "https://secure.runescape.com/m=\(mVal)/index_lite.ws?player="
        let player = usernameTextField.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let player = player {
            url += player
        }
        AF.request(url).responseString { response in
            switch response.result {
            case .success(let data):
                if (data.rangeOfCharacter(from: .letters) == nil) {
                    let stats = data.components(separatedBy: "\n")
                    CombatSkill.allCases.forEach {
                        let stat = stats[$0.rawValue + 1].components(separatedBy: ",")
                        let level = Int(stat[1])
                        if let level = level {
                            switch $0 {
                            case .attack:
                                self.attackLevel = level
                                self.attackLevelTextField.text = "\(level)"
                            case .defence:
                                self.defenceLevel = level
                                self.defenceLevelTextField.text = "\(level)"
                            case .strength:
                                self.strengthLevel = level
                                self.strengthLevelTextField.text = "\(level)"
                            case .constitution:
                                self.constitutionLevel = level
                                self.constitutionLevelTextField.text = "\(level)"
                            case .ranged:
                                self.rangedLevel = level
                                self.rangedLevelTextField.text = "\(level)"
                            case .prayer:
                                self.prayerLevel = level
                                self.prayerLevelTextField.text = "\(level)"
                            case .magic:
                                self.magicLevel = level
                                self.magicLevelTextField.text = "\(level)"
                            case .summoning:
                                self.summoningLevel = level
                                self.summoningLevelTextField.text = self.isRS3 ? "\(level)" : "N/A"
                            }
                        }
                    }
                } else {
                    let emptyUsernameMessage = "Please enter a RuneScape username."
                    let playerNotFoundMessage = "The player does not exist, is banned or unranked, or the RuneScape Hiscores service might be unavailable at this time. Please enter the data manually."
                    let alertMessage = (self.usernameTextField.text ?? "").isEmpty ? emptyUsernameMessage : playerNotFoundMessage
                    let alert = UIAlertController(title: "Error Fetching Data", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func lookupButtonPressed(_ sender: UIButton) {
        fetchUser()
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        combatLevelLabel.text = ""
        levelsNeededLabel.text = ""
        switch versionSegmentedControl.selectedSegmentIndex {
        case 0:
            version = .RuneScape3
            summoningLevelTextField.isEnabled = true
            summoningLevelTextField.text = ""
            constitutionLabel.text = "Constitution Level:"
            updateTheme()
        case 1:
            version = .OldSchool
            summoningLevelTextField.isEnabled = false
            summoningLevelTextField.text = "N/A"
            constitutionLabel.text = "Hitpoints Level:"
            updateTheme()
        default:
            break
        }
    }
    
    func updateTheme() {
        let backgroundColour = UIColor(hex: isRS3 ? "#13212eff" : "#28251aff")
        let textAndButtonColour = UIColor(hex: isRS3 ? "#e1bb34ff" : "#c1a771ff")
        let textFieldColour = UIColor(hex: isRS3 ? "#3c494eff" : "#5f523cff")
        
        view.backgroundColor = backgroundColour
        contentView.backgroundColor = backgroundColour
        calculatorScrollView.backgroundColor = backgroundColour
        
        titleLabel.textColor = textAndButtonColour
        lookupButton.backgroundColor = textAndButtonColour
        submitButton.backgroundColor = textAndButtonColour
        attackLabel.textColor = textAndButtonColour
        strengthLabel.textColor = textAndButtonColour
        defenceLabel.textColor = textAndButtonColour
        constitutionLabel.textColor = textAndButtonColour
        rangedLabel.textColor = textAndButtonColour
        magicLabel.textColor = textAndButtonColour
        prayerLabel.textColor = textAndButtonColour
        summoningLabel.textColor = textAndButtonColour
        currentLevelLabel.textColor = textAndButtonColour
        combatLevelLabel.textColor = textAndButtonColour
        neededForNextLevelLabel.textColor = textAndButtonColour
        levelsNeededLabel.textColor = textAndButtonColour
        
        usernameTextField.backgroundColor = textFieldColour
        attackLevelTextField.backgroundColor = textFieldColour
        strengthLevelTextField.backgroundColor = textFieldColour
        defenceLevelTextField.backgroundColor = textFieldColour
        constitutionLevelTextField.backgroundColor = textFieldColour
        rangedLevelTextField.backgroundColor = textFieldColour
        magicLevelTextField.backgroundColor = textFieldColour
        prayerLevelTextField.backgroundColor = textFieldColour
        summoningLevelTextField.backgroundColor = textFieldColour
    }
    
    func isMaxCombat() -> Bool {
        return (isRS3 && self.combatLevel == 138) || (!isRS3 && self.combatLevel == 126)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        combatLevelLabel.text = String(getCombatLevel())
        if (isMaxCombat()) {
            levelsNeededLabel.text = "Nothing, player is max combat."
            return
        }
        let attLvls = attackLevelsNeeded()
        let strLvls = strengthLevelsNeeded()
        let defLvls = defenceLevelsNeeded()
        let hpLvls = constitutionLevelsNeeded()
        let rangedLvls = rangedLevelsNeeded()
        let magicLvls = magicLevelsNeeded()
        let prayerLvls = prayerLevelsNeeded()
        let summLvls = summoningLevelsNeeded()
        let hpTitle = isRS3 ? " Constitution levels" : " Hitpoints levels"
        levelsNeededLabel.text = ((attLvls + attackLevel > 99) ? "" : "\u{2022}   " + String(attLvls) + " Attack levels") +
            ((strLvls + strengthLevel > 99) ? "" : "\n\u{2022}   " + String(strLvls) + " Strength levels") +
            ((defLvls + defenceLevel > 99) ? "" : "\n\u{2022}   " + String(defLvls) + " Defence levels") +
            ((hpLvls + constitutionLevel > 99) ? "" : "\n\u{2022}   " + String(hpLvls) + hpTitle) +
            ((rangedLvls + rangedLevel > 99) ? "" : "\n\u{2022}   " + String(rangedLvls) + " Ranged levels") +
            ((magicLvls + magicLevel > 99) ? "" : "\n\u{2022}   " + String(magicLvls) + " Magic levels") +
            ((prayerLvls + prayerLevel > 99) ? "" : "\n\u{2022}   " + String(prayerLvls) + " Prayer levels") +
            ((summLvls + summoningLevel > 99 || !isRS3) ? "" : "\n\u{2022}   " + String(summLvls) + " Summoning levels")
    }
    
    func strengthLevelsNeeded() -> Int {
        let s = isRS3 ? (summoningLevel / 2) : 0
        let nextLevel = combatLevel + 1
        var y = Double(4 * nextLevel - constitutionLevel - defenceLevel - (prayerLevel / 2) - s) / 1.3
        y = y - Double(attackLevel)
        return Int(ceil(y)) - strengthLevel
    }
    
    func attackLevelsNeeded() -> Int {
        let s = isRS3 ? (summoningLevel / 2) : 0
        let nextLevel = combatLevel + 1
        var y = Double(4 * nextLevel - constitutionLevel - defenceLevel - (prayerLevel / 2) - s) / 1.3
        y = y - Double(strengthLevel)
        return Int(ceil(y)) - attackLevel
    }
    
    func rangedLevelsNeeded() -> Int {
        let z = isRS3 ? 2 : 1.5
        let s = isRS3 ? (summoningLevel / 2) : 0
        let nextLevel = combatLevel + 1
        var y = Double(4 * nextLevel - constitutionLevel - defenceLevel - (prayerLevel / 2) - s) / 1.3
        y = y / z
        return Int(ceil(y)) - rangedLevel
    }
    
    func magicLevelsNeeded() -> Int {
        let z = isRS3 ? 2 : 1.5
        let s = isRS3 ? (summoningLevel / 2) : 0
        let nextLevel = combatLevel + 1
        var y = Double(4 * nextLevel - constitutionLevel - defenceLevel - (prayerLevel / 2) - s) / 1.3
        y = y / z
        return Int(ceil(y)) - magicLevel
    }
    
    func summoningLevelsNeeded() -> Int {
        if (!isRS3) {
            return 1
        }
        let x = max(Double(strengthLevel + attackLevel), Double(magicLevel) * 2, Double(rangedLevel) * 2) * 1.3
        let nextLevel = combatLevel + 1
        var y = Double(4 * nextLevel - defenceLevel - constitutionLevel - (prayerLevel / 2)) - x
        y = ceil(y) * 2
        return Int(ceil(y)) - summoningLevel
    }
    
    func prayerLevelsNeeded() -> Int {
        let z = isRS3 ? 2 : 1.5
        let s = isRS3 ? (summoningLevel / 2) : 0
        let x = max(Double(strengthLevel + attackLevel), Double(magicLevel) * z, Double(rangedLevel) * z) * 1.3
        let nextLevel = combatLevel + 1
        var y = Double(4 * nextLevel - defenceLevel - constitutionLevel - s) - x
        y = ceil(y) * 2
        return Int(ceil(y)) - prayerLevel
    }
    
    func defenceLevelsNeeded() -> Int {
         let z = isRS3 ? 2 : 1.5
         let s = isRS3 ? (summoningLevel / 2) : 0
         let x = max(Double(strengthLevel + attackLevel), Double(magicLevel) * z, Double(rangedLevel) * z) * 1.3
         let nextLevel = combatLevel + 1
         let y = Double(4 * nextLevel - constitutionLevel - (prayerLevel / 2) - s) - x
         return Int(ceil(y)) - defenceLevel
    }
    
    func constitutionLevelsNeeded() -> Int {
        let z = isRS3 ? 2 : 1.5
        let s = isRS3 ? (summoningLevel / 2) : 0
        let x = max(Double(strengthLevel + attackLevel), Double(magicLevel) * z, Double(rangedLevel) * z) * 1.3
        let nextLevel = combatLevel + 1
        let y = Double(4 * nextLevel - defenceLevel - (prayerLevel / 2) - s) - x
        return Int(ceil(y)) - constitutionLevel
    }
    
    func getCombatLevel() -> Int {
        attackLevel = Int(attackLevelTextField.text!) ?? 1
        strengthLevel = Int(strengthLevelTextField.text!) ?? 1
        magicLevel = Int(magicLevelTextField.text!) ?? 1
        defenceLevel = Int(defenceLevelTextField.text!) ?? 1
        rangedLevel = Int(rangedLevelTextField.text!) ?? 1
        constitutionLevel = Int(constitutionLevelTextField.text!) ?? 10
        prayerLevel = Int(prayerLevelTextField.text!) ?? 1
        summoningLevel = Int(summoningLevelTextField.text!) ?? 1
        
        let z = isRS3 ? 2 : 1.5
        let s = isRS3 ? (summoningLevel / 2) : 0
        let x = max(Double(strengthLevel + attackLevel), Double(magicLevel) * z, Double(rangedLevel) * z) * 1.3
        let y = (x + Double(defenceLevel + constitutionLevel + (prayerLevel / 2) + s)) / 4
        self.combatLevel = Int(floor(y))
        return self.combatLevel
    }
}
