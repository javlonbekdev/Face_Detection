//
//  Extensions.swift
//  Test
//
//  Created by Afraz Siddiqui on 3/18/21.
//

import UIKit
import TensorFlowLite

extension UIImage {
    /// Crop the image to be the required size.
    ///
    /// - parameter bounds:    The bounds to which the new image should be cropped.
    ///
    /// - returns:             Cropped `UIImage`.
    
    func cropping(to bounds: CGRect) -> UIImage? {
        // if bounds is entirely within image, do simple CGImage `cropping` …
        
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
    
    /// Resize image
    /// - Parameter size: Size to resize to
    /// - Returns: Resized image
    
    // Load and preprocess the image
    
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func toPixelBuffer() -> [UInt8]? {
        // Create a graphics context for resizing the image
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
            
            // Draw the image into the context to populate pixel data
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
