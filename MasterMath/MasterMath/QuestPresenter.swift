//
//  QuestPresenter.swift
//  MasterMath
//
//  Quest Presenter - MVVM Pattern
//

import UIKit

final class QuestPresenter: UIViewController {
    
    // MARK: - Properties
    
    weak var orchestrator: QuestOrchestrator?
    private let mediator: QuestMediator
    
    // UI Components
    private let closeButton = UIButton()
    private let targetLabel = UILabel()
    private let scoreLabel = UILabel()
    private let levelLabel = UILabel()
    private let timeLabel = UILabel()
    private let tokensContainerView = UIView()
    private let operandsContainerView = UIView()
    private let selectionLabel = UILabel()
    private let resetButton = UIButton()
    private let submitButton = UIButton()
    private let refreshButton = UIButton()
    private let buttonsStack = UIStackView()
    private var tokenViews: [TokenView] = []
    private var operandButtons: [OperandButton] = []
    private var gradientLayer: CAGradientLayer?
    private var hasLayoutCompleted = false
    
    // MARK: - Initialization
    
    init(mediator: QuestMediator) {
        self.mediator = mediator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindMediator()
        mediator.startNewQuest()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        
        if !hasLayoutCompleted {
            hasLayoutCompleted = true
            createTokenViews()
            createOperandButtons()
        }
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = UIColor.systemBackground
        
        // Gradient Background
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemTeal.withAlphaComponent(0.3).cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        setupHeader()
        setupTargetLabel()
        setupTokensContainer()
        setupOperandsContainer()
        setupSelectionArea()
        setupButtons()
        setupConstraints()
    }
    
    private func setupHeader() {
        // Close Button
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        closeButton.addTarget(self, action: #selector(closeSelected), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        // Score Label
        scoreLabel.text = "Score: 0"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        scoreLabel.textColor = .black
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        // Level Label
        levelLabel.text = "Level 1"
        levelLabel.font = UIFont.boldSystemFont(ofSize: 20)
        levelLabel.textColor = .black
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(levelLabel)
        
        // Time Label (only for Time Mode)
        if mediator.hasTimeLimit {
            timeLabel.text = "⏱ \(mediator.timeRemaining)"
            timeLabel.font = UIFont.boldSystemFont(ofSize: 20)
            timeLabel.textColor = .systemRed
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(timeLabel)
        }
    }
        
    private func setupTargetLabel() {
        targetLabel.text = "Target: 0"
        targetLabel.font = UIFont.boldSystemFont(ofSize: 36)
        targetLabel.textColor = .systemIndigo
        targetLabel.textAlignment = .center
        targetLabel.layer.shadowColor = UIColor.black.cgColor
        targetLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        targetLabel.layer.shadowRadius = 4
        targetLabel.layer.shadowOpacity = 0.2
        targetLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(targetLabel)
    }
        
    private func setupTokensContainer() {
        tokensContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tokensContainerView)
    }
        
    private func setupOperandsContainer() {
        operandsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(operandsContainerView)
    }
        
    private func setupSelectionArea() {
        selectionLabel.text = "Select tiles and operators"
        selectionLabel.font = UIFont.systemFont(ofSize: 18)
        selectionLabel.textColor = .darkGray
        selectionLabel.textAlignment = .center
        selectionLabel.numberOfLines = 0
        selectionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectionLabel)
    }
        
    private func setupButtons() {
        // Reset Button
        resetButton.setTitle("🔄 Reset", for: .normal)
        configureButton(resetButton, color: .systemGray)
        resetButton.addTarget(self, action: #selector(resetSelected), for: .touchUpInside)
        
        // Submit Button
        submitButton.setTitle("✓ Submit", for: .normal)
        configureButton(submitButton, color: .systemGreen)
        submitButton.addTarget(self, action: #selector(submitSelected), for: .touchUpInside)
        
        // Refresh Button
        refreshButton.setTitle("⟳ New", for: .normal)
        configureButton(refreshButton, color: .systemBlue)
        refreshButton.addTarget(self, action: #selector(refreshSelected), for: .touchUpInside)
        
        // StackView Configuration
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 15
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsStack.addArrangedSubview(resetButton)
        buttonsStack.addArrangedSubview(submitButton)
        buttonsStack.addArrangedSubview(refreshButton)
        
        view.addSubview(buttonsStack)
    }
    
    private func configureButton(_ button: UIButton, color: UIColor) {
        button.backgroundColor = color
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = [
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            
            levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            
            targetLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            targetLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tokensContainerView.topAnchor.constraint(equalTo: targetLabel.bottomAnchor, constant: 30),
            tokensContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tokensContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tokensContainerView.heightAnchor.constraint(equalToConstant: 170),
            
            operandsContainerView.topAnchor.constraint(equalTo: tokensContainerView.bottomAnchor, constant: 20),
            operandsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            operandsContainerView.heightAnchor.constraint(equalToConstant: 80),
            operandsContainerView.widthAnchor.constraint(equalToConstant: 330),
            
            selectionLabel.topAnchor.constraint(equalTo: operandsContainerView.bottomAnchor, constant: 20),
            selectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonsStack.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        if mediator.hasTimeLimit {
            constraints.append(contentsOf: [
                timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Mediator Binding
    
    private func bindMediator() {
        mediator.delegate = self
    }
    
    // MARK: - UI Updates
    
    private func updateScreen() {
        targetLabel.text = "Target: \(mediator.targetValue)"
        scoreLabel.text = "Score: \(mediator.currentScore)"
        levelLabel.text = "Level \(mediator.currentLevel)"
        selectionLabel.text = mediator.selectionText
        submitButton.isEnabled = mediator.canSubmit
        submitButton.alpha = mediator.canSubmit ? 1.0 : 0.5
    }
    
    private func createTokenViews() {
        // Remove old views
        tokenViews.forEach { $0.removeFromSuperview() }
        tokenViews.removeAll()
        
        let tokens = mediator.tokens
        
        // Determine layout based on token count
        // Simple mode (5 tokens): 1 row, 5 columns
        // Hard mode (10 tokens): 2 rows, 5 columns
        let columns = 5
        let rows = (tokens.count + columns - 1) / columns
        let tokenSize: CGFloat = 70
        let spacing: CGFloat = 10
        
        let totalWidth = CGFloat(columns) * tokenSize + CGFloat(columns - 1) * spacing
        let totalHeight = CGFloat(rows) * tokenSize + CGFloat(rows - 1) * spacing
        let startX = (tokensContainerView.bounds.width - totalWidth) / 2
        let startY = (tokensContainerView.bounds.height - totalHeight) / 2
        
        for (index, token) in tokens.enumerated() {
            let row = index / columns
            let column = index % columns
            
            let x = startX + CGFloat(column) * (tokenSize + spacing)
            let y = startY + CGFloat(row) * (tokenSize + spacing)
            
            let tokenView = TokenView(frame: CGRect(x: x, y: y, width: tokenSize, height: tokenSize))
            tokenView.token = token
            tokenView.tokenTapped = { [weak self] _ in
                self?.tokenWasSelected(token)
            }
            
            tokensContainerView.addSubview(tokenView)
            tokenViews.append(tokenView)
        }
    }
    
    private func createOperandButtons() {
        // Remove old buttons
        operandButtons.forEach { $0.removeFromSuperview() }
        operandButtons.removeAll()
        
        let operands: [ArithmeticOperand] = [.addieren, .subtrahieren, .multiplizieren, .dividieren]
        let buttonWidth: CGFloat = 70
        let spacing: CGFloat = 10
        let totalWidth = CGFloat(operands.count) * buttonWidth + CGFloat(operands.count - 1) * spacing
        let containerWidth: CGFloat = 330
        let startX = (containerWidth - totalWidth) / 2
        
        for (index, operand) in operands.enumerated() {
            let x = startX + CGFloat(index) * (buttonWidth + spacing)
            let button = OperandButton(frame: CGRect(x: x, y: 5, width: buttonWidth, height: 70))
            button.operandType = operand
            button.addTarget(self, action: #selector(operandButtonPressed(_:)), for: .touchUpInside)
            
            operandsContainerView.addSubview(button)
            operandButtons.append(button)
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeSelected() {
        orchestrator?.concludeQuest()
    }
    
    private func tokenWasSelected(_ token: NumericToken) {
        let action = mediator.tokenWasSelected(token)
        
        switch action {
        case .operandRequired:
            showHint(message: "Please select an operator first!")
        case .successfullySelected, .successfullyDeselected:
            updateScreen()
            updateTokenViews()
        }
    }
    
    @objc private func operandButtonPressed(_ sender: OperandButton) {
        guard let operand = sender.operandType else { return }
        mediator.operandWasSelected(operand)
    }
    
    @objc private func resetSelected() {
        mediator.resetSelection()
        updateTokenViews()
    }
    
    @objc private func submitSelected() {
        mediator.submitAnswer()
    }
    
    @objc private func refreshSelected() {
        mediator.refreshQuest()
        createTokenViews()
    }
    
    // MARK: - Helper Methods
    
    private func updateTokenViews() {
        for (index, view) in tokenViews.enumerated() {
            if index < mediator.tokens.count {
                view.isSelected = mediator.tokens[index].isSelected
            }
        }
    }
    
    private func showHint(message: String) {
        DialogOrchestrator.displayErrorDialog(
            in: view,
            title: "Notice",
            message: message
        )
    }
    
    private func showParticleEffect() {
        let effectView = ParticleEffectView(frame: view.bounds)
        effectView.backgroundColor = .clear
        view.addSubview(effectView)
        effectView.showSuccessEffect()
    }
}

// MARK: - QuestMediatorDelegate

extension QuestPresenter: QuestMediatorDelegate {
    
    func questMediatorDidUpdate(_ mediator: QuestMediator) {
        updateScreen()
        
        // Only update existing views
        if !tokenViews.isEmpty {
            updateTokenViews()
        }
    }
    
    func questMediator(_ mediator: QuestMediator, didCompleteWithResult result: ValidationOutcome) {
        switch result {
        case .correct(let points):
            let totalPoints = points * (mediator.currentLevel - 1)
            showParticleEffect()
            
            DialogOrchestrator.displaySuccessDialog(in: view, points: totalPoints) { [weak self] in
                self?.mediator.refreshQuest()
                self?.createTokenViews()
            }
            
        case .insufficientTokens(let minimum):
            showHint(message: "Please select at least \(minimum) tiles!")
            
        case .incorrectOperandCount(let expected, let received):
            showHint(message: "Expected \(expected) operators but got \(received)!")
            
        case .incorrectResult(let expected, let obtained):
            let obtainedString = String(format: "%.0f", obtained)
            showHint(message: "Incorrect! Got \(obtainedString), expected \(expected)")
        }
    }
    
    func questMediator(_ mediator: QuestMediator, didUpdateTime seconds: Int) {
        timeLabel.text = "⏱ \(seconds)"
        
        if seconds <= 10 {
            timeLabel.textColor = .systemRed
            UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat]) {
                self.timeLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }
    }
    
    func questMediatorDidEndQuest(_ mediator: QuestMediator, withScore score: Int, level: Int) {
        DialogOrchestrator.displayTimeExpiredDialog(
            in: view,
            score: score,
            level: level,
            restart: { [weak self] in
                self?.mediator.restart()
                self?.createTokenViews()
            },
            exit: { [weak self] in
                self?.orchestrator?.concludeQuest()
            }
        )
    }
}
