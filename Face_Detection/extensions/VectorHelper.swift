//
//  VectorHelper.swift
//  Face_Detection
//
//  Created by Javlonbek Dev on 17/11/24.
//

import UIKit
import RealmSwift
import CoreML
import TensorFlowLite

class VectorHelper {
    
    let realm = try! Realm()
    var kMeanVectors = [Vector]()
    
    func analyseImage(image: UIImage?, completion: @escaping ([Float]) -> Void) {
        guard let modelPath = Bundle.main.path(forResource: "mobilefacenet", ofType: "tflite") else {
            fatalError("MobileFaceNet model not found.")
        }
        
        guard let inputData = preprocessImage(image) else { return }

        var interpreter: Interpreter
        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter.allocateTensors()
            try interpreter.copy(inputData, toInputAt: 0)
            try interpreter.invoke()
            let outputTensor = try interpreter.output(at: 0)
            let outputData: [Float32] = outputTensor.data.withUnsafeBytes { pointer in
                guard let baseAddress = pointer.baseAddress else { return [] }
                return Array(UnsafeBufferPointer<Float32>(start: baseAddress.assumingMemoryBound(to: Float32.self),
                                                          count: outputTensor.shape.dimensions.reduce(1, *)))
            } as! [Float32]
            print(outputData)
            completion(outputData)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveVector(name: String?, image: UIImage?) {
        let item = SavedVector()
        item.name = name ?? ""
        analyseImage(image: image) { vector in
            item.vector = self.arrayToString(array: vector)
            try! self.realm.write {
                self.realm.add(item)
            }
        }
    }
    
    func preprocessImage(_ image: UIImage?) -> Data? {
        guard let resizedImage = image?.resize(to: .init(width: 97, height: 97)),
              let pixelBuffer = resizedImage.toPixelBuffer() else {
            return nil
        }

        var inputData = Data()
        let normalizedPixels = pixelBuffer.prefix(150528 / 4).map { Float($0) / 255.0 }

        normalizedPixels.withUnsafeBufferPointer { bufferPointer in
            inputData.append(contentsOf: UnsafeRawBufferPointer(bufferPointer))
        }
        return inputData
    }
    
    func loadVector() -> [Vector] {
        var vectors: [Vector] = []
        let items = realm.objects(SavedVector.self)
        for item in items {
            let vector = Vector(name: item.name, vector: stringToArray(string: item.vector), distance: item.distance)
            vectors.append(vector)
        }
        return vectors
    }
    
    func cosineSimilarity(_ vectorA: [Float], _ vectorB: [Float]) -> Float {
        let dotProduct = zip(vectorA, vectorB).map(*).reduce(0, +)
        let magnitudeA = sqrt(vectorA.map { $0 * $0 }.reduce(0, +))
        let magnitudeB = sqrt(vectorB.map { $0 * $0 }.reduce(0, +))
        return dotProduct / (magnitudeA * magnitudeB)
    }
    
    func getResult(image: UIImage?) -> Vector {
        var result = Vector(name: "Unknown", vector: [], distance: 0)
        
        analyseImage(image: image) { targetVector in
            for vector in  self.loadVector() {
                let distance = self.cosineSimilarity(targetVector, vector.vector)
                let dist = distance * distance
                if dist > 0.7 && result.distance < dist {
                    result = vector
                    result.distance = dist
                }
            }
        }
        return result
    }
    
    func convertToArray(from mlMultiArray: MLMultiArray) -> [Double] {
        
        if let list = try? UnsafeBufferPointer<Double>(mlMultiArray) {
            print(Array(list))
            return Array(list)
        }
        return []
    }
    
    func l2distance(_ feat1: [Double], _ feat2: [Double]) -> Double {
        let dotProduct = zip(feat1, feat2).map { $0 * $1 }.reduce(0, +)
        let magnitude1 = sqrt(feat1.map { $0 * $0 }.reduce(0, +))
        let magnitude2 = sqrt(feat2.map { $0 * $0 }.reduce(0, +))
        return dotProduct / (magnitude1 * magnitude2)
    }
    
    func arrayToString(array: [Float]) -> String {
        var str = ""
        for item in array {
            str += ",\(item)"
        }
        return str
    }
    
    func stringToArray(string: String) -> [Float] {
        var vector: [Float] = []
        var array = string.components(separatedBy: ",")
        array.removeFirst()
        for item in array {
            vector.append(Float(item)!)
        }
        return vector
    }
}
