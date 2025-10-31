//
//  GamePlayViewController.swift
//  MasterMath
//
//  Presentation Layer - Game Play View Controller
//

import UIKit

final class GamePlayViewController: UIViewController {
    
    private let mode: GameModeEntity
    private let eventBus: EventBusProtocol
    private let commandHandler: CommandHandlerProtocol
    private let router: NavigationRouterProtocol
    
    private var sessionManager: GameSessionManager?
    private var puzzleGenerator: PuzzleGenerationUseCaseProtocol?
    private var answerValidator: AnswerValidationUseCaseProtocol?
    
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
    private var tokenViews: [TileDisplayView] = []
    private var operandButtons: [OperatorDisplayButton] = []
    private var gradientLayer: CAGradientLayer?
    private var layoutCompleted = false
    
    private var currentPuzzle: PuzzleEntity?
    private var currentScore: Int = 0
    private var currentLevel: Int = 1
    private var timeRemaining: Int = 0
    
    init(
        mode: GameModeEntity,
        eventBus: EventBusProtocol,
        commandHandler: CommandHandlerProtocol,
        router: NavigationRouterProtocol
    ) {
        self.mode = mode
        self.eventBus = eventBus
        self.commandHandler = commandHandler
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeServices()
        setupInterface()
        subscribeToEvents()
        startGame()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        
        if !layoutCompleted {
            layoutCompleted = true
            renderTiles()
            renderOperators()
        }
    }
    
    private func initializeServices() {
        let calculator = ArithmeticComputationService()
        let solvabilityChecker = SolvabilityVerificationService(calculator: calculator)
        puzzleGenerator = PuzzleGenerationUseCase(
            solvabilityChecker: solvabilityChecker,
            maxGenerationAttempts: 100
        )
        answerValidator = AnswerValidationUseCase(
            calculator: calculator,
            minTileRequirement: 3
        )
        
        let stateMachine = GameStateMachine(eventBus: eventBus)
        let scoreRepository = ScoreRepository()
        sessionManager = GameSessionManager(
            eventBus: eventBus,
            stateMachine: stateMachine,
            scoreRepository: scoreRepository
        )
    }
    
    private func setupInterface() {
        view.backgroundColor = UIColor.systemBackground
        
        // 清新的渐变背景
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.97, green: 0.98, blue: 1.0, alpha: 1.0).cgColor,  // 淡蓝白
            UIColor(red: 0.99, green: 0.99, blue: 1.0, alpha: 1.0).cgColor,  // 纯白
            UIColor(red: 0.98, green: 0.97, blue: 0.99, alpha: 1.0).cgColor   // 淡粉紫
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        setupHeaderElements()
        setupTargetDisplay()
        setupContainers()
        setupSelectionDisplay()
        setupActionButtons()
        setupLayoutConstraints()
    }
    
    private func setupHeaderElements() {
        // 关闭按钮 - 现代化的圆形设计
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0), for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        closeButton.layer.cornerRadius = 20
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        closeButton.layer.shadowRadius = 8
        closeButton.layer.shadowOpacity = 0.1
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        // 分数标签 - 卡片样式
        scoreLabel.text = "Score: 0"
        scoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        scoreLabel.textColor = UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0)
        scoreLabel.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        scoreLabel.layer.cornerRadius = 12
        scoreLabel.textAlignment = .center
        scoreLabel.layer.shadowColor = UIColor.black.cgColor
        scoreLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        scoreLabel.layer.shadowRadius = 4
        scoreLabel.layer.shadowOpacity = 0.1
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        // 等级标签 - 卡片样式
        levelLabel.text = "Level 1"
        levelLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        levelLabel.textColor = UIColor(red: 0.7, green: 0.3, blue: 0.5, alpha: 1.0)
        levelLabel.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        levelLabel.layer.cornerRadius = 12
        levelLabel.textAlignment = .center
        levelLabel.layer.shadowColor = UIColor.black.cgColor
        levelLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        levelLabel.layer.shadowRadius = 4
        levelLabel.layer.shadowOpacity = 0.1
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(levelLabel)
        
        if mode.hasTimer {
            timeLabel.text = "⏱ 0"
            timeLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            timeLabel.textColor = .white
            timeLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
            timeLabel.layer.cornerRadius = 12
            timeLabel.textAlignment = .center
            timeLabel.layer.shadowColor = UIColor.systemRed.cgColor
            timeLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
            timeLabel.layer.shadowRadius = 4
            timeLabel.layer.shadowOpacity = 0.3
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(timeLabel)
        }
    }
    
    private func setupTargetDisplay() {
        targetLabel.text = "Target: 0"
        targetLabel.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        targetLabel.textColor = UIColor(red: 0.2, green: 0.3, blue: 0.6, alpha: 1.0)
        targetLabel.textAlignment = .center
        targetLabel.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        targetLabel.layer.cornerRadius = 20
        targetLabel.layer.shadowColor = UIColor(red: 0.2, green: 0.3, blue: 0.6, alpha: 1.0).cgColor
        targetLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        targetLabel.layer.shadowRadius = 12
        targetLabel.layer.shadowOpacity = 0.3
        targetLabel.layer.borderWidth = 2
        targetLabel.layer.borderColor = UIColor(red: 0.2, green: 0.3, blue: 0.6, alpha: 0.3).cgColor
        targetLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(targetLabel)
    }
    
    private func setupContainers() {
        // 添加容器背景和样式
        tokensContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        tokensContainerView.layer.cornerRadius = 20
        tokensContainerView.layer.shadowColor = UIColor.black.cgColor
        tokensContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        tokensContainerView.layer.shadowRadius = 10
        tokensContainerView.layer.shadowOpacity = 0.1
        tokensContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tokensContainerView)
        
        operandsContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        operandsContainerView.layer.cornerRadius = 20
        operandsContainerView.layer.shadowColor = UIColor.black.cgColor
        operandsContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        operandsContainerView.layer.shadowRadius = 10
        operandsContainerView.layer.shadowOpacity = 0.1
        operandsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(operandsContainerView)
    }
    
    private func setupSelectionDisplay() {
        selectionLabel.text = "Select tiles and operators"
        selectionLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        selectionLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0)
        selectionLabel.textAlignment = .center
        selectionLabel.numberOfLines = 0
        selectionLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        selectionLabel.layer.cornerRadius = 16
        selectionLabel.layer.shadowColor = UIColor.black.cgColor
        selectionLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        selectionLabel.layer.shadowRadius = 6
        selectionLabel.layer.shadowOpacity = 0.1
        selectionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectionLabel)
    }
    
    private func setupActionButtons() {
        resetButton.setTitle("🔄 Reset", for: .normal)
        styleButton(resetButton, color: .systemGray)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        
        submitButton.setTitle("✓ Submit", for: .normal)
        styleButton(submitButton, color: .systemGreen)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        
        refreshButton.setTitle("⟳ New", for: .normal)
        styleButton(refreshButton, color: .systemBlue)
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 15
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsStack.addArrangedSubview(resetButton)
        buttonsStack.addArrangedSubview(submitButton)
        buttonsStack.addArrangedSubview(refreshButton)
        
        view.addSubview(buttonsStack)
    }
    
    private func styleButton(_ button: UIButton, color: UIColor) {
        button.backgroundColor = color.withAlphaComponent(0.9)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = color.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.4
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupLayoutConstraints() {
        var constraints: [NSLayoutConstraint] = [
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            scoreLabel.widthAnchor.constraint(equalToConstant: 100),
            scoreLabel.heightAnchor.constraint(equalToConstant: 36),
            
            levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            levelLabel.widthAnchor.constraint(equalToConstant: 100),
            levelLabel.heightAnchor.constraint(equalToConstant: 36),
            
            targetLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            targetLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            targetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            targetLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            targetLabel.heightAnchor.constraint(equalToConstant: 70),
            
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
            selectionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonsStack.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        if mode.hasTimer {
            constraints.append(contentsOf: [
                timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                timeLabel.widthAnchor.constraint(equalToConstant: 80),
                timeLabel.heightAnchor.constraint(equalToConstant: 36)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func subscribeToEvents() {
        eventBus.subscribe(PuzzleGeneratedEvent.self) { [weak self] event in
            self?.handlePuzzleGenerated(event.puzzle)
        }
        
        eventBus.subscribe(TileSelectedEvent.self) { [weak self] event in
            self?.handleTileSelected(event.tile)
        }
        
        eventBus.subscribe(OperatorSelectedEvent.self) { [weak self] event in
            self?.handleOperatorSelected(event.operatorEntity)
        }
        
        eventBus.subscribe(SelectionClearedEvent.self) { [weak self] _ in
            self?.handleSelectionCleared()
        }
        
        eventBus.subscribe(AnswerValidatedEvent.self) { [weak self] event in
            self?.handleAnswerValidated(event.result)
        }
        
        eventBus.subscribe(ScoreUpdatedEvent.self) { [weak self] event in
            self?.handleScoreUpdated(event.currentScore, event.currentLevel)
        }
        
        eventBus.subscribe(TimerTickEvent.self) { [weak self] event in
            self?.handleTimerTick(event.remainingSeconds)
        }
        
        eventBus.subscribe(GameEndedEvent.self) { [weak self] event in
            self?.handleGameEnded(event.finalScore, event.finalLevel)
        }
    }
    
    private func startGame() {
        commandHandler.handle(StartGameCommand(
            mode: mode,
            eventBus: eventBus,
            puzzleGenerator: puzzleGenerator!
        ))
    }
    
    private func handlePuzzleGenerated(_ puzzle: PuzzleEntity) {
        currentPuzzle = puzzle
        updateDisplay()
        renderTiles()
    }
    
    private func handleTileSelected(_ tile: TileEntity) {
        if let index = currentPuzzle?.availableTiles.firstIndex(where: { $0.id == tile.id }) {
            var updatedTiles = currentPuzzle!.availableTiles
            updatedTiles[index] = tile
            currentPuzzle = PuzzleEntity(
                targetNumber: currentPuzzle!.targetNumber,
                availableTiles: updatedTiles,
                mode: currentPuzzle!.mode
            )
            
            updateDisplay()
            updateTileViews()
        }
    }
    
    private func handleOperatorSelected(_ operator: OperatorEntity) {
        updateDisplay()
    }
    
    private func handleSelectionCleared() {
        // 同步 sessionManager 中的 currentPuzzle 状态
        if let updatedPuzzle = sessionManager?.currentPuzzle {
            currentPuzzle = updatedPuzzle
        }
        updateDisplay()
        updateTileViews()
    }
    
    private func handleAnswerValidated(_ result: ValidationResultEntity) {
        switch result {
        case .success(let points):
            // 使用当前级别计算本次获得的分数（与 GameSessionManager 中的计算一致）
            let totalPoints = points * currentLevel
            showSuccessAnimation()
            showSuccessDialog(points: totalPoints)
        case .failure(let reason):
            showErrorDialog(for: reason)
        }
    }
    
    private func handleScoreUpdated(_ score: Int, _ level: Int) {
        currentScore = score
        currentLevel = level
        updateDisplay()
    }
    
    private func handleTimerTick(_ seconds: Int) {
        timeRemaining = seconds
        timeLabel.text = "⏱ \(seconds)"
        
        if seconds <= 10 {
            timeLabel.textColor = .systemRed
            UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat]) {
                self.timeLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }
    }
    
    private func handleGameEnded(_ score: Int, _ level: Int) {
        showTimeExpiredDialog(score: score, level: level)
    }
    
    private func updateDisplay() {
        guard let puzzle = currentPuzzle,
              let sessionManager = sessionManager else { return }
        
        targetLabel.text = "Target: \(puzzle.targetNumber)"
        scoreLabel.text = "Score: \(currentScore)"
        levelLabel.text = "Level \(currentLevel)"
        
        let answer = sessionManager.createAnswer()
        let selectionText = buildSelectionText(from: answer)
        selectionLabel.text = selectionText
        
        let canSubmit = answer.isValid
        submitButton.isEnabled = canSubmit
        submitButton.alpha = canSubmit ? 1.0 : 0.5
    }
    
    private func buildSelectionText(from answer: AnswerEntity) -> String {
        guard !answer.selectedTiles.isEmpty else {
            return "Select tiles and operators"
        }
        
        var text = ""
        for i in 0..<answer.selectedTiles.count {
            text += "\(answer.selectedTiles[i].numericValue)"
            if i < answer.selectedOperators.count {
                text += " \(answer.selectedOperators[i].symbol) "
            }
        }
        return text
    }
    
    private func showHint(message: String) {
        let dialog = CustomDialogView(
            title: "Notice",
            message: message,
            buttonTitles: ["OK"]
        )
        dialog.display(in: view)
    }
    
    private func renderTiles() {
        tokenViews.forEach { $0.removeFromSuperview() }
        tokenViews.removeAll()
        
        guard let puzzle = currentPuzzle else { return }
        let tiles = puzzle.availableTiles
        
        let columns = 5
        let rows = (tiles.count + columns - 1) / columns
        let tileSize: CGFloat = 70
        let spacing: CGFloat = 10
        
        let totalWidth = CGFloat(columns) * tileSize + CGFloat(columns - 1) * spacing
        let totalHeight = CGFloat(rows) * tileSize + CGFloat(rows - 1) * spacing
        let startX = (tokensContainerView.bounds.width - totalWidth) / 2
        let startY = (tokensContainerView.bounds.height - totalHeight) / 2
        
        for (index, tile) in tiles.enumerated() {
            let row = index / columns
            let column = index % columns
            
            let x = startX + CGFloat(column) * (tileSize + spacing)
            let y = startY + CGFloat(row) * (tileSize + spacing)
            
            let tileView = TileDisplayView(frame: CGRect(x: x, y: y, width: tileSize, height: tileSize))
            tileView.configure(with: tile)
            tileView.onTap = { [weak self] in
                self?.handleTileTapped(tile)
            }
            
            tokensContainerView.addSubview(tileView)
            tokenViews.append(tileView)
        }
    }
    
    private func renderOperators() {
        operandButtons.forEach { $0.removeFromSuperview() }
        operandButtons.removeAll()
        
        let operators: [OperatorEntity] = [.addition, .subtraction, .multiplication, .division]
        let buttonWidth: CGFloat = 70
        let spacing: CGFloat = 10
        let totalWidth = CGFloat(operators.count) * buttonWidth + CGFloat(operators.count - 1) * spacing
        let containerWidth: CGFloat = 330
        let startX = (containerWidth - totalWidth) / 2
        
        for (index, op) in operators.enumerated() {
            let x = startX + CGFloat(index) * (buttonWidth + spacing)
            let button = OperatorDisplayButton(frame: CGRect(x: x, y: 5, width: buttonWidth, height: 70))
            button.configure(with: op)
            button.addTarget(self, action: #selector(operatorTapped(_:)), for: .touchUpInside)
            
            operandsContainerView.addSubview(button)
            operandButtons.append(button)
        }
    }
    
    private func handleTileTapped(_ tile: TileEntity) {
        guard let puzzle = currentPuzzle,
              let index = puzzle.availableTiles.firstIndex(where: { $0.id == tile.id }),
              let sessionManager = sessionManager else {
            return
        }
        
        var updatedTile = puzzle.availableTiles[index]
        let answer = sessionManager.createAnswer()
        
        if updatedTile.isChosen {
            updatedTile.clearSelection()
        } else {
            // 游戏规则：必须先选择牌，然后是运算符，不能连续选择两张牌
            // 如果已经选择了牌，在选择下一张牌之前，运算符数量必须等于已选牌数
            if !answer.selectedTiles.isEmpty && answer.selectedOperators.count < answer.selectedTiles.count {
                showHint(message: "Please select an operator first!")
                return
            }
            updatedTile.toggleSelection()
        }
        
        commandHandler.handle(SelectTileCommand(tile: updatedTile, eventBus: eventBus))
    }
    
    @objc private func operatorTapped(_ sender: OperatorDisplayButton) {
        guard let op = sender.operatorEntity else { return }
        commandHandler.handle(SelectOperatorCommand(operatorEntity: op, eventBus: eventBus))
    }
    
    @objc private func closeTapped() {
        router.dismiss(from: self)
    }
    
    @objc private func resetTapped() {
        commandHandler.handle(ClearSelectionCommand(eventBus: eventBus))
    }
    
    @objc private func submitTapped() {
        guard let puzzle = currentPuzzle,
              let sessionManager = sessionManager else { return }
        
        let answer = sessionManager.createAnswer()
        
        commandHandler.handle(SubmitAnswerCommand(
            answer: answer,
            targetValue: puzzle.targetNumber,
            eventBus: eventBus,
            validator: answerValidator!
        ))
    }
    
    @objc private func refreshTapped() {
        commandHandler.handle(RefreshPuzzleCommand(
            mode: mode,
            eventBus: eventBus,
            puzzleGenerator: puzzleGenerator!
        ))
    }
    
    private func updateTileViews() {
        for (index, view) in tokenViews.enumerated() {
            if index < currentPuzzle?.availableTiles.count ?? 0 {
                let tile = currentPuzzle!.availableTiles[index]
                view.updateSelection(tile.isChosen)
            }
        }
    }
    
    private func showSuccessDialog(points: Int) {
        let dialog = CustomDialogView(
            title: "🎉 Correct!",
            message: "Well done! +\(points) points",
            buttonTitles: ["Continue"]
        )
        dialog.buttonAction = { [weak self] _ in
            guard let self = self else { return }
            self.commandHandler.handle(RefreshPuzzleCommand(
                mode: self.mode,
                eventBus: self.eventBus,
                puzzleGenerator: self.puzzleGenerator!
            ))
        }
        dialog.display(in: view)
    }
    
    private func showErrorDialog(for reason: ValidationResultEntity.ValidationFailureReason) {
        let message: String
        switch reason {
        case .notEnoughTiles(let minimum):
            message = "Please select at least \(minimum) tiles!"
        case .operatorCountMismatch(let expected, let received):
            message = "Expected \(expected) operators but got \(received)!"
        case .incorrectAnswer(let expected, let obtained):
            message = "Incorrect! Got \(String(format: "%.0f", obtained)), expected \(expected)"
        case .computationError:
            message = "Calculation error occurred!"
        }
        
        let dialog = CustomDialogView(
            title: "Notice",
            message: message,
            buttonTitles: ["OK"]
        )
        dialog.display(in: view)
    }
    
    private func showTimeExpiredDialog(score: Int, level: Int) {
        let dialog = CustomDialogView(
            title: "⏰ Time's Up!",
            message: "Final Score: \(score)\nLevel: \(level)",
            buttonTitles: ["Play Again", "Exit"]
        )
        dialog.buttonAction = { [weak self] index in
            guard let self = self else { return }
            if index == 0 {
                self.commandHandler.handle(RestartGameCommand(
                    mode: self.mode,
                    eventBus: self.eventBus,
                    puzzleGenerator: self.puzzleGenerator!
                ))
            } else {
                self.router.dismiss(from: self)
            }
        }
        dialog.display(in: view)
    }
    
    private func showSuccessAnimation() {
        // 使用脉冲动画替代粒子效果
        let pulseView = UIView(frame: view.bounds)
        pulseView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        pulseView.alpha = 0
        view.addSubview(pulseView)
        
        UIView.animate(withDuration: 0.3, animations: {
            pulseView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                pulseView.alpha = 0
            }) { _ in
                pulseView.removeFromSuperview()
            }
        }
        
        // 添加缩放动画到目标标签
        UIView.animate(withDuration: 0.2, animations: {
            self.targetLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                self.targetLabel.transform = .identity
            })
        }
    }
}

