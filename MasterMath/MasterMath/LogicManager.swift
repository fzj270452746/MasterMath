//
//  QuestLogicHandler.swift
//  MasterMath
//
//  Quest Logic Handler
//

import Foundation

// MARK: - Protocols

protocol QuestGenerator {
    func generateQuest(mode: ChallengeMode) -> QuestState
}

protocol AnswerValidator {
    func validateAnswer(
        tokens: [NumericToken],
        operands: [ArithmeticOperand],
        targetValue: Int
    ) -> ValidationOutcome
}

protocol SolvabilityChecker {
    func isSolvable(targetValue: Int, tokens: [NumericToken], configuration: ChallengeConfiguration) -> Bool
}

protocol Calculator {
    func calculate(tokens: [NumericToken], operands: [ArithmeticOperand]) -> ComputationResult
}

// MARK: - Quest State

struct QuestState {
    let targetValue: Int
    let tokens: [NumericToken]
    let mode: ChallengeMode
    let creationTimestamp: Date
    
    init(targetValue: Int, tokens: [NumericToken], mode: ChallengeMode) {
        self.targetValue = targetValue
        self.tokens = tokens
        self.mode = mode
        self.creationTimestamp = Date()
    }
}

// MARK: - Calculator Implementation

final class StandardCalculator: Calculator {
    
    func calculate(tokens: [NumericToken], operands: [ArithmeticOperand]) -> ComputationResult {
        guard !tokens.isEmpty else {
            return ComputationResult(value: 0, error: .invalidValue)
        }
        
        guard tokens.count == operands.count + 1 else {
            return ComputationResult(value: 0, error: .invalidValue)
        }
        
        var result = Double(tokens[0].numericValue)
        
        for (index, operand) in operands.enumerated() {
            let nextValue = Double(tokens[index + 1].numericValue)
            let intermediateResult = operand.executeOperation(left: result, right: nextValue)
            
            if let error = intermediateResult.error {
                return ComputationResult(value: 0, error: error)
            }
            
            result = intermediateResult.value
        }
        
        return ComputationResult(value: result, error: nil)
    }
}

// MARK: - Answer Validator Implementation

final class StandardAnswerValidator: AnswerValidator {
    
    private let calculator: Calculator
    private let minimumTokenCount: Int
    
    init(calculator: Calculator, minimumTokenCount: Int = 3) {
        self.calculator = calculator
        self.minimumTokenCount = minimumTokenCount
    }
    
    func validateAnswer(
        tokens: [NumericToken],
        operands: [ArithmeticOperand],
        targetValue: Int
    ) -> ValidationOutcome {
        
        guard tokens.count >= minimumTokenCount else {
            return .insufficientTokens(minimum: minimumTokenCount)
        }
        
        let expectedOperandCount = tokens.count - 1
        guard operands.count == expectedOperandCount else {
            return .incorrectOperandCount(
                expected: expectedOperandCount,
                received: operands.count
            )
        }
        
        let computationResult = calculator.calculate(tokens: tokens, operands: operands)
        
        guard computationResult.isValid else {
            return .incorrectResult(expected: targetValue, obtained: 0)
        }
        
        let isCorrect = abs(computationResult.value - Double(targetValue)) < 0.001
        
        if isCorrect {
            let points = calculateBasePoints(tokenCount: tokens.count)
            return .correct(points: points)
        } else {
            return .incorrectResult(expected: targetValue, obtained: computationResult.value)
        }
    }
    
    private func calculateBasePoints(tokenCount: Int) -> Int {
        return 10
    }
}

// MARK: - Solvability Checker Implementation

final class StandardSolvabilityChecker: SolvabilityChecker {
    
    private let calculator: Calculator
    
    init(calculator: Calculator) {
        self.calculator = calculator
    }
    
    func isSolvable(targetValue: Int, tokens: [NumericToken], configuration: ChallengeConfiguration) -> Bool {
        
        let minCount = configuration.minimumTokenUsage
        let maxCount = min(configuration.maximumTokenUsage, tokens.count)
        
        for count in minCount...maxCount {
            let combinations = generateCombinations(from: tokens, count: count)
            
            for combination in combinations {
                if canReachTarget(target: targetValue, tokens: combination) {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func canReachTarget(target: Int, tokens: [NumericToken]) -> Bool {
        guard !tokens.isEmpty else { return false }
        guard tokens.count > 0 else { return false }
        
        if tokens.count == 1 {
            return tokens[0].numericValue == target
        }
        
        let permutations = generatePermutations(tokens: tokens)
        
        for permutation in permutations {
            let operandCount = permutation.count - 1
            let operandCombinations = generateOperandCombinations(count: operandCount)
            
            for operands in operandCombinations {
                let result = calculator.calculate(tokens: permutation, operands: operands)
                
                if result.isValid && abs(result.value - Double(target)) < 0.001 {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func generateCombinations(from tokens: [NumericToken], count: Int) -> [[NumericToken]] {
        if count == 0 { return [[]] }
        if tokens.isEmpty { return [] }
        
        let first = tokens[0]
        let rest = Array(tokens.dropFirst())
        
        let withFirst = generateCombinations(from: rest, count: count - 1).map { [first] + $0 }
        let withoutFirst = generateCombinations(from: rest, count: count)
        
        return withFirst + withoutFirst
    }
    
    private func generatePermutations(tokens: [NumericToken]) -> [[NumericToken]] {
        if tokens.count <= 1 { return [tokens] }
        
        var result: [[NumericToken]] = []
        
        for i in 0..<tokens.count {
            let current = tokens[i]
            var remaining = tokens
            remaining.remove(at: i)
            
            let permutationsOfRest = generatePermutations(tokens: remaining)
            for permutation in permutationsOfRest {
                result.append([current] + permutation)
            }
        }
        
        return result
    }
    
    private func generateOperandCombinations(count: Int) -> [[ArithmeticOperand]] {
        if count == 0 { return [[]] }
        if count == 1 {
            return ArithmeticOperand.allCases.map { [$0] }
        }
        
        let smallerCombinations = generateOperandCombinations(count: count - 1)
        var result: [[ArithmeticOperand]] = []
        
        for combination in smallerCombinations {
            for operand in ArithmeticOperand.allCases {
                result.append(combination + [operand])
            }
        }
        
        return result
    }
}

// MARK: - Quest Generator Implementation

final class StandardQuestGenerator: QuestGenerator {
    
    private let solvabilityChecker: SolvabilityChecker
    private let maxAttempts: Int
    
    init(solvabilityChecker: SolvabilityChecker, maxAttempts: Int = 100) {
        self.solvabilityChecker = solvabilityChecker
        self.maxAttempts = maxAttempts
    }
    
    func generateQuest(mode: ChallengeMode) -> QuestState {
        let configuration = mode.configuration
        var attempts = 0
        
        while attempts < maxAttempts {
            let targetValue = configuration.generateTargetValue()
            let tokens = NumericToken.createTokenCollection(count: configuration.tokenCount)
            
            if solvabilityChecker.isSolvable(targetValue: targetValue, tokens: tokens, configuration: configuration) {
                return QuestState(targetValue: targetValue, tokens: tokens, mode: mode)
            }
            
            attempts += 1
        }
        
        return createGuaranteedSolvableQuest(mode: mode, configuration: configuration)
    }
    
    private func createGuaranteedSolvableQuest(mode: ChallengeMode, configuration: ChallengeConfiguration) -> QuestState {
        let useMultiplication = Bool.random()
        
        let a: Int
        let b: Int
        let targetValue: Int
        
        if useMultiplication {
            a = Int.random(in: 3...9)
            b = Int.random(in: 3...9)
            targetValue = a * b
        } else {
            a = Int.random(in: 5...20)
            b = Int.random(in: 5...20)
            targetValue = a + b
        }
        
        var tokens: [NumericToken] = [
            NumericToken(colorScheme: .freun, value: a),
            NumericToken(colorScheme: .joirars, value: b)
        ]
        
        while tokens.count < configuration.tokenCount {
            tokens.append(NumericToken.createRandomToken())
        }
        
        tokens.shuffle()
        
        return QuestState(targetValue: targetValue, tokens: tokens, mode: mode)
    }
}

// MARK: - Main Quest Logic Handler (Facade)

final class QuestLogicHandler {
    
    // MARK: Properties
    
    private let questGenerator: QuestGenerator
    private let answerValidator: AnswerValidator
    
    // MARK: Shared Instance
    
    static let shared: QuestLogicHandler = {
        let calculator = StandardCalculator()
        let solvabilityChecker = StandardSolvabilityChecker(calculator: calculator)
        let questGenerator = StandardQuestGenerator(solvabilityChecker: solvabilityChecker)
        let answerValidator = StandardAnswerValidator(calculator: calculator)
        
        return QuestLogicHandler(
            questGenerator: questGenerator,
            answerValidator: answerValidator
        )
    }()
    
    // MARK: Initialization
    
    init(questGenerator: QuestGenerator, answerValidator: AnswerValidator) {
        self.questGenerator = questGenerator
        self.answerValidator = answerValidator
    }
    
    // MARK: Public Methods
    
    func generateQuest(mode: ChallengeMode) -> QuestState {
        return questGenerator.generateQuest(mode: mode)
    }
    
    func validateAnswer(
        selectedTokens: [NumericToken],
        selectedOperands: [ArithmeticOperand],
        targetValue: Int
    ) -> ValidationOutcome {
        return answerValidator.validateAnswer(
            tokens: selectedTokens,
            operands: selectedOperands,
            targetValue: targetValue
        )
    }
    
    // MARK: Legacy Compatibility
    
    @available(*, deprecated, message: "Use generateQuest(mode:) instead")
    static func generiereSpiel(modus: ChallengeMode) -> (zielWert: Int, kacheln: [NumericToken]) {
        let state = shared.generateQuest(mode: modus)
        return (state.targetValue, state.tokens)
    }
    
    @available(*, deprecated, message: "Use shared.validateAnswer instead")
    static func validiereAntwort(
        ausgewaehlteKacheln: [NumericToken],
        ausgewaehlteOperatoren: [ArithmeticOperand],
        zielWert: Int
    ) -> ValidationOutcome {
        return shared.validateAnswer(
            selectedTokens: ausgewaehlteKacheln,
            selectedOperands: ausgewaehlteOperatoren,
            targetValue: zielWert
        )
    }
}

// MARK: - Score Handler (Score Manager)

protocol ScoreStorage {
    func retrieveScore(forMode mode: ChallengeMode) -> Int
    func storeScore(_ score: Int, forMode mode: ChallengeMode)
}

final class ScoreHandler: ScoreStorage {
    
    // MARK: Shared Instance
    
    static let shared = ScoreHandler()
    
    // MARK: Properties
    
    private let keySimple = "score_simple"
    private let keyHard = "score_hard"
    private let keyTime = "score_time"
    private let storage: UserDefaults
    
    // MARK: Initialization
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
    }
    
    // MARK: Public Methods
    
    func retrieveScore(forMode mode: ChallengeMode) -> Int {
        let key = keyForMode(mode)
        return storage.integer(forKey: key)
    }
    
    func storeScore(_ score: Int, forMode mode: ChallengeMode) {
        let key = keyForMode(mode)
        let currentScore = retrieveScore(forMode: mode)
        if score > currentScore {
            storage.set(score, forKey: key)
        }
    }
    
    func updateScore(_ score: Int, forMode mode: ChallengeMode) {
        let key = keyForMode(mode)
        storage.set(score, forKey: key)
    }
    
    func resetAllScores() {
        ChallengeMode.allCases.forEach { mode in
            updateScore(0, forMode: mode)
        }
    }
    
    // MARK: Private Methods
    
    private func keyForMode(_ mode: ChallengeMode) -> String {
        switch mode {
        case .einfach: return keySimple
        case .schwierig: return keyHard
        case .zeit: return keyTime
        }
    }
}
