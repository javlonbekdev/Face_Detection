//
//  Extensions.swift
//  Test
//
//  Created by Afraz Siddiqui on 3/18/21.
//

import UIKit

extension UIImage {
    func toPixelBuffer(size: Int) -> CVPixelBuffer? {
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, size, size, kCVPixelFormatType_32BGRA, attributes as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size, height: size))
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        
        return buffer
    }
    
    func cropping(to bounds: CGRect) -> UIImage? {
        
        if CGRect(origin: .zero, size: size).contains(bounds),
           imageOrientation == .up,
           let cropped = cgImage?.cropping(to: bounds * scale)
        {
            return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation)
        }
        
        // … otherwise, manually render whole image, only drawing what we need
        
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = scale
        
        return UIGraphicsImageRenderer(size: bounds.size, format: format).image { _ in
            let origin = CGPoint(x: -bounds.minX, y: -bounds.minY)
            draw(in: CGRect(origin: origin, size: size))
        }
    }
    
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func toRGBPixelBuffer() -> [UInt8]? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = 160
        let height = 160
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = width * height * bytesPerPixel
        
        var rawData = [UInt8](repeating: 0, count: totalBytes)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: &rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // ✅ Faqat RGB olish (RGBA bo'lsa, alpha kanalni o‘chiramiz)
        var rgbData = [UInt8]()
        for i in stride(from: 0, to: rawData.count, by: 4) {
            rgbData.append(rawData[i])   // R
            rgbData.append(rawData[i+1]) // G
            rgbData.append(rawData[i+2]) // B
        }
        
        return rgbData
    }
    
    func toPixelBuffer() -> [UInt8]? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        
        // Get the resized image
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext(),
              let cgImage = resizedImage.cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        // Create a buffer to hold pixel data
        let width = Int(size.width)
        let height = Int(size.height)
        let bytesPerPixel = 4 // RGBA format
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        var pixelData = [UInt8](repeating: 0, count: totalBytes)
        
        // Create a context to extract pixel data
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8, // Each channel is 8 bits
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        return pixelData
    }
}

extension CGSize {
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}

extension CGPoint {
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

extension CGRect {
    static func * (lhs: CGRect, rhs: CGFloat) -> CGRect {
        return CGRect(origin: lhs.origin * rhs, size: lhs.size * rhs)
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview)
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach(addArrangedSubview)
    }
}
