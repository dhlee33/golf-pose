//
//  AnalyzeManager.swift.swift
//  golf-pose
//
//  Created by 이동현 on 2021/12/17.
//

import Foundation
import TensorFlowLite

enum AnalyzingError: Error {
    case notFound
    case parsingError
}

protocol AnalyzeManager {

}

final class DefaultAnalyzeManager: AnalyzeManager {
    func result(from csv: String) throws -> DTOResult {
        guard let modelPath = Bundle.main.path(forResource: "model", ofType: "tflite") else {
            throw AnalyzingError.notFound
        }

        // Initialize an interpreter with the model.
        let interpreter = try Interpreter(modelPath: modelPath)

        // Allocate memory for the model's input `Tensor`s.
        try interpreter.allocateTensors()

        guard let inputData: Data = csv.data(using: .utf8) else {
            throw AnalyzingError.parsingError
        }

        // Copy the input data to the input `Tensor`.
        try interpreter.copy(inputData, toInputAt: 0)

        // Run inference by invoking the `Interpreter`.
        try interpreter.invoke()

        // Get the output `Tensor`
        let outputTensor = try interpreter.output(at: 0)
        let jsonDecoder = JSONDecoder()

        return try jsonDecoder.decode(DTOResult.self, from: outputTensor.data)
    }
}
