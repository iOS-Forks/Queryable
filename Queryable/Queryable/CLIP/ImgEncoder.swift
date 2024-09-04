//
//  ImgEncoder.swift
//  TestEncoder
//
//  Created by Ke Fang on 2022/12/08.
//

import Foundation
import CoreML
import UIKit

public struct ImgEncoder {
    var model: MLModel
    
    init(configuration config: MLModelConfiguration = .init()) throws {
        guard let path = Bundle.main.path(forResource: "CoreMLModels", ofType: nil, inDirectory: nil) else {
            fatalError("Fatal error: failed to find the CoreML models.")
        }
        let baseURL = URL(fileURLWithPath: path)
        
        let imgEncoderURL = baseURL.appending(path:"ImageEncoder_mobileCLIP_s2.mlmodelc")
        let imgEncoderModel = try MLModel(contentsOf: imgEncoderURL, configuration: config)
        self.model = imgEncoderModel
    }
    
    public func computeImgEmbedding(img: UIImage) async -> MLShapedArray<Float32>? {
        let imgEmbedding = await self.encode(image: img)
        return imgEmbedding
    }
    
//    public init(model: MLModel) {
//        self.model = model
//    }
    
    /// Prediction queue
    let queue = DispatchQueue(label: "imgencoder.predict")
    
    private func encode(image: UIImage) async -> MLShapedArray<Float32>? {
        do {
            guard let resizedImage = try image.resizeImageTo(size:CGSize(width: 256, height: 256)) else {
                throw ImageEncodingError.resizeError
            }
            
            guard let buffer = resizedImage.convertToBuffer() else {
                throw ImageEncodingError.bufferConversionError
            }
            
            guard let inputFeatures = try? MLDictionaryFeatureProvider(dictionary: ["colorImage": buffer]) else {
                throw ImageEncodingError.featureProviderError
            }
            
            let result = try queue.sync { try model.prediction(from: inputFeatures) }
            guard let embeddingFeature = result.featureValue(for: "embOutput"),
                  let multiArray = embeddingFeature.multiArrayValue else {
                throw ImageEncodingError.predictionError
            }
            
            return MLShapedArray<Float32>(converting: multiArray)
        } catch {
            print("Error in encoding: \(error)")
            return nil
        }
    }
}

// Define the custom errors
enum ImageEncodingError: Error {
    case resizeError
    case bufferConversionError
    case featureProviderError
    case predictionError
}
