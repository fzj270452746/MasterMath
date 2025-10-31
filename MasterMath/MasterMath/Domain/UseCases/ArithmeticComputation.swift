//
//  ArithmeticComputation.swift
//  MasterMath
//
//  Domain Layer - Arithmetic Computation
//

import Foundation

protocol ArithmeticComputationProtocol {
    func performCalculation(
        values: [Double],
        operators: [OperatorEntity]
    ) -> Double?
}

final class ArithmeticComputationService: ArithmeticComputationProtocol {
    
    func performCalculation(
        values: [Double],
        operators: [OperatorEntity]
    ) -> Double? {
        
        guard !values.isEmpty else { return nil }
        guard values.count == operators.count + 1 else { return nil }
        
        var result = values[0]
        
        for index in 0..<operators.count {
            let nextValue = values[index + 1]
            
            guard let intermediateResult = operators[index].compute(
                left: result,
                right: nextValue
            ) else {
                return nil
            }
            
            result = intermediateResult
        }
        
        return result
    }
}

