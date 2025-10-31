//
//  DomainAdapter.swift
//  MasterMath
//
//  Adapter Layer - Bridges old and new domain models
//

import Foundation

// MARK: - NumericToken to TileEntity Adapter

extension TileEntity {
    init(from token: NumericToken) {
        let theme: TileColorTheme
        switch token.colorScheme {
        case .freun: theme = .red
        case .joirars: theme = .blue
        case .sortie: theme = .green
        }
        
        self.init(
            id: token.uniqueIdentifier,
            numericValue: token.numericValue,
            colorTheme: theme,
            isChosen: token.isSelected
        )
    }
}

extension NumericToken {
    convenience init(from entity: TileEntity) {
        let scheme: TokenColorScheme
        switch entity.colorTheme {
        case .red: scheme = .freun
        case .blue: scheme = .joirars
        case .green: scheme = .sortie
        }
        
        self.init(
            colorScheme: scheme,
            value: entity.numericValue,
            uniqueIdentifier: entity.id
        )
        self.isSelected = entity.isChosen
    }
}

// MARK: - ArithmeticOperand to OperatorEntity Adapter

extension OperatorEntity {
    init(from operand: ArithmeticOperand) {
        switch operand {
        case .addieren: self = .addition
        case .subtrahieren: self = .subtraction
        case .multiplizieren: self = .multiplication
        case .dividieren: self = .division
        }
    }
}

extension ArithmeticOperand {
    init(from entity: OperatorEntity) {
        switch entity {
        case .addition: self = .addieren
        case .subtraction: self = .subtrahieren
        case .multiplication: self = .multiplizieren
        case .division: self = .dividieren
        }
    }
}

// MARK: - ChallengeMode to GameModeEntity Adapter

extension GameModeEntity {
    init(from mode: ChallengeMode) {
        switch mode {
        case .einfach: self = .simple
        case .schwierig: self = .hard
        case .zeit: self = .time
        }
    }
}

extension ChallengeMode {
    init(from entity: GameModeEntity) {
        switch entity.identifier {
        case "simple": self = .einfach
        case "hard": self = .schwierig
        case "time": self = .zeit
        default: self = .einfach
        }
    }
}

// MARK: - ValidationResult Adapter

extension ValidationResultEntity {
    init(from outcome: ValidationOutcome) {
        switch outcome {
        case .correct(let points):
            self = .success(pointsEarned: points)
        case .insufficientTokens(let minimum):
            self = .failure(reason: .notEnoughTiles(minimum: minimum))
        case .incorrectOperandCount(let expected, let received):
            self = .failure(reason: .operatorCountMismatch(expected: expected, actual: received))
        case .incorrectResult(let expected, let obtained):
            self = .failure(reason: .incorrectAnswer(expected: expected, computed: obtained))
        }
    }
}

extension ValidationOutcome {
    init(from entity: ValidationResultEntity) {
        switch entity {
        case .success(let points):
            self = .correct(points: points)
        case .failure(let reason):
            switch reason {
            case .notEnoughTiles(let minimum):
                self = .insufficientTokens(minimum: minimum)
            case .operatorCountMismatch(let expected, let actual):
                self = .incorrectOperandCount(expected: expected, received: actual)
            case .incorrectAnswer(let expected, let computed):
                self = .incorrectResult(expected: expected, obtained: computed)
            case .computationError:
                self = .incorrectResult(expected: 0, obtained: 0)
            }
        }
    }
}

