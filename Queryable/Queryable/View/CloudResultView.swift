//
//  ContentView.swift
//  AIPoem
//
//  Created by andforce on 2023/6/25.
//

import SwiftUI
import CoreData
import CommonLibs
import Photos
import SwiftUIViews

struct CloudResultView: View {
    
    @State private var imageViewSize: CGSize? = CGSize.zero
    
    @State private var saveViewSize: CGSize? = CGSize.zero
    
    @ObservedObject var viewModel = CloudViewModel.shared
    
    @EnvironmentObject var rotationState: RotationState
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ScrollView {
            VStack {
                saveView
            }
            // 设置frame是为了让ScrollView宽度充满
            .frame(width: DeviceUtils.screenSize().width)
        }
        
        // 自定义返回button
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:CloseButton(dismiss: {
            presentationMode.wrappedValue.dismiss()
        })
        )
        
        .navigationViewStyle(.stack)
        
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            let orgSize = self.$saveViewSize.wrappedValue ?? CGSize.zero
            saveView.asImage(size: orgSize).saveToAlbum()
            
            viewModel.showSaveStatusView(success: true, msg: "成功保存到相册")
        }, label: {
            Label("Save Image", systemImage: "tray.and.arrow.down")
        }))
        
        
        .navigationViewStyle(.stack)
//        .sheet(isPresented: $viewModel.isShowingImagePicker) {
//            ImagePicker(selectedImage: $viewModel.selectedImage)
//        }
        
        .environmentObject(rotationState)
        
        .onChange(of: viewModel.selectedImage, perform: { newValue in
            if newValue != nil {
                //self.viewModel.uploadImageForAI(image: newValue!)
                self.viewModel.checkCloudSpecie(image: newValue)
            }
        })
//        .onAppear {
//            //self.viewModel.loadUIImage(asset: asset)
//            self.viewModel.checkCloudSpecie(image: newValue)
//        }
        .onAppear {
            self.rotationState.isRotated = UIDevice.current.orientation.isLandscape
            NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                self.rotationState.isRotated = UIDevice.current.orientation.isLandscape
            }
        }
        .onDisappear {
            //self.viewModel.clearCurrentPoem()
        }
        .overlay(dialogStatusView)
        
    }
    
    private var dialogStatusView: some View {
        VStack {
            if viewModel.isShowSaveStatusView {
                DialogStatusView(isPresented: $viewModel.isShowSaveStatusView,
                                 isSuccess: $viewModel.isShowSaveSuccess,
                                 message: $viewModel.saveStatusMsg
                )
                .animation(.easeInOut, value: viewModel.isShowSaveStatusView)
                .onDisappear {
                    // 弹出评级框
                    StoreReviewHelper.shared.requestAppInnerReview()
                }
            }
        }
    }
    
    private var saveView: some View {
        VStack(spacing: 0) {
            if let image = self.viewModel.selectedImage {
                ZStack {
                    
                    // 背景框
                    Image(uiImage: UIImage())
                        .resizable()
                        .background(Color.white)
                        .cornerRadius(2)
                        .frame(width: (self.imageViewSize ?? CGSize.zero).width + 18 * 2, height: (self.imageViewSize ?? CGSize.zero).height + 18 * 2)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: -2, y: 2)
                    
                    
                    // 用户图和诗句
                    VStack {
                        // 用户图片
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(2)
                            .frame(width: DeviceUtils.screenSmallWidth() - 18 * 4)
                        
                        if let cloud = self.viewModel.cloud {
                            // 诗句
                            VStack(spacing: 8) {
                                // 诗的句子
                                Text(cloud.summery)
                                    .foregroundColor(Color("mainColor"))
                                    .font(.system(size: 17))
                                if !self.isNeedHideBottomInfo() {
                                    HStack(spacing: 0) {
                                        
                                        if true {
                                            // 诗的标题
                                            Text("《\(cloud.cloudName)》")
                                                .foregroundColor(Color.secondary)
                                                .font(.system(size: 14))
                                        }
                                        
                                    }
                                }
                            }
                            .frame(width: DeviceUtils.screenSmallWidth() - 18 * 4)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        }
                        
                        
                    }
                    .background(GeometryReader { proxy in
                        Color.clear.preference(key: SizeKey.self, value: proxy.size)
                    })
                    .onPreferenceChange(SizeKey.self) { value in
                        self.imageViewSize = value
                    }
                }
                .padding()
                .background(GeometryReader { proxy in
                    Color.clear.preference(key: SaveSizeKey.self, value: proxy.size)
                })
                .onPreferenceChange(SaveSizeKey.self) { value in
                    self.saveViewSize = value
                }
            }
        }
        // 为了保存照片后，去掉上面的空白
        .edgesIgnoringSafeArea(.all)
    }
    
    func isNeedHideBottomInfo()-> Bool{
        return false//!SettingsManager.shared.isShowAuthor() && !SettingsManager.shared.isShowTitle() && !SettingsManager.shared.isShowDynasty()
    }
    
    struct SaveSizeKey: PreferenceKey {
        static let defaultValue: CGSize? = nil
        
        static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
            value = value ?? nextValue()
        }
    }
    
    struct SizeKey: PreferenceKey {
        static let defaultValue: CGSize? = nil
        
        static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
            value = value ?? nextValue()
        }
    }
}


//{
//    "cloudId":"As",
//    "cloudName":"高层云",
//    "cloudNameEng":"Altostratus",
//    "summery":"灰色或蓝色云片或条纹层，纤维状或均匀外观，完全或部分覆盖天空，至少可透过磨砂玻璃或毛玻璃隐约地看见太阳，不显示光晕现象。"
//},

public class Cloud: Codable {
    var cloudId: String
    
    var cloudName: String
    
    var cloudNameEng: String
    
    var summery: String
    
}
