

import Foundation

final class GameSessionManager {
    
    private(set) var currentPuzzle: PuzzleEntity?
    private(set) var selectedTiles: [TileEntity] = []
    private(set) var selectedOperators: [OperatorEntity] = []
    private(set) var currentScore: Int = 0
    private(set) var currentLevel: Int = 1
    private(set) var timeRemaining: Int = 0
    
    private let eventBus: EventBusProtocol
    private let stateMachine: GameStateMachine
    private let scoreRepository: ScoreRepositoryProtocol
    private var timer: Timer?
    private var lastSelectionType: SelectionType = .none
    
    enum SelectionType {
        case none
        case tile
        case `operator`
    }
    
    init(
        eventBus: EventBusProtocol,
        stateMachine: GameStateMachine,
        scoreRepository: ScoreRepositoryProtocol
    ) {
        self.eventBus = eventBus
        self.stateMachine = stateMachine
        self.scoreRepository = scoreRepository
        setupEventListeners()
    }
    
    private func setupEventListeners() {
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
        
        eventBus.subscribe(GameStartedEvent.self) { [weak self] event in
            self?.handleGameStarted(event.mode)
        }
        
        eventBus.subscribe(GameEndedEvent.self) { [weak self] event in
            self?.handleGameEnded(event.finalScore, event.finalLevel)
        }
    }
    
    private func handlePuzzleGenerated(_ puzzle: PuzzleEntity) {
        currentPuzzle = puzzle
        clearSelection()
    }
    
    private func handleTileSelected(_ tile: TileEntity) {
        guard var puzzle = currentPuzzle else { return }
        
        if let index = puzzle.availableTiles.firstIndex(where: { $0.id == tile.id }) {
            var updatedTile = puzzle.availableTiles[index]
            
            if updatedTile.isChosen {
                updatedTile.clearSelection()
                selectedTiles.removeAll { $0.id == tile.id }
                if selectedTiles.isEmpty {
                    lastSelectionType = .none
                }
            } else {
                // 游戏规则：必须先选择牌，然后是运算符，不能连续选择两张牌
                // 如果已经选择了牌，在选择下一张牌之前，运算符数量必须等于已选牌数
                if !selectedTiles.isEmpty && selectedOperators.count < selectedTiles.count {
                    return
                }
                updatedTile.toggleSelection()
                selectedTiles.append(updatedTile)
                lastSelectionType = .tile
            }
            
            var updatedTiles = puzzle.availableTiles
            updatedTiles[index] = updatedTile
            currentPuzzle = PuzzleEntity(
                targetNumber: puzzle.targetNumber,
                availableTiles: updatedTiles,
                mode: puzzle.mode
            )
        }
    }
    
    private func handleOperatorSelected(_ operatorEntity: OperatorEntity) {
        selectedOperators.append(operatorEntity)
        lastSelectionType = .operator
    }
    
    private func handleSelectionCleared() {
        clearSelection()
    }
    
    private func handleAnswerValidated(_ result: ValidationResultEntity) {
        if case .success(let points) = result {
            currentScore += points * currentLevel
            currentLevel += 1
            eventBus.publish(ScoreUpdatedEvent(
                currentScore: currentScore,
                currentLevel: currentLevel
            ))
        }
    }
    
    private func handleGameStarted(_ mode: GameModeEntity) {
        currentScore = 0
        currentLevel = 1
        timeRemaining = mode.hasTimer ? mode.timerDuration : 0
        
        if mode.hasTimer {
            startTimer()
        }
    }
    
    private func handleGameEnded(_ finalScore: Int, _ finalLevel: Int) {
        stopTimer()
        if let mode = currentPuzzle?.mode {
            scoreRepository.saveScore(ScoreEntity(
                modeIdentifier: mode.identifier,
                value: finalScore
            ))
        }
    }
    
    private func clearSelection() {
        selectedTiles.forEach { tile in
            if let index = currentPuzzle?.availableTiles.firstIndex(where: { $0.id == tile.id }) {
                var updatedTile = currentPuzzle!.availableTiles[index]
                updatedTile.clearSelection()
                var updatedTiles = currentPuzzle!.availableTiles
                updatedTiles[index] = updatedTile
                currentPuzzle = PuzzleEntity(
                    targetNumber: currentPuzzle!.targetNumber,
                    availableTiles: updatedTiles,
                    mode: currentPuzzle!.mode
                )
            }
        }
        selectedTiles.removeAll()
        selectedOperators.removeAll()
        lastSelectionType = .none
    }
    
    private func startTimer() {
        stopTimer()
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
        eventBus.publish(TimerTickEvent(remainingSeconds: timeRemaining))
        
        if timeRemaining <= 0 {
            if let puzzle = currentPuzzle {
                EndGameCommand(
                    finalScore: currentScore,
                    finalLevel: currentLevel,
                    eventBus: eventBus
                ).execute()
            }
        }
    }
    
    func createAnswer() -> AnswerEntity {
        return AnswerEntity(
            selectedTiles: selectedTiles,
            selectedOperators: selectedOperators
        )
    }
}

