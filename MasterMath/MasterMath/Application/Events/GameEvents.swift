//
//  GameEvents.swift
//  MasterMath
//
//  Application Layer - Game Events (Event Bus)
//

import Foundation

// MARK: - Event Protocol

protocol GameEvent: AnyObject {
    var timestamp: Date { get }
}

// MARK: - Event Bus

protocol EventBusProtocol: AnyObject {
    func publish<T: GameEvent>(_ event: T)
    func subscribe<T: GameEvent>(_ type: T.Type, handler: @escaping (T) -> Void) -> EventSubscription
    func unsubscribe(_ subscription: EventSubscription)
}

final class EventBus: EventBusProtocol {
    
    static let shared = EventBus()
    
    private var subscriptions: [String: [EventSubscription]] = [:]
    private let queue = DispatchQueue(label: "com.mastermath.eventbus", attributes: .concurrent)
    
    private init() {}
    
    func publish<T: GameEvent>(_ event: T) {
        let key = String(describing: T.self)
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let handlers = self.subscriptions[key] ?? []
            
            DispatchQueue.main.async {
                handlers.forEach { subscription in
                    subscription.handler(event)
                }
            }
        }
    }
    
    func subscribe<T: GameEvent>(_ type: T.Type, handler: @escaping (T) -> Void) -> EventSubscription {
        let key = String(describing: T.self)
        let subscription = EventSubscription(
            id: UUID(),
            key: key,
            handler: { event in
                if let typedEvent = event as? T {
                    handler(typedEvent)
                }
            }
        )
        
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if self.subscriptions[key] == nil {
                self.subscriptions[key] = []
            }
            self.subscriptions[key]?.append(subscription)
        }
        
        return subscription
    }
    
    func unsubscribe(_ subscription: EventSubscription) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.subscriptions[subscription.key]?.removeAll { $0.id == subscription.id }
        }
    }
}

final class EventSubscription {
    let id: UUID
    let key: String
    let handler: (GameEvent) -> Void
    
    init(id: UUID, key: String, handler: @escaping (GameEvent) -> Void) {
        self.id = id
        self.key = key
        self.handler = handler
    }
}

// MARK: - Game Events

final class PuzzleGeneratedEvent: GameEvent {
    let timestamp = Date()
    let puzzle: PuzzleEntity
    init(puzzle: PuzzleEntity) {
        self.puzzle = puzzle
    }
}

final class TileSelectedEvent: GameEvent {
    let timestamp = Date()
    let tile: TileEntity
    init(tile: TileEntity) {
        self.tile = tile
    }
}

final class OperatorSelectedEvent: GameEvent {
    let timestamp = Date()
    let operatorEntity: OperatorEntity
    init(operator op: OperatorEntity) {
        self.operatorEntity = op
    }
}

final class SelectionClearedEvent: GameEvent {
    let timestamp = Date()
}

final class AnswerSubmittedEvent: GameEvent {
    let timestamp = Date()
    let answer: AnswerEntity
    init(answer: AnswerEntity) {
        self.answer = answer
    }
}

final class AnswerValidatedEvent: GameEvent {
    let timestamp = Date()
    let result: ValidationResultEntity
    init(result: ValidationResultEntity) {
        self.result = result
    }
}

final class ScoreUpdatedEvent: GameEvent {
    let timestamp = Date()
    let currentScore: Int
    let currentLevel: Int
    init(currentScore: Int, currentLevel: Int) {
        self.currentScore = currentScore
        self.currentLevel = currentLevel
    }
}

final class TimerTickEvent: GameEvent {
    let timestamp = Date()
    let remainingSeconds: Int
    init(remainingSeconds: Int) {
        self.remainingSeconds = remainingSeconds
    }
}

final class GameStartedEvent: GameEvent {
    let timestamp = Date()
    let mode: GameModeEntity
    init(mode: GameModeEntity) {
        self.mode = mode
    }
}

final class GameEndedEvent: GameEvent {
    let timestamp = Date()
    let finalScore: Int
    let finalLevel: Int
    init(finalScore: Int, finalLevel: Int) {
        self.finalScore = finalScore
        self.finalLevel = finalLevel
    }
}

final class GameStateChangedEvent: GameEvent {
    let timestamp = Date()
    let state: GameStateMachine.State
    init(state: GameStateMachine.State) {
        self.state = state
    }
}

