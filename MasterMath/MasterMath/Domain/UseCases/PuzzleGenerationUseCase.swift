//
//  PuzzleGenerationUseCase.swift
//  MasterMath
//
//  Domain Layer - Puzzle Generation Use Case
//

import Foundation

protocol PuzzleGenerationUseCaseProtocol {
    func execute(mode: GameModeEntity) -> PuzzleEntity
}

final class PuzzleGenerationUseCase: PuzzleGenerationUseCaseProtocol {
    
    private let solvabilityChecker: SolvabilityVerificationProtocol
    private let maxGenerationAttempts: Int
    
    init(
        solvabilityChecker: SolvabilityVerificationProtocol,
        maxGenerationAttempts: Int = 100
    ) {
        self.solvabilityChecker = solvabilityChecker
        self.maxGenerationAttempts = maxGenerationAttempts
    }
    
    func execute(mode: GameModeEntity) -> PuzzleEntity {
        var attempts = 0
        
        while attempts < maxGenerationAttempts {
            let target = Int.random(in: mode.targetRange)
            let tiles = generateTileSet(count: mode.tileCount)
            
            if solvabilityChecker.verify(
                target: target,
                tiles: tiles.map { $0.numericValue },
                configuration: mode
            ) {
                return PuzzleEntity(
                    targetNumber: target,
                    availableTiles: tiles,
                    mode: mode
                )
            }
            
            attempts += 1
        }
        
        return createFallbackPuzzle(mode: mode)
    }
    
    private func generateTileSet(count: Int) -> [TileEntity] {
        return (0..<count).map { _ in
            TileEntity(
                id: UUID(),
                numericValue: Int.random(in: 1...9),
                colorTheme: .random(),
                isChosen: false
            )
        }
    }
    
    private func createFallbackPuzzle(mode: GameModeEntity) -> PuzzleEntity {
        let useMultiply = Bool.random()
        let first = useMultiply ? Int.random(in: 3...9) : Int.random(in: 5...20)
        let second = useMultiply ? Int.random(in: 3...9) : Int.random(in: 5...20)
        let target = useMultiply ? first * second : first + second
        
        var tiles: [TileEntity] = [
            TileEntity(id: UUID(), numericValue: first, colorTheme: .red, isChosen: false),
            TileEntity(id: UUID(), numericValue: second, colorTheme: .blue, isChosen: false)
        ]
        
        while tiles.count < mode.tileCount {
            tiles.append(TileEntity(
                id: UUID(),
                numericValue: Int.random(in: 1...9),
                colorTheme: .random(),
                isChosen: false
            ))
        }
        
        tiles.shuffle()
        
        return PuzzleEntity(
            targetNumber: target,
            availableTiles: tiles,
            mode: mode
        )
    }
}

