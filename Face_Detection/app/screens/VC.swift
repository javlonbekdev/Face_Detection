//
//  VC.swift
//  Face_Detection
//
//  Created by Javlonbek Dev on 19/02/25.
//

import UIKit
import TensorFlowLite
import CoreImage

class FaceRecognitionViewController: UIViewController {

    private var interpreter: Interpreter!
    private let modelFileName = "facenetnew" // "FaceNet.tflite" fayl nomi (kengaytmasiz)
    private let inputSize = 160
    private let outputSize = 512

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterpreter()
        check()
    }
    
    func check() {
        let image1 = UIImage(named: "face1.jpeg")!
        let image2 = UIImage(named: "face2.jpeg")!

        if let embedding1 = recognizeFace(from: image1),
           let embedding2 = recognizeFace(from: image2) {
            
            let distance = calculateEuclideanDistance(embedding1, embedding2)
            print("Yuzlar orasidagi masofa: \(distance)")

            if distance < 1.0 {
                print("Yuzlar bir xil!")
            } else {
                print("Yuzlar har xil!")
            }
        }
    }
    
    func calculateEuclideanDistance(_ vector1: [Float], _ vector2: [Float]) -> Float {
        guard vector1.count == vector2.count else { return Float.greatestFiniteMagnitude }
        
        let distance = zip(vector1, vector2).map { (a, b) in (a - b) * (a - b) }.reduce(0, +)
        return sqrt(distance)
    }

    private func setupInterpreter() {
        guard let modelPath = Bundle.main.path(forResource: modelFileName, ofType: "tflite") else {
            print("Model fayli topilmadi!")
            return
        }
        
        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter.allocateTensors()
            print("Model muvaffaqiyatli yuklandi!")
        } catch {
            print("Modelni yuklashda xatolik: \(error)")
        }
    }

    func recognizeFace(from image: UIImage) -> [Float]? {
        guard let pixelBuffer = preprocessImage(image) else {
            print("Rasmni tayyorlashda muammo!")
            return nil
        }

        do {
            try interpreter.copy(pixelBuffer, toInputAt: 0)
            try interpreter.invoke()
            
            let outputTensor = try interpreter.output(at: 0)
            let embeddings = [Float](unsafeData: outputTensor.data) ?? []
            print("Embeddinglar: \(embeddings)")
            return embeddings
        } catch {
            print("Model ishlashida xatolik: \(error)")
            return nil
        }
    }

    private func preprocessImage(_ image: UIImage) -> Data? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        
        guard let resizedImage = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: inputSize, height: inputSize)) else {
            return nil
        }

        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
        guard let context2 = CGContext(data: nil,
                                       width: inputSize,
                                       height: inputSize,
                                       bitsPerComponent: 8,
                                       bytesPerRow: inputSize * 4,
                                       space: CGColorSpaceCreateDeviceRGB(),
                                       bitmapInfo: bitmapInfo) else {
            return nil
        }

        context2.draw(resizedImage, in: CGRect(x: 0, y: 0, width: inputSize, height: inputSize))

        guard let pixelBuffer = context2.data else { return nil }

        return Data(bytes: pixelBuffer, count: inputSize * inputSize * 12)
    }
}

extension Array where Element == Float {
    init?(unsafeData: Data) {
        let count = unsafeData.count / MemoryLayout<Float>.size
        self = unsafeData.withUnsafeBytes {
            Array(UnsafeBufferPointer<Float>(start: $0, count: count))
        }
    }
}
