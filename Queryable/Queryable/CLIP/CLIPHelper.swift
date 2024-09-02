//
//  CLIPHelper.swift
//  Queryable
//
//  Created by Dy Wang on 2024/9/2.
//

import Foundation
import CoreML
import Accelerate

class CLIPHelper {
    static let shared = CLIPHelper()
    
    private init() {
        // 私有化初始化方法以确保单例模式
    }
    
    func cosine_similarity(A: MLShapedArray<Float32>, B: MLShapedArray<Float32>) async -> Float {
        let magnitude = vDSP.sumOfSquares(A.scalars).squareRoot() * vDSP.sumOfSquares(B.scalars).squareRoot()
        let dotarray = vDSP.dot(A.scalars, B.scalars)
        return  dotarray / magnitude
    }
}
