//
//  NumericToken.swift
//  MasterMath
//
//  Numeric Token Data Model
//

import UIKit

// MARK: - Protocols

protocol Computable {
    var numericValue: Int { get }
}

protocol Selectable: AnyObject {
    var isSelected: Bool { get set }
    var uniqueIdentifier: UUID { get }
}

protocol VisuallyRepresentable {
    var imageAssetName: String { get }
    var displayColor: UIColor { get }
}

// MARK: - Enumerations

enum TokenColorScheme: String, CaseIterable, Codable {
    case freun = "Freun"
    case joirars = "Joirars"
    case sortie = "Sortie"
    
    var associatedColor: UIColor {
        switch self {
        case .freun: return .systemRed
        case .joirars: return .systemBlue
        case .sortie: return .systemGreen
        }
    }
    
    static func random() -> TokenColorScheme {
        return allCases.randomElement() ?? .freun
    }
}

enum ArithmeticOperand: String, CaseIterable, Codable {
    case addieren = "Operator_add"
    case subtrahieren = "Operator_subtract"
    case multiplizieren = "Operator_multiply"
    case dividieren = "Operator_divide"
    
    var symbol: String {
        switch self {
        case .addieren: return "+"
        case .subtrahieren: return "-"
        case .multiplizieren: return "×"
        case .dividieren: return "÷"
        }
    }
    
    var precedence: Int {
        switch self {
        case .addieren, .subtrahieren: return 1
        case .multiplizieren, .dividieren: return 2
        }
    }
}

// MARK: - Calculation Extension

extension ArithmeticOperand {
    func executeOperation(left: Double, right: Double) -> ComputationResult {
        let outcome: Double
        var error: ComputationError?
        
        switch self {
        case .addieren:
            outcome = left + right
        case .subtrahieren:
            outcome = left - right
        case .multiplizieren:
            outcome = left * right
        case .dividieren:
            if right == 0 {
                error = .divisionByZero
                outcome = 0
            } else {
                outcome = left / right
            }
        }
        
        return ComputationResult(value: outcome, error: error)
    }
}

// MARK: - Computation Models

struct ComputationResult {
    let value: Double
    let error: ComputationError?
    
    var isValid: Bool { error == nil }
}

enum ComputationError: Error {
    case divisionByZero
    case invalidValue
}

// MARK: - Numeric Token Model

class NumericToken: Selectable, Computable, VisuallyRepresentable {
    
    // MARK: Properties
    
    let colorScheme: TokenColorScheme
    private(set) var value: Int
    let uniqueIdentifier: UUID
    var isSelected: Bool
    
    // MARK: Computed Properties
    
    var imageAssetName: String {
        "\(colorScheme.rawValue)_\(value)"
    }
    
    var displayColor: UIColor {
        colorScheme.associatedColor
    }
    
    var numericValue: Int {
        value
    }
    
    // MARK: Initialization
    
    init(colorScheme: TokenColorScheme, value: Int, uniqueIdentifier: UUID = UUID()) {
        self.colorScheme = colorScheme
        self.value = min(max(value, 1), 9)
        self.uniqueIdentifier = uniqueIdentifier
        self.isSelected = false
    }
    
    // MARK: Factory Methods
    
    static func createRandomToken() -> NumericToken {
        let colorScheme = TokenColorScheme.random()
        let value = Int.random(in: 1...9)
        return NumericToken(colorScheme: colorScheme, value: value)
    }
    
    static func createTokenCollection(count: Int) -> [NumericToken] {
        return (0..<count).map { _ in createRandomToken() }
    }
    
    // MARK: Methods
    
    func reset() {
        isSelected = false
    }
    
    func copy() -> NumericToken {
        return NumericToken(colorScheme: colorScheme, value: value, uniqueIdentifier: UUID())
    }
}

// MARK: - Equatable

extension NumericToken: Equatable {
    static func == (lhs: NumericToken, rhs: NumericToken) -> Bool {
        return lhs.uniqueIdentifier == rhs.uniqueIdentifier
    }
}

// MARK: - Challenge Mode

enum ChallengeMode: String, CaseIterable {
    case einfach = "Simple Mode"
    case schwierig = "Hard Mode"
    case zeit = "Time Mode"
    
    var configuration: ChallengeConfiguration {
        switch self {
        case .einfach:
            return ChallengeConfiguration(
                tokenCount: 5,
                minimumTokenUsage: 3,
                maximumTokenUsage: 5,
                targetValueRange: 10...100,
                hasTimeLimit: false,
                timeLimitInSeconds: 0
            )
        case .schwierig:
            return ChallengeConfiguration(
                tokenCount: 10,
                minimumTokenUsage: 3,
                maximumTokenUsage: 6,
                targetValueRange: 10...100,
                hasTimeLimit: false,
                timeLimitInSeconds: 0
            )
        case .zeit:
            return ChallengeConfiguration(
                tokenCount: 5,
                minimumTokenUsage: 3,
                maximumTokenUsage: 5,
                targetValueRange: 10...100,
                hasTimeLimit: true,
                timeLimitInSeconds: 60
            )
        }
    }
}

// MARK: - Challenge Configuration

struct ChallengeConfiguration {
    let tokenCount: Int
    let minimumTokenUsage: Int
    let maximumTokenUsage: Int
    let targetValueRange: ClosedRange<Int>
    let hasTimeLimit: Bool
    let timeLimitInSeconds: Int
    
    func generateTargetValue() -> Int {
        return Int.random(in: targetValueRange)
    }
}

// MARK: - Validation Outcome

enum ValidationOutcome {
    case correct(points: Int)
    case insufficientTokens(minimum: Int)
    case incorrectOperandCount(expected: Int, received: Int)
    case incorrectResult(expected: Int, obtained: Double)
    
    var isSuccessful: Bool {
        if case .correct = self { return true }
        return false
    }
    
    var errorDescription: String? {
        switch self {
        case .correct:
            return nil
        case .insufficientTokens(let minimum):
            return "Please select at least \(minimum) tokens."
        case .incorrectOperandCount(let expected, let received):
            return "Expected \(expected) operands, but \(received) were selected."
        case .incorrectResult(let expected, let obtained):
            return "Expected: \(expected), Obtained: \(Int(obtained))"
        }
    }
}
