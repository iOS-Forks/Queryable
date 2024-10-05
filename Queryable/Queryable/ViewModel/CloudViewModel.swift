//
//  CloudViewModel.swift
//  Queryable
//
//  Created by Dy Wang on 2024/9/4.
//

import Foundation
import UIKit
import CommonLibs

class CloudViewModel : ObservableObject {
    
    @Published var cloud: Cloud?
    
    private let products: [Cloud] = JsonUtils.toCodableModel(jsonFile: Bundle.main.path(forResource: "clouds", ofType: "json")!)!
    
    @Published var showCloudSpecies: Bool = false
    
    @Published var selectedImage: UIImage? = nil
    
    private func findCloudWithId(_ cloudId: String) -> Cloud {
        for cloud in products {
            if cloud.cloudId == cloudId {
                return cloud
            }
        }
        
        return products.last!
    }
    
    private func updateCloudSpecies(_ newValue: String) {
        DispatchQueue.main.async {
            self.cloud = self.findCloudWithId(newValue)
        }
    }
    
    private func updateShowCloudSpecies(_ newValue: Bool) {
        DispatchQueue.main.async {
            self.showCloudSpecies = newValue
        }
    }

    static let shared = CloudViewModel()
    
    private let imgEncoder: ImgEncoder
    private let cloudTextModel: CloudHaveChecker
    
    private init() {
        do {
            self.imgEncoder = try ImgEncoder()
            self.cloudTextModel = CloudHaveChecker.shared
        } catch {
            fatalError("初始化ImgEncoder失败: \(error)")
        }
    }
    
    
    func checkCloudSpecie(image: UIImage?) {
        guard let image = image else {
            return
        }
        Task {
            
            do {
                guard let cropImage = image.cropImageForCLIP() else {
                    print("调整图像大小失败")
                    self.updateCloudSpecies("NONE")
                    return
                }
                
                guard let resizedImage = try cropImage.resizeImageTo(size: CGSize(width: 256, height: 256)) else {
                    print("调整图像大小失败")
                    self.updateCloudSpecies("NONE")
                    return
                }
                guard let embedding = await imgEncoder.computeImgEmbedding(img: resizedImage) else {
                    print("无法计算图像嵌入")
                    self.updateCloudSpecies("NONE")
                    return
                }
                print("图像嵌入: \(embedding)")
                
                let hasCloudInPic = await cloudTextModel.isHaveCloud(in: embedding)
                
                if hasCloudInPic {
                    
//                    guard let closestLabel = await cloudTextModel.findClosestCloudLabel(for: embedding) else {
//                        print("未找到匹配的标签")
//                        self.updateCloudSpecies("NONE")
//                        return
//                    }
//                    print("最接近的云标签: \(closestLabel)")
//                    self.updateCloudSpecies(closestLabel)
                    
                    let result = CloudImageClassifier.shared.classifyImage(image)
                    print("CloudViewModel --->> 云识别结果：\(result)")
                    self.updateCloudSpecies(result)
                    
                } else {
                    print("未找到匹配的标签")
                    self.updateCloudSpecies("NONE")
                }
                
                print("图片中有云: \(hasCloudInPic)")
            } catch {
                print("编码图像时出错: \(error)")
                print("未找到匹配的标签")
                self.updateCloudSpecies("NONE")
            }
            self.updateShowCloudSpecies(true)
        }
    }
    
    @Published var isShowSaveStatusView = false
    @Published var isShowSaveSuccess = true
    @Published var saveStatusMsg: String = ""
    
    func showSaveStatusView(success: Bool, msg: String) {
        isShowSaveSuccess = success
        saveStatusMsg = msg
        isShowSaveStatusView = true
    }
}
