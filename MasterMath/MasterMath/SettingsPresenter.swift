//
//  SettingsPresenter.swift
//  MasterMath
//

import UIKit

class SettingsPresenter: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let resetButton = UIButton()
    private let closeButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        
        // Title
        titleLabel.text = "⚙️ Game Guide & Settings"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .systemPurple
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        
        // ContentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Create all content areas
        createGameGuideContent()
        
        // Reset Button
        resetButton.setTitle("🔄 Reset All Scores", for: .normal)
        resetButton.backgroundColor = .systemRed
        resetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 12
        resetButton.layer.shadowColor = UIColor.black.cgColor
        resetButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        resetButton.layer.shadowRadius = 4
        resetButton.layer.shadowOpacity = 0.3
        resetButton.addTarget(self, action: #selector(resetAllScores), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resetButton)
        
        // Close Button
        closeButton.setTitle("✕ Close", for: .normal)
        closeButton.backgroundColor = .systemBlue
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 12
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        closeButton.layer.shadowRadius = 4
        closeButton.layer.shadowOpacity = 0.3
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            resetButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -15),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createGameGuideContent() {
        var lastView: UIView?
        let spacing: CGFloat = 20
        
        // 1. Game Overview
        let overviewCard = createCard(
            title: "🎴 Game Overview",
            content: "Mahjong Math Master is a mathematical puzzle game that combines Mahjong-style tiles with arithmetic operators. Your goal is to select tiles and operators to create an equation that equals the target number!\n\n• Select tiles in order\n• Choose operators (+, -, ×, ÷)\n• Submit to check your answer\n• Earn points and level up!",
            backgroundColor: UIColor.systemPurple.withAlphaComponent(0.1),
            borderColor: UIColor.systemPurple
        )
        contentView.addSubview(overviewCard)
        NSLayoutConstraint.activate([
            overviewCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            overviewCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            overviewCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = overviewCard
        
        // 2. Game Modes
        let modesCard = createCard(
            title: "🎮 Game Modes",
            content: "🎯 SIMPLE MODE\n• 5 tiles per round\n• Use 3-5 tiles to solve\n• Target range: 10-100\n• Perfect for beginners\n• Take your time!\n\n🔥 HARD MODE\n• 10 tiles per round\n• Use 3-6 tiles to solve\n• Target range: 10-100\n• More complex solutions\n• Challenge yourself!\n\n⏱️ TIME MODE\n• 60 seconds countdown\n• 5 tiles per round\n• Solve as many as possible\n• Race against time\n• Test your speed!",
            backgroundColor: UIColor.systemBlue.withAlphaComponent(0.1),
            borderColor: UIColor.systemBlue
        )
        contentView.addSubview(modesCard)
        NSLayoutConstraint.activate([
            modesCard.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: spacing),
            modesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            modesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = modesCard
        
        // 3. How to Play
        let instructionsCard = createCard(
            title: "📖 How to Play",
            content: "STEP 1: Read the Target\nLook at the top of the screen to see your target number (e.g., Target: 24)\n\nSTEP 2: Select Tiles\n• Tap Mahjong tiles to select them\n• Selected tiles highlight in yellow\n• Each tile shows a number (1-9)\n• Select tiles in the order you want to use them\n\nSTEP 3: Choose Operators\n• Tap operator buttons: + - × ÷\n• Operators are used between tiles\n• You need one less operator than tiles\n  (e.g., 3 tiles = 2 operators)\n\nSTEP 4: Submit\n• Tap the green '✓ Submit' button\n• ✅ Correct: Earn points + fireworks!\n• ❌ Wrong: Try again!\n\nSTEP 5: Continue\n• Each correct answer increases your level\n• New puzzle appears automatically\n• Your score multiplies with each level",
            backgroundColor: UIColor.systemGreen.withAlphaComponent(0.1),
            borderColor: UIColor.systemGreen
        )
        contentView.addSubview(instructionsCard)
        NSLayoutConstraint.activate([
            instructionsCard.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: spacing),
            instructionsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = instructionsCard
        
        // 4. Calculation Rules
        let rulesCard = createCard(
            title: "🧮 Calculation Rules",
            content: "IMPORTANT: Operations are calculated LEFT to RIGHT!\n\n✓ Example 1:\nTiles: 3, 8\nOperator: ×\nCalculation: 3 × 8 = 24 ✅\n\n✓ Example 2:\nTiles: 2, 3, 4\nOperators: +, ×\nCalculation: 2 + 3 × 4\n= (2 + 3) × 4 (left to right!)\n= 5 × 4\n= 20 ✅\n\n✓ Example 3:\nTiles: 6, 2, 3\nOperators: ×, +\nCalculation: 6 × 2 + 3\n= (6 × 2) + 3\n= 12 + 3\n= 15 ✅\n\n⚠️ Common Mistake:\nDon't use standard math order!\n2 + 3 × 4 is NOT 2 + 12\nIt's (2 + 3) × 4 = 20",
            backgroundColor: UIColor.systemOrange.withAlphaComponent(0.1),
            borderColor: UIColor.systemOrange
        )
        contentView.addSubview(rulesCard)
        NSLayoutConstraint.activate([
            rulesCard.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: spacing),
            rulesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            rulesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = rulesCard
        
        // 5. Mahjong Tiles
        let tilesCard = createCard(
            title: "🎴 Mahjong Tiles",
            content: "Three beautiful tile colors:\n\n🔴 FREUN (Red Tiles)\nNumbers 1-9 in elegant red design\n\n🔵 JOIRARS (Blue Tiles)\nNumbers 1-9 in beautiful blue style\n\n🟢 SORTIE (Green Tiles)\nNumbers 1-9 in fresh green color\n\nAll tiles function identically - only the appearance differs! Choose any color you like.",
            backgroundColor: UIColor.systemPink.withAlphaComponent(0.1),
            borderColor: UIColor.systemPink
        )
        contentView.addSubview(tilesCard)
        NSLayoutConstraint.activate([
            tilesCard.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: spacing),
            tilesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tilesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = tilesCard
        
        // 6. Scoring System
        let scoringCard = createCard(
            title: "🏆 Scoring System",
            content: "BASE SCORE: 10 points per correct answer\n\nLEVEL MULTIPLIER:\n• Level 1: 10 × 1 = 10 points\n• Level 2: 10 × 2 = 20 points\n• Level 3: 10 × 3 = 30 points\n• And so on...\n\nHIGH SCORES:\n• Each mode saves your best score\n• Check the 🏆 Leaderboard\n• Beat your personal record\n• Compete with yourself!\n\nTIME MODE BONUS:\n• Solve quickly for more rounds\n• Each round adds to your total\n• Higher levels = more points",
            backgroundColor: UIColor.systemYellow.withAlphaComponent(0.1),
            borderColor: UIColor.systemYellow
        )
        contentView.addSubview(scoringCard)
        NSLayoutConstraint.activate([
            scoringCard.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: spacing),
            scoringCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scoringCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = scoringCard
        
        // 7. Tips & Strategies
        let tipsCard = createCard(
            title: "💡 Tips & Strategies",
            content: "🎯 START SIMPLE\nTry two-tile solutions first (e.g., 3 × 8 = 24)\n\n🧠 THINK BACKWARDS\nStart from the target and work backwards\nTarget 24? Think: 24 = 6 × 4 or 8 × 3\n\n🔢 USE DIVISION WISELY\nDivision can create decimals\nMake sure the result is a whole number!\n\n🔄 USE RESET\nMade a mistake? Tap 'Reset' to start over\nNo penalty for resetting!\n\n🎨 REFRESH TILES\nStuck? Use the refresh button (if available)\nGet a new set of tiles!\n\n⏱️ TIME MODE STRATEGY\nSpeed matters - use familiar patterns\nSkip if stuck - save time!\n\n🎓 PRACTICE MAKES PERFECT\nStart with Simple Mode\nMove to Hard Mode when confident\nChallenge yourself in Time Mode!",
            backgroundColor: UIColor.systemTeal.withAlphaComponent(0.1),
            borderColor: UIColor.systemTeal
        )
        contentView.addSubview(tipsCard)
        NSLayoutConstraint.activate([
            tipsCard.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: spacing),
            tipsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tipsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = tipsCard
        
        // 8. Complete Example
        let exampleCard = createCard(
            title: "📚 Complete Example",
            content: "Let's solve a puzzle together!\n\n🎯 TARGET: 30\n🎴 AVAILABLE TILES: 2, 3, 4, 5, 6\n\nSOLUTION 1 (Easy - 2 tiles):\nSelect: 5, then 6\nOperator: ×\nCalculation: 5 × 6 = 30 ✅\n\nSOLUTION 2 (Medium - 3 tiles):\nSelect: 2, then 3, then 5\nOperators: +, ×\nCalculation: (2 + 3) × 5 = 25... ❌\nTry again!\n\nSelect: 3, then 2, then 5\nOperators: ×, ×\nCalculation: (3 × 2) × 5 = 30 ✅\n\nGreat job! 🎉",
            backgroundColor: UIColor.systemIndigo.withAlphaComponent(0.1),
            borderColor: UIColor.systemIndigo
        )
        contentView.addSubview(exampleCard)
        NSLayoutConstraint.activate([
            exampleCard.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: spacing),
            exampleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            exampleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = exampleCard
        
        // 9. Version Info
        let versionCard = createCard(
            title: "ℹ️ App Information",
            content: "MasterMath\nVersion 1.0\n\n© 2025 MasterMath Game\n\nA mathematical puzzle game that combines the beauty of Mahjong tiles with the challenge of arithmetic!\n\nEnjoy the game and improve your mental math skills! 🧮🎮",
            backgroundColor: UIColor.systemGray.withAlphaComponent(0.1),
            borderColor: UIColor.systemGray
        )
        contentView.addSubview(versionCard)
        NSLayoutConstraint.activate([
            versionCard.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: spacing),
            versionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            versionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = versionCard
        
        // Set final constraint
        lastView?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing).isActive = true
    }
    
    private func createCard(title: String, content: String, backgroundColor: UIColor, borderColor: UIColor) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = backgroundColor
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 2
        cardView.layer.borderColor = borderColor.cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = borderColor
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            contentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
        
        return cardView
    }
    
    @objc private func resetAllScores() {
        let dialog = CustomDialogView(
            title: "⚠️ Reset Scores",
            message: "Are you sure you want to reset all scores?",
            buttonTitles: ["Cancel", "Reset"]
        )
        dialog.buttonAction = { [weak self] index in
            if index == 1 {
                self?.performReset()
            }
        }
        dialog.display(in: view)
    }
    
    private func performReset() {
        ScoreHandler.shared.updateScore(0, forMode: .einfach)
        ScoreHandler.shared.updateScore(0, forMode: .schwierig)
        ScoreHandler.shared.updateScore(0, forMode: .zeit)
        
        let confirmationDialog = CustomDialogView(
            title: "✅ Success",
            message: "All scores have been reset!",
            buttonTitles: ["OK"]
        )
        confirmationDialog.display(in: view)
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}
