//
//  ScoreRepository.swift
//  MasterMath
//
//  Domain Layer - Score Repository
//

import Foundation

protocol ScoreRepositoryProtocol {
    func fetchBestScore(for modeIdentifier: String) -> Int
    func saveScore(_ score: ScoreEntity)
    func resetScores(for modeIdentifier: String)
    func resetAllScores()
}

final class ScoreRepository: ScoreRepositoryProtocol {
    
    private let storage: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }
    
    func fetchBestScore(for modeIdentifier: String) -> Int {
        let key = scoreKey(for: modeIdentifier)
        return storage.integer(forKey: key)
    }
    
    func saveScore(_ score: ScoreEntity) {
        let key = scoreKey(for: score.modeIdentifier)
        let currentBest = fetchBestScore(for: score.modeIdentifier)
        
        if score.value > currentBest {
            storage.set(score.value, forKey: key)
        }
    }
    
    func resetScores(for modeIdentifier: String) {
        let key = scoreKey(for: modeIdentifier)
        storage.set(0, forKey: key)
    }
    
    func resetAllScores() {
        ["simple", "hard", "time"].forEach { modeIdentifier in
            resetScores(for: modeIdentifier)
        }
    }
    
    private func scoreKey(for modeIdentifier: String) -> String {
        "score_\(modeIdentifier)"
    }
}

