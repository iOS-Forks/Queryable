//
//  PhotoSearcherModel.swift
//  TestEncoder
//
//  Created by Ke Fang on 2022/12/08.
//
import UIKit
import CoreML
import Foundation
import Accelerate

struct PhotoSearcherModel {
    private var texEncoder: TextEncoder?
    
    mutating func load_text_encoder() {
        texEncoder = try! TextEncoder()
    }
    
    func text_embedding(prompt: String) -> MLShapedArray<Float32> {
        let emb = try! texEncoder?.computeTextEmbedding(prompt: prompt)
        return emb!
    }
    
    func cosine_similarity(A: MLShapedArray<Float32>, B: MLShapedArray<Float32>) async -> Float {
        return await CLIPHelper.shared.cosine_similarity(A: A, B: B)
    }
    
    func spherical_dist_loss(A: MLShapedArray<Float32>, B: MLShapedArray<Float32>) async -> Float {
        let a = vDSP.divide(A.scalars, sqrt(vDSP.sumOfSquares(A.scalars)))
        let b = vDSP.divide(B.scalars, sqrt(vDSP.sumOfSquares(B.scalars)))
        
        let magnitude = sqrt(vDSP.sumOfSquares(vDSP.subtract(a, b)))
        return pow(asin(magnitude / 2.0), 2) * 2.0
    }

}
