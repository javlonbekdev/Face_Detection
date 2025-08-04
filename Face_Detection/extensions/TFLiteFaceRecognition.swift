//
//  TFLiteFaceRecognition.swift
//  Face_Detection
//
//  Created by Javlonbek Dev on 19/02/25.
//

import UIKit
import TensorFlowLite

class TFLiteFaceRecognition {
    
    private let modelFileName = "facenetnew.tflite"
    private let inputSize: Int
    private let outputSize = 512
    private let isModelQuantized: Bool
    private var interpreter: Interpreter?
    
    private var idToLabel: [Int64: Int] = [:]

    init(inputSize: Int, isQuantized: Bool) {
        self.inputSize = inputSize
        self.isModelQuantized = isQuantized
//        VectorData
//        self.annDatabase = ANNDatabase(dimension: outputSize, numTables: 20, numFunctions: 7, w: 4.0)
        loadModel()
    }

    private func loadModel() {
        guard let modelPath = Bundle.main.path(forResource: modelFileName, ofType: nil) else {
            print("Model file not found!")
            return
        }

        do {
            var options = Interpreter.Options()
            options.threadCount = 4

            interpreter = try Interpreter(modelPath: modelPath, options: options)
        } catch {
            print("Failed to create TensorFlow Lite interpreter: \(error)")
        }
    }

    func registerFace(id: Int, embedding: [Float]) {
//        let vectorId = annDatabase.insert(vector: embedding)
//        idToLabel[vectorId] = id
    }

    func recognizeFace(from image: UIImage) -> (String, Float)? {
        guard let interpreter = interpreter else {
            print("Interpreter not initialized!")
            return nil
        }
        
        guard let pixelBuffer = image.toPixelBuffer(size: inputSize) else {
            return nil
        }
        
        do {
            let inputTensor = try interpreter.input(at: 0)
            let byteCount = inputSize * inputSize * 3 * (isModelQuantized ? 1 : 4)
            var inputData = Data(count: byteCount)
            
            try interpreter.copy(inputData, toInputAt: 0)
            
            try interpreter.invoke()
            
            let outputTensor = try interpreter.output(at: 0)
            var outputData = [Float](repeating: 0, count: outputSize)
//            try outputTensor.copyData(to: &outputData)
            
//            let nearestNeighbors = annDatabase.query(vector: outputData, k: 2)
            
//            if let nearest = nearestNeighbors.first, let userId = idToLabel[nearest.id] {
//                return ("User \(userId)", nearest.distance)
//            }
        } catch {
            print("Error running inference: \(error)")
        }
        return nil
    }
}
