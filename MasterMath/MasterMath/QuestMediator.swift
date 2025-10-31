
import Foundation

// MARK: - Protocols

protocol QuestMediatorDelegate: AnyObject {
    func questMediatorDidUpdate(_ mediator: QuestMediator)
    func questMediator(_ mediator: QuestMediator, didCompleteWithResult result: ValidationOutcome)
    func questMediator(_ mediator: QuestMediator, didUpdateTime seconds: Int)
    func questMediatorDidEndQuest(_ mediator: QuestMediator, withScore score: Int, level: Int)
}

// MARK: - Quest Mediator

final class QuestMediator {
    
    // MARK: Properties
    
    weak var delegate: QuestMediatorDelegate?
    
    private let questLogicHandler: QuestLogicHandler
    private let scoreHandler: ScoreHandler
    private let mode: ChallengeMode
    
    private(set) var questState: QuestState?
    private(set) var selectedTokens: [NumericToken] = []
    private(set) var selectedOperands: [ArithmeticOperand] = []
    private(set) var currentScore: Int = 0
    private(set) var currentLevel: Int = 1
    private(set) var timeRemaining: Int
    
    private var timer: Timer?
    private var lastSelection: SelectionType = .none
    
    // MARK: Computed Properties
    
    var targetValue: Int {
        return questState?.targetValue ?? 0
    }
    
    var tokens: [NumericToken] {
        return questState?.tokens ?? []
    }
    
    var selectionText: String {
        guard !selectedTokens.isEmpty else {
            return "Select tiles and operators"
        }
        
        var text = ""
        for i in 0..<selectedTokens.count {
            text += "\(selectedTokens[i].numericValue)"
            if i < selectedOperands.count {
                text += " \(selectedOperands[i].symbol) "
            }
        }
        return text
    }
    
    var canSubmit: Bool {
        return selectedTokens.count >= 3 && 
               selectedOperands.count == selectedTokens.count - 1
    }
    
    var hasTimeLimit: Bool {
        return mode.configuration.hasTimeLimit
    }
    
    // MARK: Nested Types
    
    private enum SelectionType {
        case none
        case token
        case operand
    }
    
    // MARK: Initialization
    
    init(
        mode: ChallengeMode,
        questLogicHandler: QuestLogicHandler = .shared,
        scoreHandler: ScoreHandler = .shared
    ) {
        self.mode = mode
        self.questLogicHandler = questLogicHandler
        self.scoreHandler = scoreHandler
        self.timeRemaining = mode.configuration.timeLimitInSeconds
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: Public Methods - Quest Flow
    
    func startNewQuest() {
        questState = questLogicHandler.generateQuest(mode: mode)
        resetSelection()
        delegate?.questMediatorDidUpdate(self)
        
        if hasTimeLimit && timer == nil {
            startTimer()
        }
    }
    
    func refreshQuest() {
        tokens.forEach { $0.reset() }
        resetSelection()
        startNewQuest()
    }
    
    func restart() {
        currentScore = 0
        currentLevel = 1
        timeRemaining = mode.configuration.timeLimitInSeconds
        resetSelection()
        startNewQuest()
    }
    
    func endQuest() {
        stopTimer()
        scoreHandler.storeScore(currentScore, forMode: mode)
        delegate?.questMediatorDidEndQuest(self, withScore: currentScore, level: currentLevel)
    }
    
    // MARK: Public Methods - Selection
    
    func tokenWasSelected(_ token: NumericToken) -> SelectionAction {
        if lastSelection == .token && !token.isSelected {
            return .operandRequired
        }
        
        if token.isSelected {
            token.isSelected = false
            selectedTokens.removeAll { $0.uniqueIdentifier == token.uniqueIdentifier }
            
            if selectedTokens.isEmpty {
                lastSelection = .none
            }
            return .successfullyDeselected
        } else {
            token.isSelected = true
            selectedTokens.append(token)
            lastSelection = .token
            delegate?.questMediatorDidUpdate(self)
            return .successfullySelected
        }
    }
    
    func operandWasSelected(_ operand: ArithmeticOperand) {
        selectedOperands.append(operand)
        lastSelection = .operand
        delegate?.questMediatorDidUpdate(self)
    }
    
    func resetSelection() {
        selectedTokens.forEach { $0.isSelected = false }
        selectedTokens.removeAll()
        selectedOperands.removeAll()
        lastSelection = .none
        delegate?.questMediatorDidUpdate(self)
    }
    
    // MARK: Public Methods - Validation
    
    func submitAnswer() {
        let result = questLogicHandler.validateAnswer(
            selectedTokens: selectedTokens,
            selectedOperands: selectedOperands,
            targetValue: targetValue
        )
        
        if case .correct(let points) = result {
            currentScore += points * currentLevel
            currentLevel += 1
        }
        
        delegate?.questMediator(self, didCompleteWithResult: result)
    }
    
    // MARK: Private Methods - Timer
    
    private func startTimer() {
        timeRemaining = mode.configuration.timeLimitInSeconds
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timerTick() {
        timeRemaining -= 1
        delegate?.questMediator(self, didUpdateTime: timeRemaining)
        
        if timeRemaining <= 0 {
            endQuest()
        }
    }
}

// MARK: - Selection Action

enum SelectionAction {
    case successfullySelected
    case successfullyDeselected
    case operandRequired
}
