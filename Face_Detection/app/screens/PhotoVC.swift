//
//  PhotoVC.swift
//  Face_Detection
//
//  Created by Javlonbek Dev on 11/11/24.
//

import UIKit
import Vision

class PhotoVC: UIViewController {
    
    let imageView = UIImageView()
    let cropImage = UIImageView()
    var scaledImageRect: CGRect?
    
    override func viewDidLoad() {
        view.backgroundColor = .cyan
        
        view.addSubview(imageView)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(cropImage)
        
        cropImage.frame = .init(x: view.bounds.width / 2 - 80, y: 20, width: 160, height: 160)
        cropImage.contentMode = .scaleAspectFit
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let image = UIImage(named: "jav") {
            imageView.image = image
            
            guard let cgImage = image.cgImage else { return }
            
            calculateScaledImageRect(image: cgImage)
            performVisionRequest(image: cgImage)
        }
    }
    
    private func calculateScaledImageRect(image: CGImage) {
        
        let originalWidth = CGFloat(image.width)
        let originalHeight = CGFloat(image.height)
        
        let imageFrame = imageView.frame
        let widthRatio = originalWidth / imageFrame.width
        let heightRatio = originalHeight / imageFrame.height
        
        // ScaleAspectFit
        let scaleRatio = max(widthRatio, heightRatio)
        
        let scaledImageWidth = originalWidth / scaleRatio
        let scaledImageHeight = originalHeight / scaleRatio
        
        let scaledImageX = (imageFrame.width - scaledImageWidth) / 2
        let scaledImageY = (imageFrame.height - scaledImageHeight) / 2
        
        self.scaledImageRect = CGRect(
            x: scaledImageX,
            y: scaledImageY,
            width: scaledImageWidth,
            height: scaledImageHeight
        )
    }
    
    private func performVisionRequest(image: CGImage) {
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaceDetectionRequest)
        
        let requests = [faceDetectionRequest]
        let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                        orientation: .up,
                                                        options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error as NSError {
                print(error)
                return
            }
        }
    }
    
    private func handleFaceDetectionRequest(request: VNRequest?, error: Error?) {
        if let requestError = error as NSError? {
            print(requestError)
            return
        }
        
        guard let imageRect = self.scaledImageRect else {
            return
        }
        
        let imageWidth = imageRect.size.width
        let imageHeight = imageRect.size.height
        
        DispatchQueue.main.async {
            
            self.imageView.layer.sublayers = nil
            if let results = request?.results as? [VNFaceObservation] {
                
                for observation in results {
                    
                    print(observation.boundingBox)
                    
                    var scaledObservationRect = observation.boundingBox
                    scaledObservationRect.origin.x = imageRect.origin.x + (observation.boundingBox.origin.x * imageWidth)
                    scaledObservationRect.origin.y = imageRect.origin.y + (1 - observation.boundingBox.origin.y - observation.boundingBox.height) * imageHeight
                    scaledObservationRect.size.width *= imageWidth
                    scaledObservationRect.size.height *= imageHeight
                    
                    let faceRectanglePath = CGPath(rect: scaledObservationRect, transform: nil)
                    
                    let faceLayer = CAShapeLayer()
                    
                    faceLayer.path = faceRectanglePath
                    faceLayer.fillColor = UIColor.clear.cgColor
                    faceLayer.strokeColor = UIColor.yellow.cgColor
                    self.imageView.layer.addSublayer(faceLayer)
                    
                    guard let inputImage = self.imageView.image else { return }
                    let scale = inputImage.size.width / self.imageView.frame.width
                    
                    print(scaledObservationRect.origin)
                    
                    self.cropImage.image = inputImage.cropping(to: .init(x: scaledObservationRect.minX * scale, y: imageRect.minY * scale, width: scaledObservationRect.width * scale, height: scaledObservationRect.height * scale))
                }
            }
        }
    }
}
