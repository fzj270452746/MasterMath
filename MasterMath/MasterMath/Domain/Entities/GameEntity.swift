//
//  GameEntity.swift
//  MasterMath
//
//  Domain Layer - Game Entities
//

import Foundation

// MARK: - Game Mode Entity

struct GameModeEntity: Equatable {
    let identifier: String
    let displayName: String
    let tileCount: Int
    let minTileUsage: Int
    let maxTileUsage: Int
    let targetRange: ClosedRange<Int>
    let hasTimer: Bool
    let timerDuration: Int
    
    static let simple = GameModeEntity(
        identifier: "simple",
        displayName: "Simple Mode",
        tileCount: 5,
        minTileUsage: 3,
        maxTileUsage: 5,
        targetRange: 10...100,
        hasTimer: false,
        timerDuration: 0
    )
    
    static let hard = GameModeEntity(
        identifier: "hard",
        displayName: "Hard Mode",
        tileCount: 10,
        minTileUsage: 3,
        maxTileUsage: 6,
        targetRange: 10...100,
        hasTimer: false,
        timerDuration: 0
    )
    
    static let time = GameModeEntity(
        identifier: "time",
        displayName: "Time Mode",
        tileCount: 5,
        minTileUsage: 3,
        maxTileUsage: 5,
        targetRange: 10...100,
        hasTimer: true,
        timerDuration: 60
    )
    
    static func fromChallengeMode(_ mode: ChallengeMode) -> GameModeEntity {
        switch mode {
        case .einfach: return .simple
        case .schwierig: return .hard
        case .zeit: return .time
        }
    }
}

// MARK: - Tile Entity

struct TileEntity: Identifiable, Equatable {
    let id: UUID
    let numericValue: Int
    let colorTheme: TileColorTheme
    var isChosen: Bool
    
    enum TileColorTheme: String, CaseIterable {
        case red = "Freun"
        case blue = "Joirars"
        case green = "Sortie"
        
        var colorName: String { rawValue }
        
        static func random() -> TileColorTheme {
            allCases.randomElement() ?? .red
        }
    }
    
    var imageName: String {
        "\(colorTheme.colorName)_\(numericValue)"
    }
    
    mutating func toggleSelection() {
        isChosen.toggle()
    }
    
    mutating func clearSelection() {
        isChosen = false
    }
}

// MARK: - Operator Entity

enum OperatorEntity: String, CaseIterable {
    case addition = "Operator_add"
    case subtraction = "Operator_subtract"
    case multiplication = "Operator_multiply"
    case division = "Operator_divide"
    
    var symbol: String {
        switch self {
        case .addition: return "+"
        case .subtraction: return "-"
        case .multiplication: return "×"
        case .division: return "÷"
        }
    }
    
    func compute(left: Double, right: Double) -> Double? {
        switch self {
        case .addition: return left + right
        case .subtraction: return left - right
        case .multiplication: return left * right
        case .division: return right != 0 ? left / right : nil
        }
    }
}

// MARK: - Puzzle Entity

struct PuzzleEntity {
    let targetNumber: Int
    let availableTiles: [TileEntity]
    let mode: GameModeEntity
    let createdAt: Date
    
    init(targetNumber: Int, availableTiles: [TileEntity], mode: GameModeEntity) {
        self.targetNumber = targetNumber
        self.availableTiles = availableTiles
        self.mode = mode
        self.createdAt = Date()
    }
}

// MARK: - Answer Entity

struct AnswerEntity {
    let selectedTiles: [TileEntity]
    let selectedOperators: [OperatorEntity]
    
    var isValid: Bool {
        selectedTiles.count >= 3 && 
        selectedOperators.count == selectedTiles.count - 1
    }
}

// MARK: - Validation Result Entity

enum ValidationResultEntity {
    case success(pointsEarned: Int)
    case failure(reason: ValidationFailureReason)
    
    enum ValidationFailureReason {
        case notEnoughTiles(minimum: Int)
        case operatorCountMismatch(expected: Int, actual: Int)
        case incorrectAnswer(expected: Int, computed: Double)
        case computationError
    }
}

// MARK: - Score Entity

struct ScoreEntity: Codable {
    let modeIdentifier: String
    let value: Int
    let achievedAt: Date
    
    init(modeIdentifier: String, value: Int, achievedAt: Date = Date()) {
        self.modeIdentifier = modeIdentifier
        self.value = value
        self.achievedAt = achievedAt
    }
}

