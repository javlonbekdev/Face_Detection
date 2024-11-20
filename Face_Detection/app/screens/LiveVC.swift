//
//  LeaveVC.swift
//  Face_Detection
//
//  Created by Javlonbek Dev on 11/11/24.
//

import AVFoundation
import UIKit
import Vision

class LiveVC: UIViewController {
    let vectorHelper = VectorHelper()
    var timer: Timer?
    var cropImage: UIImage?
    
    private var captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let photoDataOutput = AVCapturePhotoOutput()
    private var faceLayers: [CAShapeLayer] = []
    var label = UILabel()
    
    var faceRect = CGRect()
    var faceRectLive = CGRect()
    
    let button = UIButton(configuration: .filled())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        DispatchQueue.main.async {
            self.captureSession.startRunning()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let vector = self?.vectorHelper.getResult(image: self?.cropImage) else { return }
            self?.label.text = vector.name + " " + String(format: ": %.2f", vector.distance)
        }
        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .systemBackground
        previewLayer.frame = view.frame
        
        view.addSubviews(button, label)
        button.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
            $0.width.height.equalTo(60)
        }
        button.configuration?.baseBackgroundColor = .systemBackground
        button.configuration?.baseForegroundColor = .label
        button.configuration?.image = UIImage(systemName: "camera.aperture")
        
        label.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(12)
        }
    }
    
    @objc func buttonTap() {
        faceRect = faceRectLive
        photoDataOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    private func setupCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                    
                    setupPreview()
                }
            }
        }
    }
    
    private func setupPreview() {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(self.previewLayer)
        
        self.videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        self.captureSession.addOutput(self.photoDataOutput)
        
        let videoConnection = self.videoDataOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
}

extension LiveVC: AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                self.faceLayers.forEach({ drawing in drawing.removeFromSuperlayer() })
                
                if let observations = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionObservations(observations: observations, buffer: sampleBuffer)
                }
            }
        })
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .leftMirrored)
        
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func displayCapturedImage(buffer: CMSampleBuffer, faceRect: CGRect) {
        // Convert pixel buffer to CIImage
        guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            return
        }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        // Convert CIImage to UIImage for further processing
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let image = UIImage(cgImage: cgImage)
            
            // Process the UIImage (e.g., display it, save it, apply filters)
            //            DispatchQueue.main.async {
            let scaleX = image.size.width / self.view.frame.width
            let scaleY = image.size.height / self.view.frame.height
            
            cropImage = image.cropping(to: CGRect(x: (self.view.frame.width - faceRect.maxX) * scaleX, y: faceRect.minY * scaleY, width: faceRect.width * scaleX, height: faceRect.height * scaleX))
        }
    }
    
    func handleFaceDetectionObservations(observations: [VNFaceObservation], buffer: CMSampleBuffer) {
        for observation in observations {
            let faceRectConverted = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observation.boundingBox)
            let faceRectPath = CGPath(rect: faceRectConverted, transform: nil)
            
            let faceLayer = CAShapeLayer()
            faceLayer.path = faceRectPath
            faceLayer.fillColor = UIColor.clear.cgColor
            faceLayer.strokeColor = UIColor.yellow.cgColor
            
            self.faceLayers.append(faceLayer)
            self.view.layer.addSublayer(faceLayer)
            
            displayCapturedImage(buffer: buffer, faceRect: faceRectConverted)
            
            faceRectLive = faceRectConverted
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let data = photo.fileDataRepresentation(),
              let image =  UIImage(data: data)  else {
            return
        }
        
        let scaleX = image.size.width / view.frame.width
        let scaleY = image.size.height / view.frame.height
        
        let cropImage = image.cropping(to: CGRect(x: (view.frame.width - faceRect.maxX) * scaleX, y: faceRect.minY * scaleY, width: faceRect.width * scaleX, height: faceRect.height * scaleX))
        
        let vc = NameAddVC()
        vc.cropImage = cropImage
        present(vc, animated: true, completion: nil)
    }
}
