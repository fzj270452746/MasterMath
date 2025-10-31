//
//  SolvabilityVerification.swift
//  MasterMath
//
//  Domain Layer - Solvability Verification
//

import Foundation

protocol SolvabilityVerificationProtocol {
    func verify(
        target: Int,
        tiles: [Int],
        configuration: GameModeEntity
    ) -> Bool
}

final class SolvabilityVerificationService: SolvabilityVerificationProtocol {
    
    private let calculator: ArithmeticComputationProtocol
    
    init(calculator: ArithmeticComputationProtocol) {
        self.calculator = calculator
    }
    
    func verify(
        target: Int,
        tiles: [Int],
        configuration: GameModeEntity
    ) -> Bool {
        
        let minCount = configuration.minTileUsage
        let maxCount = min(configuration.maxTileUsage, tiles.count)
        
        for count in minCount...maxCount {
            let combinations = generateCombinations(from: tiles, count: count)
            
            for combination in combinations {
                if canAchieveTarget(target: target, values: combination) {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func canAchieveTarget(target: Int, values: [Int]) -> Bool {
        guard !values.isEmpty else { return false }
        if values.count == 1 {
            return values[0] == target
        }
        
        let permutations = generatePermutations(values: values)
        
        for permutation in permutations {
            let operatorCount = permutation.count - 1
            let operatorCombinations = generateOperatorCombinations(count: operatorCount)
            
            for operators in operatorCombinations {
                if let result = calculator.performCalculation(
                    values: permutation.map { Double($0) },
                    operators: operators
                ), abs(result - Double(target)) < 0.001 {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func generateCombinations(from values: [Int], count: Int) -> [[Int]] {
        if count == 0 { return [[]] }
        if values.isEmpty { return [] }
        
        let first = values[0]
        let rest = Array(values.dropFirst())
        
        let withFirst = generateCombinations(from: rest, count: count - 1).map { [first] + $0 }
        let withoutFirst = generateCombinations(from: rest, count: count)
        
        return withFirst + withoutFirst
    }
    
    private func generatePermutations(values: [Int]) -> [[Int]] {
        if values.count <= 1 { return [values] }
        
        var result: [[Int]] = []
        
        for i in 0..<values.count {
            let current = values[i]
            var remaining = values
            remaining.remove(at: i)
            
            let permutationsOfRest = generatePermutations(values: remaining)
            for permutation in permutationsOfRest {
                result.append([current] + permutation)
            }
        }
        
        return result
    }
    
    private func generateOperatorCombinations(count: Int) -> [[OperatorEntity]] {
        if count == 0 { return [[]] }
        if count == 1 {
            return OperatorEntity.allCases.map { [$0] }
        }
        
        let smallerCombinations = generateOperatorCombinations(count: count - 1)
        var result: [[OperatorEntity]] = []
        
        for combination in smallerCombinations {
            for op in OperatorEntity.allCases {
                result.append(combination + [op])
            }
        }
        
        return result
    }
}

