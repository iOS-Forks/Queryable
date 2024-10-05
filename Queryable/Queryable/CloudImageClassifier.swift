//
//  ImageClassifier.swift
//  Queryable
//
//  Created by Dy Wang on 2024/10/5.
//

import CoreML
import Vision
import UIKit
import CommonLibs

class CloudImageClassifier {
    
    public static let shared = CloudImageClassifier()
    
    private init() {}
    
    private let model = try! best(configuration: .init()).model

    func classifyImage(_ inputImage: UIImage) -> String {
        
        // 将 UIImage 转换为 Core ML 需要的输入格式 (400x400)
        guard let buffer = inputImage.resize(to: CGSize(width: 400, height: 400))?.toCVPixelBuffer() else {
            return "NONE"
        }
        
        do {
            // 创建输入
            let input = try MLDictionaryFeatureProvider(dictionary: ["image" : buffer])
            
            // 获取输出
            let prediction = try model.prediction(from: input)
            
            let prob = prediction.featureValue(for: "classLabel_probs")
            
            print("--->> \(prob)")
            
            // 输出的分类标签
            if let outputLabel = prediction.featureValue(for: "classLabel")?.stringValue {
                return outputLabel
            }
        } catch {
            print("Failed to make prediction: \(error.localizedDescription)")
        }
        
        return "NONE"
    }
}


import UIKit
import CoreVideo

extension UIImage {
    // 调整图像大小
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    // 将 UIImage 转换为 CVPixelBuffer
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        var pixelBuffer: CVPixelBuffer?
        let options: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ]
        
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
        
        guard let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }
        
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return buffer
    }
}
