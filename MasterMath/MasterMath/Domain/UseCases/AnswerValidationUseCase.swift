//
//  AnswerValidationUseCase.swift
//  MasterMath
//
//  Domain Layer - Answer Validation Use Case
//

import Foundation

protocol AnswerValidationUseCaseProtocol {
    func execute(
        answer: AnswerEntity,
        targetValue: Int
    ) -> ValidationResultEntity
}

final class AnswerValidationUseCase: AnswerValidationUseCaseProtocol {
    
    private let calculator: ArithmeticComputationProtocol
    private let minTileRequirement: Int
    
    init(
        calculator: ArithmeticComputationProtocol,
        minTileRequirement: Int = 3
    ) {
        self.calculator = calculator
        self.minTileRequirement = minTileRequirement
    }
    
    func execute(
        answer: AnswerEntity,
        targetValue: Int
    ) -> ValidationResultEntity {
        
        guard answer.selectedTiles.count >= minTileRequirement else {
            return .failure(reason: .notEnoughTiles(minimum: minTileRequirement))
        }
        
        let expectedOperatorCount = answer.selectedTiles.count - 1
        guard answer.selectedOperators.count == expectedOperatorCount else {
            return .failure(reason: .operatorCountMismatch(
                expected: expectedOperatorCount,
                actual: answer.selectedOperators.count
            ))
        }
        
        let computationResult = calculator.performCalculation(
            values: answer.selectedTiles.map { Double($0.numericValue) },
            operators: answer.selectedOperators
        )
        
        guard let computedValue = computationResult else {
            return .failure(reason: .computationError)
        }
        
        let difference = abs(computedValue - Double(targetValue))
        if difference < 0.001 {
            let basePoints = 10
            return .success(pointsEarned: basePoints)
        } else {
            return .failure(reason: .incorrectAnswer(
                expected: targetValue,
                computed: computedValue
            ))
        }
    }
}

