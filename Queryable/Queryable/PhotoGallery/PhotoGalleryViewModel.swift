//
//  PhotoGalleryViewModel.swift
//  AIPoem
//
//  Created by andforce on 2023/6/27.
//

import Foundation
import Photos
import UIKit

public class PhotoGalleryViewModel: ObservableObject {
    public static let shared = PhotoGalleryViewModel()
    
    private init() {}
    
    
    @Published var assetImageDic:[PHAsset:UIImage] = [:]
    
    private var assetImageDicCache:[PHAsset:UIImage] = [:]
    private var phAssetsCache:[PHAsset] = [PHAsset]()
    
    @Published var phAssets:[PHAsset] = [PHAsset]()
    
    @Published var isShowPayAlert: Bool = false
    
    @Published var isLinkActive: Bool = false
    
    var count:Int = 0
    
    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited{
                let size = CGSize(width: 200, height: 200)
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let result = PHAsset.fetchAssets(with: options)
                
                print("fetchPhotosCount: \(result.count)")
                if result.count > 0 {
                    result.enumerateObjects { asset, _, _ in
                        if self.isShowPayAlert || PayModel.shared.isShowPayUI{
                            self.phAssetsCache.append(asset)
                            asset.toUIImage(targetSize: size) { image in
                                self.assetImageDicCache.updateValue(image, forKey: asset)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.phAssets.append(asset)
                            }
                            
                            asset.toUIImage(targetSize: size) { image in
                                DispatchQueue.main.async {
                                    self.assetImageDic.updateValue(image, forKey: asset)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func goLink() {
        self.isLinkActive = true
        CountChecker.shared.updateTodayCount()
    }
    
    func showPayAlert() {
        isShowPayAlert = true
    }
    
    func hidePayAlert() {
        isShowPayAlert = false
        self.refreshGallery()
    }
    
    func refreshGallery() {
        DispatchQueue.main.async {
            self.phAssets.append(contentsOf: self.phAssetsCache)
            self.phAssetsCache.removeAll()
            
            for key in self.assetImageDicCache.keys {
                if self.isShowPayAlert || PayModel.shared.isShowPayUI {
                    break
                }
                if let imageValue = self.assetImageDicCache[key] {
                    self.assetImageDic.updateValue(imageValue, forKey: key)
                }
            }
        }
    }
    
    func isLimit() -> Bool{
        return CountChecker.shared.isLimit()
    }
}
