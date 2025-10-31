//
//  GameStateMachine.swift
//  MasterMath
//
//  Application Layer - State Machine
//

import Foundation

final class GameStateMachine {
    
    enum State: Equatable {
        case idle
        case active
        case paused
        case completed
        case terminated
    }
    
    enum Transition {
        case start
        case pause
        case resume
        case complete
        case terminate
    }
    
    private(set) var currentState: State = .idle
    private let eventBus: EventBusProtocol
    
    init(eventBus: EventBusProtocol) {
        self.eventBus = eventBus
    }
    
    func transition(_ transition: Transition) {
        let newState = determineNextState(from: currentState, transition: transition)
        
        if newState != currentState {
            currentState = newState
            eventBus.publish(GameStateChangedEvent(state: newState))
        }
    }
    
    private func determineNextState(from state: State, transition: Transition) -> State {
        switch (state, transition) {
        case (.idle, .start):
            return .active
        case (.active, .pause):
            return .paused
        case (.paused, .resume):
            return .active
        case (.active, .complete):
            return .completed
        case (.active, .terminate), (.paused, .terminate), (.completed, .terminate):
            return .terminated
        case (.idle, .start):
            return .active
        default:
            return state
        }
    }
}

