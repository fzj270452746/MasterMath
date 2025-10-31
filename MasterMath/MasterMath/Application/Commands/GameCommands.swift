//
//  GameCommands.swift
//  MasterMath
//
//  Application Layer - Command Pattern
//

import Foundation

// MARK: - Command Protocol

protocol CommandProtocol {
    func execute()
}

// MARK: - Command Handler

protocol CommandHandlerProtocol {
    func handle<T: CommandProtocol>(_ command: T)
}

final class CommandHandler: CommandHandlerProtocol {
    func handle<T: CommandProtocol>(_ command: T) {
        command.execute()
    }
}

// MARK: - Game Commands

struct StartGameCommand: CommandProtocol {
    let mode: GameModeEntity
    let eventBus: EventBusProtocol
    let puzzleGenerator: PuzzleGenerationUseCaseProtocol
    
    func execute() {
        let puzzle = puzzleGenerator.execute(mode: mode)
        eventBus.publish(GameStartedEvent(mode: mode))
        eventBus.publish(PuzzleGeneratedEvent(puzzle: puzzle))
    }
}

struct SelectTileCommand: CommandProtocol {
    let tile: TileEntity
    let eventBus: EventBusProtocol
    
    func execute() {
        eventBus.publish(TileSelectedEvent(tile: tile))
    }
}

struct SelectOperatorCommand: CommandProtocol {
    let operatorEntity: OperatorEntity
    let eventBus: EventBusProtocol
    
    func execute() {
        eventBus.publish(OperatorSelectedEvent(operator: operatorEntity))
    }
}

struct ClearSelectionCommand: CommandProtocol {
    let eventBus: EventBusProtocol
    
    func execute() {
        eventBus.publish(SelectionClearedEvent())
    }
}

struct SubmitAnswerCommand: CommandProtocol {
    let answer: AnswerEntity
    let targetValue: Int
    let eventBus: EventBusProtocol
    let validator: AnswerValidationUseCaseProtocol
    
    func execute() {
        eventBus.publish(AnswerSubmittedEvent(answer: answer))
        let result = validator.execute(answer: answer, targetValue: targetValue)
        eventBus.publish(AnswerValidatedEvent(result: result))
    }
}

struct RefreshPuzzleCommand: CommandProtocol {
    let mode: GameModeEntity
    let eventBus: EventBusProtocol
    let puzzleGenerator: PuzzleGenerationUseCaseProtocol
    
    func execute() {
        let puzzle = puzzleGenerator.execute(mode: mode)
        eventBus.publish(PuzzleGeneratedEvent(puzzle: puzzle))
    }
}

struct EndGameCommand: CommandProtocol {
    let finalScore: Int
    let finalLevel: Int
    let eventBus: EventBusProtocol
    
    func execute() {
        eventBus.publish(GameEndedEvent(finalScore: finalScore, finalLevel: finalLevel))
    }
}

struct RestartGameCommand: CommandProtocol {
    let mode: GameModeEntity
    let eventBus: EventBusProtocol
    let puzzleGenerator: PuzzleGenerationUseCaseProtocol
    
    func execute() {
        let puzzle = puzzleGenerator.execute(mode: mode)
        eventBus.publish(GameStartedEvent(mode: mode))
        eventBus.publish(PuzzleGeneratedEvent(puzzle: puzzle))
    }
}

