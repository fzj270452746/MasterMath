
import UIKit

class EinstellungenViewController: UIViewController {
    
    private let scrollAnsicht = UIScrollView()
    private let inhaltsAnsicht = UIView()
    private let titelLabel = UILabel()
    private let zuruecksetzenSchaltflaeche = UIButton()
    private let schliessenSchaltflaeche = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        einrichteAnsicht()
    }
    
    private func einrichteAnsicht() {
        view.backgroundColor = .systemBackground
        
        // Titel
        titelLabel.text = "⚙️ Game Guide & Settings"
        titelLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titelLabel.textAlignment = .center
        titelLabel.textColor = .systemPurple
        titelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titelLabel)
        
        // ScrollView
        scrollAnsicht.translatesAutoresizingMaskIntoConstraints = false
        scrollAnsicht.showsVerticalScrollIndicator = true
        view.addSubview(scrollAnsicht)
        
        // InhaltsAnsicht
        inhaltsAnsicht.translatesAutoresizingMaskIntoConstraints = false
        scrollAnsicht.addSubview(inhaltsAnsicht)
        
        // 创建所有内容区域
        erstelleSpielanleitungInhalt()
        
        // Zurücksetzen Button
        zuruecksetzenSchaltflaeche.setTitle("🔄 Reset All Scores", for: .normal)
        zuruecksetzenSchaltflaeche.backgroundColor = .systemRed
        zuruecksetzenSchaltflaeche.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        zuruecksetzenSchaltflaeche.setTitleColor(.white, for: .normal)
        zuruecksetzenSchaltflaeche.layer.cornerRadius = 12
        zuruecksetzenSchaltflaeche.layer.shadowColor = UIColor.black.cgColor
        zuruecksetzenSchaltflaeche.layer.shadowOffset = CGSize(width: 0, height: 2)
        zuruecksetzenSchaltflaeche.layer.shadowRadius = 4
        zuruecksetzenSchaltflaeche.layer.shadowOpacity = 0.3
        zuruecksetzenSchaltflaeche.addTarget(self, action: #selector(allePunktzahlenZuruecksetzen), for: .touchUpInside)
        zuruecksetzenSchaltflaeche.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(zuruecksetzenSchaltflaeche)
        
        // Schließen Button
        schliessenSchaltflaeche.setTitle("✕ Close", for: .normal)
        schliessenSchaltflaeche.backgroundColor = .systemBlue
        schliessenSchaltflaeche.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        schliessenSchaltflaeche.setTitleColor(.white, for: .normal)
        schliessenSchaltflaeche.layer.cornerRadius = 12
        schliessenSchaltflaeche.layer.shadowColor = UIColor.black.cgColor
        schliessenSchaltflaeche.layer.shadowOffset = CGSize(width: 0, height: 2)
        schliessenSchaltflaeche.layer.shadowRadius = 4
        schliessenSchaltflaeche.layer.shadowOpacity = 0.3
        schliessenSchaltflaeche.addTarget(self, action: #selector(schliessen), for: .touchUpInside)
        schliessenSchaltflaeche.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(schliessenSchaltflaeche)
        
        NSLayoutConstraint.activate([
            titelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titelLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titelLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scrollAnsicht.topAnchor.constraint(equalTo: titelLabel.bottomAnchor, constant: 20),
            scrollAnsicht.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollAnsicht.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollAnsicht.bottomAnchor.constraint(equalTo: zuruecksetzenSchaltflaeche.topAnchor, constant: -20),
            
            inhaltsAnsicht.topAnchor.constraint(equalTo: scrollAnsicht.topAnchor),
            inhaltsAnsicht.leadingAnchor.constraint(equalTo: scrollAnsicht.leadingAnchor),
            inhaltsAnsicht.trailingAnchor.constraint(equalTo: scrollAnsicht.trailingAnchor),
            inhaltsAnsicht.bottomAnchor.constraint(equalTo: scrollAnsicht.bottomAnchor),
            inhaltsAnsicht.widthAnchor.constraint(equalTo: scrollAnsicht.widthAnchor),
            
            zuruecksetzenSchaltflaeche.bottomAnchor.constraint(equalTo: schliessenSchaltflaeche.topAnchor, constant: -15),
            zuruecksetzenSchaltflaeche.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            zuruecksetzenSchaltflaeche.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            zuruecksetzenSchaltflaeche.heightAnchor.constraint(equalToConstant: 50),
            
            schliessenSchaltflaeche.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            schliessenSchaltflaeche.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            schliessenSchaltflaeche.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            schliessenSchaltflaeche.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func erstelleSpielanleitungInhalt() {
        var letzteAnsicht: UIView?
        let abstand: CGFloat = 20
        
        // 1. 游戏概述
        let uebersichtKarte = erstelleKarte(
            titel: "🎴 Game Overview",
            inhalt: "Mahjong Math Master is a mathematical puzzle game that combines Mahjong-style tiles with arithmetic operators. Your goal is to select tiles and operators to create an equation that equals the target number!\n\n• Select tiles in order\n• Choose operators (+, -, ×, ÷)\n• Submit to check your answer\n• Earn points and level up!",
            hintergrundFarbe: UIColor.systemPurple.withAlphaComponent(0.1),
            rahmenFarbe: UIColor.systemPurple
        )
        inhaltsAnsicht.addSubview(uebersichtKarte)
        NSLayoutConstraint.activate([
            uebersichtKarte.topAnchor.constraint(equalTo: inhaltsAnsicht.topAnchor, constant: abstand),
            uebersichtKarte.leadingAnchor.constraint(equalTo: inhaltsAnsicht.leadingAnchor, constant: 20),
            uebersichtKarte.trailingAnchor.constraint(equalTo: inhaltsAnsicht.trailingAnchor, constant: -20)
        ])
        letzteAnsicht = uebersichtKarte
        
        // 2. 游戏模式说明
        let modiKarte = erstelleKarte(
            titel: "🎮 Game Modes",
            inhalt: "🎯 SIMPLE MODE\n• 5 tiles per round\n• Use 3-5 tiles to solve\n• Target range: 10-100\n• Perfect for beginners\n• Take your time!\n\n🔥 HARD MODE\n• 10 tiles per round\n• Use 3-6 tiles to solve\n• Target range: 10-100\n• More complex solutions\n• Challenge yourself!\n\n⏱️ TIME MODE\n• 60 seconds countdown\n• 5 tiles per round\n• Solve as many as possible\n• Race against time\n• Test your speed!",
            hintergrundFarbe: UIColor.systemBlue.withAlphaComponent(0.1),
            rahmenFarbe: UIColor.systemBlue
        )
        inhaltsAnsicht.addSubview(modiKarte)
        NSLayoutConstraint.activate([
            modiKarte.topAnchor.constraint(equalTo: letzteAnsicht!.bottomAnchor, constant: abstand),
            modiKarte.leadingAnchor.constraint(equalTo: inhaltsAnsicht.leadingAnchor, constant: 20),
            modiKarte.trailingAnchor.constraint(equalTo: inhaltsAnsicht.trailingAnchor, constant: -20)
        ])
        letzteAnsicht = modiKarte
        
        // 3. 操作说明
        let spielAnleitungKarte = erstelleKarte(
            titel: "📖 How to Play",
            inhalt: "STEP 1: Read the Target\nLook at the top of the screen to see your target number (e.g., Target: 24)\n\nSTEP 2: Select Tiles\n• Tap Mahjong tiles to select them\n• Selected tiles highlight in yellow\n• Each tile shows a number (1-9)\n• Select tiles in the order you want to use them\n\nSTEP 3: Choose Operators\n• Tap operator buttons: + - × ÷\n• Operators are used between tiles\n• You need one less operator than tiles\n  (e.g., 3 tiles = 2 operators)\n\nSTEP 4: Submit\n• Tap the green '✓ Submit' button\n• ✅ Correct: Earn points + fireworks!\n• ❌ Wrong: Try again!\n\nSTEP 5: Continue\n• Each correct answer increases your level\n• New puzzle appears automatically\n• Your score multiplies with each level",
            hintergrundFarbe: UIColor.systemGreen.withAlphaComponent(0.1),
            rahmenFarbe: UIColor.systemGreen
        )
        inhaltsAnsicht.addSubview(spielAnleitungKarte)
        NSLayoutConstraint.activate([
            spielAnleitungKarte.topAnchor.constraint(equalTo: letzteAnsicht!.bottomAnchor, constant: abstand),
            spielAnleitungKarte.leadingAnchor.constraint(equalTo: inhaltsAnsicht.leadingAnchor, constant: 20),
            spielAnleitungKarte.trailingAnchor.constraint(equalTo: inhaltsAnsicht.trailingAnchor, constant: -20)
        ])
        letzteAnsicht = spielAnleitungKarte
        
        // 4. 计算规则
        let rechenregelnKarte = erstelleKarte(
            titel: "🧮 Calculation Rules",
            inhalt: "IMPORTANT: Operations are calculated LEFT to RIGHT!\n\n✓ Example 1:\nTiles: 3, 8\nOperator: ×\nCalculation: 3 × 8 = 24 ✅\n\n✓ Example 2:\nTiles: 2, 3, 4\nOperators: +, ×\nCalculation: 2 + 3 × 4\n= (2 + 3) × 4 (left to right!)\n= 5 × 4\n= 20 ✅\n\n✓ Example 3:\nTiles: 6, 2, 3\nOperators: ×, +\nCalculation: 6 × 2 + 3\n= (6 × 2) + 3\n= 12 + 3\n= 15 ✅\n\n⚠️ Common Mistake:\nDon't use standard math order!\n2 + 3 × 4 is NOT 2 + 12\nIt's (2 + 3) × 4 = 20",
            hintergrundFarbe: UIColor.systemOrange.withAlphaComponent(0.1),
            rahmenFarbe: UIColor.systemOrange
        )
        inhaltsAnsicht.addSubview(rechenregelnKarte)
        NSLayoutConstraint.activate([
            rechenregelnKarte.topAnchor.constraint(equalTo: letzteAnsicht!.bottomAnchor, constant: abstand),
            rechenregelnKarte.leadingAnchor.constraint(equalTo: inhaltsAnsicht.leadingAnchor, constant: 20),
            rechenregelnKarte.trailingAnchor.constraint(equalTo: inhaltsAnsicht.trailingAnchor, constant: -20)
        ])
        letzteAnsicht = rechenregelnKarte
        
        // 5. 麻将牌介绍
        let kachelnKarte = erstelleKarte(
            titel: "🎴 Mahjong Tiles",
            inhalt: "Three beautiful tile colors:\n\n🔴 FREUN (Red Tiles)\nNumbers 1-9 in elegant red design\n\n🔵 JOIRARS (Blue Tiles)\nNumbers 1-9 in beautiful blue style\n\n🟢 SORTIE (Green Tiles)\nNumbers 1-9 in fresh green color\n\nAll tiles function identically - only the appearance differs! Choose any color you like.",
            hintergrundFarbe: UIColor.systemPink.withAlphaComponent(0.1),
            rahmenFarbe: UIColor.systemPink
        )
        inhaltsAnsicht.addSubview(kachelnKarte)
        NSLayoutConstraint.activate([
            kachelnKarte.topAnchor.constraint(equalTo: letzteAnsicht!.bottomAnchor, constant: abstand),
            kachelnKarte.leadingAnchor.constraint(equalTo: inhaltsAnsicht.leadingAnchor, constant: 20),
            kachelnKarte.trailingAnchor.constraint(equalTo: inhaltsAnsicht.trailingAnchor, constant: -20)
        ])
        letzteAnsicht = kachelnKarte
        
        // 6. 得分系统
        let punkteSystemKarte = erstelleKarte(
            titel: "🏆 Scoring System",
            inhalt: "BASE SCORE: 10 points per correct answer\n\nLEVEL MULTIPLIER:\n• Level 1: 10 × 1 = 10 points\n• Level 2: 10 × 2 = 20 points\n• Level 3: 10 × 3 = 30 points\n• And so on...\n\nHIGH SCORES:\n• Each mode saves your best score\n• Check the 🏆 Leaderboard\n• Beat your personal record\n• Compete with yourself!\n\nTIME MODE BONUS:\n• Solve quickly for more rounds\n• Each round adds to your total\n• Higher levels = more points",
            hintergrundFarbe: UIColor.systemYellow.withAlphaComponent(0.1),
            rahmenFarbe: UIColor.systemYellow
        )
        inhaltsAnsicht.addSubview(punkteSystemKarte)
        NSLayoutConstraint.activate([
            punkteSystemKarte.topAnchor.constraint(equalTo: letzteAnsicht!.bottomAnchor, constant: abstand),
            punkteSystemKarte.leadingAnchor.constraint(equalTo: inhaltsAnsicht.leadingAnchor, constant: 20),
            punkteSystemKarte.trailingAnchor.constraint(equalTo: inhaltsAnsicht.trailingAnchor, constant: -20)
        ])
        letzteAnsicht = punkteSystemKarte
        
        // 7. 提示和技巧
        let tippsKarte = erstelleKarte(
            titel: "💡 Tips & Strategies",
            inhalt: "🎯 START SIMPLE\nTry two-tile solutions first (e.g., 3 × 8 = 24)\n\n🧠 THINK BACKWARDS\nStart from the target and work backwards\nTarget 24? Think: 24 = 6 × 4 or 8 × 3\n\n🔢 USE DIVISION WISELY\nDivision can create decimals\nMake sure the result is a whole number!\n\n🔄 USE RESET\nMade a mistake? Tap 'Reset' to start over\nNo penalty for resetting!\n\n🎨 REFRESH TILES\nStuck? Use the refresh button (if available)\nGet a new set of tiles!\n\n⏱️ TIME MODE STRATEGY\nSpeed matters - use familiar patterns\nSkip if stuck - save time!\n\n🎓 PRACTICE MAKES PERFECT\nStart with Simple Mode\nMove to Hard Mode when confident\nChallenge yourself in Time Mode!",
            hintergrundFarbe: UIColor.systemTeal.withAlphaComponent(0.1),
            rahmenFarbe: UIColor.systemTeal
        )
        inhaltsAnsicht.addSubview(tippsKarte)
        NSLayoutConstraint.activate([
            tippsKarte.topAnchor.constraint(equalTo: letzteAnsicht!.bottomAnchor, constant: abstand),
            tippsKarte.leadingAnchor.constraint(equalTo: inhaltsAnsicht.leadingAnchor, constant: 20),
            tippsKarte.trailingAnchor.constraint(equalTo: inhaltsAnsicht.trailingAnchor, constant: -20)
        ])
        letzteAnsicht = tippsKarte
        
        // 8. 完整示例
        let beispielKarte = erstelleKarte(
            titel: "📚 Complete Example",
            inhalt: "Let's solve a puzzle together!\n\n🎯 TARGET: 30\n🎴 AVAILABLE TILES: 2, 3, 4, 5, 6\n\nSOLUTION 1 (Easy - 2 tiles):\nSelect: 5, then 6\nOperator: ×\nCalculation: 5 × 6 = 30 ✅\n\nSOLUTION 2 (Medium - 3 tiles):\nSelect: 2, then 3, then 5\nOperators: +, ×\nCalculation: (2 + 3) × 5 = 25... ❌\nTry again!\n\nSelect: 6, then 5, then 4\nOperators: ×, ÷\nCalculation: (6 × 5) ÷ 4 = 7.5... ❌\n\nSelect: 2, then 4, then 6\nOperators: +, ×\nCalculation: (2 + 4) × 6 = 36... ❌\n\nSelect: 5, then 4, then 2\nOperators: ×, -\nCalculation: (5 × 4) - 2 = 18... ❌\n\nSelect: 6, then 4, then 2\nOperators: ×, +\nCalculation: (6 × 4) + 2 = 26... ❌\n\nSelect: 3, then 4, then 6\nOperators: +, ×\nCalculation: (3 + 4) × 6 = 42... ❌\n\nSelect: 4, then 5, then 2\nOperators: +, ×\nCalculation: (4 + 5) × 2 = 18... ❌\n\nLet's try another approach!\nSelect: 6, then 2, then 3\nOperators: ×, +\nCalculation: (6 × 2) + 3 = 15... ❌\n\nSelect: 3, then 2, then 5\nOperators: ×, ×\nCalculation: (3 × 2) × 5 = 30 ✅\n\nGreat job! 🎉",
            hintergrundFarbe: UIColor.systemIndigo.withAlphaComponent(0.1),
            rahmenFarbe: UIColor.systemIndigo
        )
        inhaltsAnsicht.addSubview(beispielKarte)
        NSLayoutConstraint.activate([
            beispielKarte.topAnchor.constraint(equalTo: letzteAnsicht!.bottomAnchor, constant: abstand),
            beispielKarte.leadingAnchor.constraint(equalTo: inhaltsAnsicht.leadingAnchor, constant: 20),
            beispielKarte.trailingAnchor.constraint(equalTo: inhaltsAnsicht.trailingAnchor, constant: -20)
        ])
        letzteAnsicht = beispielKarte
        
        // 9. 版本信息
        let versionKarte = erstelleKarte(
            titel: "ℹ️ App Information",
            inhalt: "MasterMath\nVersion 1.0\n\n© 2025 MasterMath Game\n\nA mathematical puzzle game that combines the beauty of Mahjong tiles with the challenge of arithmetic!\n\nEnjoy the game and improve your mental math skills! 🧮🎮",
            hintergrundFarbe: UIColor.systemGray.withAlphaComponent(0.1),
            rahmenFarbe: UIColor.systemGray
        )
        inhaltsAnsicht.addSubview(versionKarte)
        NSLayoutConstraint.activate([
            versionKarte.topAnchor.constraint(equalTo: letzteAnsicht!.bottomAnchor, constant: abstand),
            versionKarte.leadingAnchor.constraint(equalTo: inhaltsAnsicht.leadingAnchor, constant: 20),
            versionKarte.trailingAnchor.constraint(equalTo: inhaltsAnsicht.trailingAnchor, constant: -20)
        ])
        letzteAnsicht = versionKarte
        
        // 设置最后的约束
        letzteAnsicht?.bottomAnchor.constraint(equalTo: inhaltsAnsicht.bottomAnchor, constant: -abstand).isActive = true
    }
    
    private func erstelleKarte(titel: String, inhalt: String, hintergrundFarbe: UIColor, rahmenFarbe: UIColor) -> UIView {
        let kartenAnsicht = UIView()
        kartenAnsicht.backgroundColor = hintergrundFarbe
        kartenAnsicht.layer.cornerRadius = 16
        kartenAnsicht.layer.borderWidth = 2
        kartenAnsicht.layer.borderColor = rahmenFarbe.cgColor
        kartenAnsicht.layer.shadowColor = UIColor.black.cgColor
        kartenAnsicht.layer.shadowOffset = CGSize(width: 0, height: 2)
        kartenAnsicht.layer.shadowRadius = 4
        kartenAnsicht.layer.shadowOpacity = 0.1
        kartenAnsicht.translatesAutoresizingMaskIntoConstraints = false
        
        let titelLabel = UILabel()
        titelLabel.text = titel
        titelLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titelLabel.textColor = rahmenFarbe
        titelLabel.numberOfLines = 0
        titelLabel.translatesAutoresizingMaskIntoConstraints = false
        kartenAnsicht.addSubview(titelLabel)
        
        let inhaltLabel = UILabel()
        inhaltLabel.text = inhalt
        inhaltLabel.font = UIFont.systemFont(ofSize: 15)
        inhaltLabel.textColor = .label
        inhaltLabel.numberOfLines = 0
        inhaltLabel.translatesAutoresizingMaskIntoConstraints = false
        kartenAnsicht.addSubview(inhaltLabel)
        
        NSLayoutConstraint.activate([
            titelLabel.topAnchor.constraint(equalTo: kartenAnsicht.topAnchor, constant: 16),
            titelLabel.leadingAnchor.constraint(equalTo: kartenAnsicht.leadingAnchor, constant: 16),
            titelLabel.trailingAnchor.constraint(equalTo: kartenAnsicht.trailingAnchor, constant: -16),
            
            inhaltLabel.topAnchor.constraint(equalTo: titelLabel.bottomAnchor, constant: 12),
            inhaltLabel.leadingAnchor.constraint(equalTo: kartenAnsicht.leadingAnchor, constant: 16),
            inhaltLabel.trailingAnchor.constraint(equalTo: kartenAnsicht.trailingAnchor, constant: -16),
            inhaltLabel.bottomAnchor.constraint(equalTo: kartenAnsicht.bottomAnchor, constant: -16)
        ])
        
        return kartenAnsicht
    }
    
    @objc private func allePunktzahlenZuruecksetzen() {
        let dialog = BenutzerdefinierteDialogansicht(
            titel: "⚠️ Reset Scores",
            nachricht: "Are you sure you want to reset all scores?",
            schaltflaechenTitel: ["Cancel", "Reset"]
        )
        dialog.schaltflaechenAktion = { [weak self] index in
            if index == 1 {
                self?.zuruecksetzen()
            }
        }
        dialog.anzeigen(in: view)
    }
    
    private func zuruecksetzen() {
        PunktzahlManager.shared.aktualisierePunktzahl(0, fuerModus: .einfach)
        PunktzahlManager.shared.aktualisierePunktzahl(0, fuerModus: .schwierig)
        PunktzahlManager.shared.aktualisierePunktzahl(0, fuerModus: .zeit)
        
        let bestaetigungDialog = BenutzerdefinierteDialogansicht(
            titel: "✅ Success",
            nachricht: "All scores have been reset!",
            schaltflaechenTitel: ["OK"]
        )
        bestaetigungDialog.anzeigen(in: view)
    }
    
    @objc private func schliessen() {
        dismiss(animated: true)
    }
}

