//
//  CloudTextModel.swift
//  Queryable
//
//  Created by Dy Wang on 2024/9/2.
//

import Foundation
import CoreML

class CloudHaveChecker {
    static let shared = CloudHaveChecker()

    private var encodedLabels: [MLShapedArray<Float32>] = []
    private var cloud_encodeds_encoded: [MLShapedArray<Float32>] = []
    
    private init() {
        let textEncoder = try! TextEncoder()
        

        for cloud_encoded in cloud_encodeds {
            let embedding = try! textEncoder.computeTextEmbedding(prompt: cloud_encoded)
            cloud_encodeds_encoded.append(embedding)
        }
    }

    private let cloud_encodeds = [
        "cloud",
        "clouds", 
        "sky",
        "fog",
        "mist",
        "rain",
        "snow",
        "sun",
        "moon"
    ]

    func isHaveCloud(in embedding: MLShapedArray<Float32>) async -> Bool {
        for cloudEmbedding in cloud_encodeds_encoded {
            let similarity = await CLIPHelper.shared.cosine_similarity(A: embedding, B: cloudEmbedding)
            print("CloudTextHelper --->> similarity: \(similarity)")
            if similarity >= 0.2 { // 设定一个相似度阈值
                return true
            }
        }
        return false
    }
}
